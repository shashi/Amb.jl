using Amb
using Test

@testset "Pythagorean triples" begin
    intbetween(st, lo, hi) = (require(st, lo <= hi); @amb st lo intbetween(st, lo+1, hi))

    function triple(st, lo, hi)
        i = intbetween(st, lo, hi)
        j = intbetween(st, i, hi)
        k = intbetween(st, j, hi)
        require(st, i*i + j*j == k*k)
        (i, j, k)
    end
    @test collect(ambiter((st)->triple(st, 1,20))) == [(3, 4, 5), (5, 12, 13),
                                                 (6, 8, 10), (8, 15, 17),
                                                 (9, 12, 15), (12, 16, 20)]
end
