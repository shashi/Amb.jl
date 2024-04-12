# Amb

Nondeterminism operator. "[Amb](http://community.schemewiki.org/?amb)" as in "it's *amb*iguous which value this should be at this point, but it's one of these."

## Usage

### `@amb(state, options...)`

```julia
x = @amb state 1 2 3
```
`x` is an Integer, specifically either 1, 2, or 3. Which one depends on what the program does next! `require(state, isodd(x))` will make it be either `1`, or `3`.

### `require(state, condition)`

Require a certain condition to be true, if not, backtrack and try the next available set of assignments to `@amb` variables seen so far.

`require` is implemented as: `require(state, cond) = !cond ? @amb(state) : nothing`

**Example: Pythagorean triples**

```julia
julia> function int_between(state, lo, hi)
           require(state, lo <= hi)
           @amb lo int_between(state, lo+1, hi)
       end

julia> function a_pythagoras_triple(state, lo, hi)
           i = int_between(state, lo, hi)
           j = int_between(state, i, hi)
           k = int_between(state, j, hi)

           require(state, i*i + j*j == k*k)
           return (i, j, k)
       end

```

### `ambrun(f)`

Runs a zero-argument function `f` in the amb-world, where the language knows that it needs to search for a set of assignments to `@amb` variables that runs the code till the end without rejection. If no such path is found, ambrun returns nothing.

In other words, `ambrun` computes one admissible return value of the function passed to it.

```julia
julia> ambrun((state)->a_pythagoras_triple(state, 1, 20))
(3, 4, 5)
```

### `ambiter(f)`

return a Channel which gives back `f()` for all admissible assignments. `collect` on gives an array of all possible answers.

```julia
julia> collect(ambiter((state)->a_pythagoras_triple(state, 1, 20)))
6-element Array{Any,1}:
 (3, 4, 5)
 (5, 12, 13)
 (6, 8, 10)
 (8, 15, 17)
 (9, 12, 15)
 (12, 16, 20)
```

---
Thanks to Prof. Jerry Sussman for introducing us to `amb` in [6.945](https://groups.csail.mit.edu/mac/users/gjs/6.945/). Thanks to Jarrett Revels for writing Cassette!
