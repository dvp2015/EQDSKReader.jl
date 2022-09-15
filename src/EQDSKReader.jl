"""
    EQDSKReader

Functionality to read EQDSK file.

From "G_EQDSK.pdf":

"...Briefly, a right-handed
cylindrical coordinate system (R, φ, Ζ) is used. The G EQDSK provides
information on the pressure, poloidal current function, q profile on a uniform flux
grid from the magnetic axis to the plasma boundary and the poloidal flux
function on the rectangular computation grid. Information on the plasma
boundary and the surrounding limiter contour in also provided."

```code:
        character*10 case(6)
        dimension psirz(nw,nh),fpol(1),pres(1),ffprim(1),

        pprime(1),qpsi(1),rbbbs(1),zbbbs(1),

        rlim(1),zlim(1)
        c
        read (neqdsk,2000) (case(i),i=1,6),idum,nw,nh
        read (neqdsk,2020) rdim,zdim,rcentr,rleft,zmid
        read (neqdsk,2020) rmaxis,zmaxis,simag,sibry,bcentr
        read (neqdsk,2020) current,simag,xdum,rmaxis,xdum
        read (neqdsk,2020) zmaxis,xdum,sibry,xdum,xdum
        read (neqdsk,2020) (fpol(i),i=1,nw)
        read (neqdsk,2020) (pres(i),i=1,nw)
        read (neqdsk,2020) (ffprim(i),i=1,nw)
        read (neqdsk,2020) (pprime(i),i=1,nw)
        read (neqdsk,2020) ((psirz(i,j),i=1,nw),j=1,nh)
        read (neqdsk,2020) (qpsi(i),i=1,nw)
        read (neqdsk,2022) nbbbs,limitr
        read (neqdsk,2020) (rbbbs(i),zbbbs(i),i=1,nbbbs)
        read (neqdsk,2020) (rlim(i),zlim(i),i=1,limitr)
        c
        2000 format (6a8,3i4)
        2020 format (5e16.9)
        2022 format (2i5)
```
"""
module EQDSKReader

export Data, read_eqdsk, read_format_2000

# Base.@kwdef
"""
    Data

Content structure of EQDSK file.

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
struct Data
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

join_lines_skipping_eols(io) = reduce(*, readlines(io))
read_str(io, nb) = String(Base.read(io, nb))
read_num(::Type{T}, io, nb) where {T <: Number} = parse(T, read_str(io, nb))
read_num(::Type{T}, io, nb, n) where {T <: Number} = (read_num(T, io, nb) for _ in 1:n)
read_floats(io, n) = read_num(Float32, io, 16, n)
read_vector(io, n) = Float32[read_floats(io, n)...]

function read_eqdsk(io)
    s = IOBuffer(join_lines_skipping_eols(io))
    # read (neqdsk,2000) (case(i),i=1,6),idum,nw,nh
    case = read_str(s, 48)
    skip(s, 4)
    nw, nh = read_num(Int16, s, 4, 2) # row 1
    # read (neqdsk,2020) rdim,zdim,rcentr,rleft,zmid
    rdim, zdim, rcentr, rleft, zmid = read_floats(s, 5)  # row 2
    # read (neqdsk,2020) rmaxis,zmaxis,simag,sibry,bcentr
    rmaxis, zmaxis, simag, sibry, bcentr = read_floats(s, 5)  # row 3
    # read (neqdsk,2020) current,simag,xdum,rmaxis,xdum
    current, simag2, _, rmaxis2, _ = read_floats(s, 5)  # row 4
    @assert simag2 == simag
    @assert rmaxis2 == rmaxis
    # read (neqdsk,2020) zmaxis,xdum,sibry,xdum,xdum
    zmaxis2, _, sibry2, _, _ = read_floats(s, 5)  # row 5
    @assert zmaxis2 == zmaxis
    @assert sibry2 == sibry

    # read (neqdsk,2020) (fpol(i),i=1,nw)
    fpol = read_vector(s, nw)
    # read (neqdsk,2020) (pres(i),i=1,nw)
    pres = read_vector(s, nw)
    # read (neqdsk,2020) (ffprim(i),i=1,nw)
    ffprim = read_vector(s, nw)
    # read (neqdsk,2020) (pprime(i),i=1,nw)
    pprime = read_vector(s, nw)
    # read (neqdsk,2020) ((psirz(i,j),i=1,nw),j=1,nh)
    psirz = reshape(read_vector(s, nw * nh), (nw, nh))
    # read (neqdsk,2020) (qpsi(i),i=1,nw)
    qpsi = read_vector(s, nw)
    # read (neqdsk,2022) nbbbs,limitr
    nbbbs, limitr = read_num(Int16, s, 5, 2)
    # read (neqdsk,2020) (rbbbs(i),zbbbs(i),i=1,nbbbs)
    A = read_vector(s, 2 * nbbbs)
    rbbbs = A[1, :]
    zbbbs = A[2, :]
    # read (neqdsk,2020) (rlim(i),zlim(i),i=1,limitr)
    A = read_vector(s, 2 * limitr)
    rlim = A[1, :]
    zlim = A[2, :]

    return EQDSKReader.Data(
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

end
