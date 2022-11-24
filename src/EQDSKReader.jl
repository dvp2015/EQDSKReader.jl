"""
    EQDSKReader

Provides functionality to read EQDSK file.
"""
module EQDSKReader

using Interpolations
using Statistics
using StructEquality

export Content,
    zpoints,
    rpoints,
    normalize_psi,
    lowest_boundary_point,
    calc_boundary_psi,
    create_psi_interpolator,
    calc_boundary_psi,
    create_normalized_psi_interpolator,
    psi_separation_z,
    in_plasma
"""
    Content

Content of EQDSK file.

Attrs:

    case    identification character string
    nw      number of horizontal grid points
    nh      number of vertical grid points
    rdim    horizontal dimension in metter of computational box
    zdim    vertical dimension in metter of computational box
    rcentr  R in meter of vacuum toroidal magnetic field BCENTR
    rleft   Minimum R in meter of rectangular computational box
    zmid    Z of center of computational box in meter
    rmaxis  R of magnetic axis in meter
    zmaxis  Z of magnetic axis in meter
    simag   poloidal flux at magnetic axis in Weber /rad
    sibry   poloidal flux at the plasma boundary in Weber /rad
    bcentr  Vacuum toroidal magnetic field in Tesla at RCENTR
    current Plasma current in Ampere
    fpol    Poloidal current function in m-T, F = RB_T on flux grid
    pres    Plasma pressure in nt / m^2 on uniform flux grid
    ffprim  FF’(ψ) in (mT)^2 / (Weber /rad) on uniform flux grid
    pprime  P’(ψ) in (nt/m^2 ) / (Weber /rad) on uniform flux grid
    psirz   Poloidal flux in Weber / rad on the rectangular grid points
    qpsi    q values on uniform flux grid from axis to boundary
    nbbbs   Number of boundary points
    limitr  Number of limiter points
    rbbbs   R of boundary points in meter
    zbbbs   Z of boundary points in meter
    rlim    R of surrounding limiter contour in meter
    zlim    Z of surrounding limiter contour in mete
"""
struct Content
    case::String
    nw::Int16
    nh::Int16
    rdim::Float64
    zdim::Float64
    rcentr::Float64
    rleft::Float64
    zmid::Float64
    rmaxis::Float64
    zmaxis::Float64
    simag::Float64
    sibry::Float64
    bcentr::Float64
    current::Float64
    fpol::Vector{Float64}
    pres::Vector{Float64}
    ffprim::Vector{Float64}
    pprime::Vector{Float64}
    psirz::Matrix{Float64}
    qpsi::Vector{Float64}
    nbbbs::Int16
    limitr::Int16
    rbbbs::Vector{Float64}
    zbbbs::Vector{Float64}
    rlim::Vector{Float64}
    zlim::Vector{Float64}
end

"""
    Content(io::IO)

Build [`Content`](@ref) object from an input stream with a in EQDSK format.

"""
Content(io::IO) = read_eqdsk(io)
"""
    Content(path::AbstractString)

Build [`Content`](@ref) object from a file with a in EQDSK format.

"""
Content(path::AbstractString) = open(read_eqdsk, path)

@struct_hash_equal_isequal_isapprox Content

join_lines_skipping_eols(io::IO) = reduce(*, readlines(io))
read_str(io::IO, bytes::Integer) = String(Base.read(io, bytes))

function read_number(::Type{T}, io::IO, bytes::Integer) where {T<:Number}
    return parse(T, read_str(io, bytes))
end

function read_numbers(::Type{T}, io::IO, bytes::Integer, count::Integer) where {T<:Number}
    return (read_number(T, io, bytes) for _ in 1:count)
end

read_floats(io::IO, count::Integer) = read_numbers(Float64, io, 16, count)
read_vector(io::IO, count::Integer) = Float64[read_floats(io, count)...]

# From "G_EQDSK.pdf":

# "...Briefly, a right-handed
# cylindrical coordinate system (R, φ, Ζ) is used. The G EQDSK provides
# information on the pressure, poloidal current function, q profile on a uniform flux
# grid from the magnetic axis to the plasma boundary and the poloidal flux
# function on the rectangular computation grid. Information on the plasma
# boundary and the surrounding limiter contour in also provided."

# ```code:
#         character*10 case(6)
#         dimension psirz(nw,nh),fpol(1),pres(1),ffprim(1),

#         pprime(1),qpsi(1),rbbbs(1),zbbbs(1),

#         rlim(1),zlim(1)
# c
#         read (neqdsk,2000) (case(i),i=1,6),idum,nw,nh
#         read (neqdsk,2020) rdim,zdim,rcentr,rleft,zmid
#         read (neqdsk,2020) rmaxis,zmaxis,simag,sibry,bcentr
#         read (neqdsk,2020) current,simag,xdum,rmaxis,xdum
#         read (neqdsk,2020) zmaxis,xdum,sibry,xdum,xdum
#         read (neqdsk,2020) (fpol(i),i=1,nw)
#         read (neqdsk,2020) (pres(i),i=1,nw)
#         read (neqdsk,2020) (ffprim(i),i=1,nw)
#         read (neqdsk,2020) (pprime(i),i=1,nw)
#         read (neqdsk,2020) ((psirz(i,j),i=1,nw),j=1,nh)
#         read (neqdsk,2020) (qpsi(i),i=1,nw)
#         read (neqdsk,2022) nbbbs,limitr
#         read (neqdsk,2020) (rbbbs(i),zbbbs(i),i=1,nbbbs)
#         read (neqdsk,2020) (rlim(i),zlim(i),i=1,limitr)
# c
#         2000 format (6a8,3i4)
#         2020 format (5e16.9)
#         2022 format (2i5)

"""
    read_eqdsk(io::IO)

Reads a stream according to spec found in G_EQDSK.pdf.

## returns

    [`Content`](@ref)

"""
function read_eqdsk(io::IO)
    s = IOBuffer(join_lines_skipping_eols(io))
    case = read_str(s, 48)
    skip(s, 4)
    nw, nh = read_numbers(Int16, s, 4, 2) # row 1
    rdim, zdim, rcentr, rleft, zmid = read_floats(s, 5)  # row 2
    rmaxis, zmaxis, simag, sibry, bcentr = read_floats(s, 5)  # row 3
    current, simag2, _, rmaxis2, _ = read_floats(s, 5)  # row 4
    # the input contains duplicating values, let's use them to check the content
    simag2 == simag || error("Invalid file content on simag2")
    rmaxis2 == rmaxis || error("Invalid file content on rmaxis2")
    zmaxis2, _, sibry2, _, _ = read_floats(s, 5)  # row 5
    zmaxis2 == zmaxis || error("Invalid file content on zmaxis2")
    sibry2 == sibry || error("Invalid file content on sibry2")
    fpol = read_vector(s, nw)
    pres = read_vector(s, nw)
    ffprim = read_vector(s, nw)
    pprime = read_vector(s, nw)
    psirz = reshape(read_vector(s, nw * nh), (nw, nh))
    qpsi = read_vector(s, nw)
    nbbbs, limitr = read_numbers(Int16, s, 5, 2)
    A = reshape(read_vector(s, 2 * nbbbs), (2, nbbbs))
    rbbbs = A[1, :]
    zbbbs = A[2, :]
    A = reshape(read_vector(s, 2 * limitr), (2, limitr))
    rlim = A[1, :]
    zlim = A[2, :]

    return Content(
        case,
        nw,
        nh,
        rdim,
        zdim,
        rcentr,
        rleft,
        zmid,
        rmaxis,
        zmaxis,
        simag,
        sibry,
        bcentr,
        current,
        fpol,
        pres,
        ffprim,
        pprime,
        psirz,
        qpsi,
        nbbbs,
        limitr,
        rbbbs,
        zbbbs,
        rlim,
        zlim,
    )
end

"""
    rpoints(c::Content)

## returns
        Coordinates of Ψ(r,z) along tokamak large radius R. 
"""
rpoints(c::Content) = range(c.rleft, c.rleft + c.rdim; length=c.nw)

"""
    zpoints(c::Content)

Returns  coordinates of Ψ(r,z) along tokamak vertial axis Z. 
"""
zpoints(c::Content) = range(c.zmid - 0.5c.zdim, c.zmid + 0.5c.zdim; length=c.nh)

"""
    create_psi_interpolator(ψ, rpoints, zpoints)

Create interpolator for matrix `ψ` with coordinates `rpoints` and `zpoints`.

Returns function `ψ(r,z)` to compute `ψ` at arbitrary point.
"""
function create_psi_interpolator(ψ, r, z)
    scale(interpolate(ψ, BSpline(Quadratic(Line(OnGrid())))), r, z)
end

"""
    create_psi_interpolator(c::Content)

Create `ψ`  interpolator for `Content`.
"""
function create_psi_interpolator(c::Content)
    create_psi_interpolator(c.psirz, rpoints(c), zpoints(c))
end

"""
    calc_boundary_psi(c::Content)

Returns average value of `ψ` at the specified plasma boundary.

This value is used in `normalize_psi`.
"""
function calc_boundary_psi(c::Content)::Float64
    interpolated_psi = create_psi_interpolator(c)
    return mean(interpolated_psi(ri, zi) for (ri, zi) in zip(c.rbbbs, c.zbbbs))
end

"""
    function normalize_psi(ψ::Matrix{Float64})::Matrix{Float64}

Normalize matrix `Ψ` to have zero at minimum and 1.0 
on the specified plasma boundary.


Returns normalized matrix.
"""
function normalize_psi(ψ::Matrix{Float64}, Ψ_boundary::Float64)::Matrix{Float64}
    ψ_min, _ = extrema(ψ)
    return (ψ .- ψ_min) / (Ψ_boundary - ψ_min)
end

normalize_psi(c::Content)::Matrix{Float64} = normalize_psi(c.psirz, calc_boundary_psi(c))

"""
    create_normalized_psi_interpolator(c::Content)::Function

Returns function `ψ(r,z)` where value is 0 at magnetic axis and 1 at plasma boundary
"""
function create_normalized_psi_interpolator(c::Content)::Function
    itp = create_psi_interpolator(normalize_psi(c), rpoints(c), zpoints(c))
    function ψ(r, z)
        return max.(itp(r, z), 0.0)
    end
    ψ
end

"""
    lowest_boundary_point(c::Content)

Returns coordinates of the lowest point at plasma boundary.
This is useful to select points in plasma.
There should be `ψ ≤ 1` and the points are to be above this point.
"""
function lowest_boundary_point(c::Content)::Tuple{Float64,Float64}
    i = argmin(c.zbbbs)
    return c.rbbbs[i], c.zbbbs[i]
end

"""
    psi_separation_z(c::Content)

The Z coordinate to separate plasma and divertor areas with `ψ` ≤ 1.
"""
psi_separation_z(c::Content)::Float64 = lowest_boundary_point(c)[2] - 0.01

"""
    in_plasma(ψ, r, z, separation_z)::Bool

Is point (r,z) in plasma?

"""
in_plasma(ψ, r::Float64, z::Float64, separation_z::Float64)::Bool =
    separation_z < z && ψ(r, z) <= 1.0
in_plasma(ψ, r, z::Float64, separation_z::Float64)::Bool =
    separation_z .< z && all(ψ(r, z) .<= 1.0)
in_plasma(ψ, r, z, separation_z::Float64)::Bool =
    all(separation_z .< z) && all(ψ(r, z) <= 1.0)

end
