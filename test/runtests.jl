const HERE = dirname(@__FILE__)
insert!(LOAD_PATH, 1, dirname(HERE))

using EQDSKReader
using Test

const INPUT_DATA = joinpath(HERE, "data", "beforeTQ.eqdsk")

function check_before_tq_file(data)
    @test occursin("disr", data.case)
    @test data.nw == 65
    @test data.nh == 129
    @test data.current == 5.0e6
    @test data.fpol[1] == -0.178683326e+02   # Note: compare as Float32, this is not equal to Float64 -0.178683326e+02
    @test data.fpol[end] == -0.172000000e+02
    @test data.pres[1] == 0.506794023e+06
    @test data.pres[end] == 0.655331439e+01
    @test data.ffprim[1] == -0.156641850e+02
    @test data.ffprim[end] == 0.0
    @test data.pprime[1] == -0.674156969e+06
    @test data.pprime[end] == 0.0
    @test size(data.psirz) == (data.nw, data.nh)
    @test data.psirz[1, 1] == -0.988481275
    @test data.psirz[data.nw, 1] == -0.685782937e-01
    @test data.psirz[1, data.nh] == -0.262203469
    @test data.psirz[data.nw, data.nh] == 0.84876222
    @test data.qpsi[1] == 0.889066518
    @test data.qpsi[end] == 0.415200567e+01
    @test data.nbbbs == 89
    @test data.limitr == 59
    # TODO dvp: add other corners
    @test length(data.rbbbs) == data.nbbbs
    @test length(data.zbbbs) == data.nbbbs
    @test length(data.rlim) == data.limitr
    @test length(data.zlim) == data.limitr
    @test data.zlim[end] == -0.68049
    r = rpoints(data)
    @test length(r) == data.nw
    @test eltype(r) == Float64
    z = zpoints(data)
    @test length(z) == data.nh
    @test eltype(z) == Float64
    lbp = lowest_boundary_point(data)
    @test lbp[2] ≈ -0.68 atol=0.01
    @test calc_boundary_psi(data) ≈ -0.54 atol=0.01
    ψ = create_normalized_psi_interpolator(data)
    ataxis = ψ(data.rmaxis, data.zmaxis)
    @test ataxis == 0.0
    onboundary = [ψ(r,z) for (r,z) in zip(data.rbbbs, data.zbbbs)]
    maxdiff_onboundary = maximum(abs.(onboundary .- 1.0))
    @test maxdiff_onboundary <= 4e-5
    sepz = psi_separation_z(data)
    @test sepz < lbp[2]
    @test in_plasma(ψ, data.rmaxis, data.zmaxis, sepz)
    @test !in_plasma(ψ, r[end], z[end], sepz)
    @test !in_plasma(ψ, r, sepz-0.01, sepz)
    close_to_boundary = 0.99*hcat(data.rbbbs, data.zbbbs) .+ 0.01*[data.rmaxis data.zmaxis]
    @test all(in_plasma(ψ, close_to_boundary[i,1], close_to_boundary[i,2], sepz) for i in 1:length(data.rbbbs))
    rarry = LinRange(data.rmaxis - 0.5, data.rmaxis - 0.5, 10)
    zarry = LinRange(data.zmaxis - 0.5, data.zmaxis - 0.5, 10)
    @test in_plasma(ψ, rarry, zarry, sepz)
end


@testset "Building from path and stream" begin
    data = Content(INPUT_DATA)
    check_before_tq_file(data)
    open(INPUT_DATA) do io
        data2 = Content(io)
        @test hash(data) == hash(data2)
        @test data == data2
        @test isequal(data, data2)
        @test data ≈ data2
    end
end


nothing
