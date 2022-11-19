"""
    EQDSKReader

Provides functionality to read EQDSK file.
"""
module EQDSKReader

using StructEquality

export Content, zpoints, rpoints, normalize_psi

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
    rdim::Float32
    zdim::Float32
    rcentr::Float32
    rleft::Float32
    zmid::Float32
    rmaxis::Float32
    zmaxis::Float32
    simag::Float32
    sibry::Float32
    bcentr::Float32
    current::Float32
    fpol::Vector{Float32}
    pres::Vector{Float32}
    ffprim::Vector{Float32}
    pprime::Vector{Float32}
    psirz::Matrix{Float32}
    qpsi::Vector{Float32}
    nbbbs::Int16
    limitr::Int16
    rbbbs::Vector{Float32}
    zbbbs::Vector{Float32}
    rlim::Vector{Float32}
    zlim::Vector{Float32}
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

read_floats(io::IO, count::Integer) = read_numbers(Float32, io, 16, count)
read_vector(io::IO, count::Integer) = Float32[read_floats(io, count)...]

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

## returns

    Coordinates of Ψ(r,z) along tokamak vertial axis Z. 
"""
zpoints(c::Content) = range(c.zmid - 0.5f0 * c.zdim, c.zmid + 0.5f0 * c.zdim; length=c.nh)

"""
    function normalize_psi(ψ::Matrix{Float32})::Matrix{Float32}

Transform matrix `Ψ` to have zero at minimum and 1.0 
on the specified plasma boundary.

## returns

    Transformed matrix
"""
function normalize_psi(ψ::Matrix{Float32})::Matrix{Float32}
    ψ_min, _ = extrema(ψ)
    return (ψ .- ψ_min) / -0.746ψ_min
end

normalize_psi(c::Content) = normalize_psi(c.psirz)

"""
    xpoint(c::Content)

Lowest point at plasma boundary.
This is close to X-point in devertor area, so the name.
"""
function xpoint(c::Content)::Tuple{Float32, Float32}
	i = argmin(c.zbbbs)
	c.rbbbs[i], c.zbbbs[i]
end

end
