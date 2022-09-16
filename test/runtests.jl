using EQDSKReader
using Test

const HERE = dirname(@__FILE__)
const INPUT_DATA = joinpath(HERE, "data", "beforeTQ.eqdsk")

function check_before_tq_file(data)
    @test occursin("disr", data.case)
    @test data.nw == 65
    @test data.nh == 129
    @test data.current == 5.0f6
    @test data.fpol[1] == -0.178683326f+02   # Note: compare as Float32, this is not equal to Float64 -0.178683326e+02
    @test data.fpol[end] == -0.172000000f+02
    @test data.pres[1] == 0.506794023f+06
    @test data.pres[end] == 0.655331439f+01
    @test data.ffprim[1] == -0.156641850f+02
    @test data.ffprim[end] == 0.0
    @test data.pprime[1] == -0.674156969f+06
    @test data.pprime[end] == 0.0
    @test size(data.psirz) == (data.nw, data.nh)
    @test data.psirz[1, 1] == -0.988481275f+00
    @test data.psirz[data.nw, 1] == -0.685782937f-01
    @test data.psirz[1, data.nh] == -0.262203469f+00
    @test data.psirz[data.nw, data.nh] == 0.848762220f+00
    @test data.qpsi[1] == 0.889066518f+00
    @test data.qpsi[end] == 0.415200567f+01
    @test data.nbbbs == 89
    @test data.limitr == 59
    # TODO dvp: add other corners
    @test data.zlim[end] == -0.680490000f+00
end


@testset "Building from path and stream" begin
    data = Content(INPUT_DATA)
    check_before_tq_file(data)
    open(INPUT_DATA) do io
        data2 = Content(io)
        # @test data == data2  
    end
end

# @testset "Building from stream" begin
#     open(INPUT_DATA) do io
#         check_before_tq_file(Content(io))
#     end
# end

nothing