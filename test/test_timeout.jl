include("prelude.jl")

@testset "functions" begin
    interact(`cat`, 1) do proc
        # Check that all reading function emit an ExpectTimeout exception
        @test_throws ExpectTimeout read(proc, UInt8)
        @test_throws ExpectTimeout readbytes!(proc, Vector{UInt8}(undef, 1))
        @test_throws ExpectTimeout readuntil(proc, '\n')
        @test_throws ExpectTimeout Base.wait_readnb(proc, 1)
        if VERSION ≤ v"1.3.0-rc1.0"
            @test_throws ExpectTimeout Base.wait_readbyte(proc, UInt8('\n'))
        else
            @test_throws ExpectTimeout Base.wait_close(proc)
        end
        @test_throws ExpectTimeout read(proc, String)
        @test_throws ExpectTimeout readline(proc)
        @test process_running(proc)
    end
end

@testset "with_timeout!" begin
    interact(`sh -c 'sleep 5 && echo test'`, 1) do proc
        @test_throws ExpectTimeout expect!(proc, "test")
        with_timeout!(proc, 5) do
            @test expect!(proc, "test") == ""
        end
    end
end

@testset "inf_timeout" begin
    interact(`sh -c 'sleep 5 && echo test'`, Inf) do proc
        @test expect!(proc, "test") == ""
    end
end
