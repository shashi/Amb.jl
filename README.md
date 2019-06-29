# Amb

Exploratory execution with the [`amb` operator](http://community.schemewiki.org/?amb).

## Usage

### `amb(options...)`

```julia
x = amb(1,2,3)

f(x)
```

This piece of code says that `x` is either 1, 2, or 3. `f` can decide to admit a value or not using `require`. In effect you can think of this as calling `f` with a value appropriate for `f` as decided by `f`.

### `require(condition)`

Require a certain condition to be true, if not, backtrack and try the next available set of assignments to `amb` variables.

`require` is implemented as: `require(cond) = !cond ? amb() : nothing`

**Example: Pythagorean triples**

```julia
julia> intbetween(lo, hi) = amb(lo:hi...)

julia> function a_pythagoras_triple(lo, hi)
           i = intbetween(lo, hi)
           j = intbetween(i, hi)
           k = intbetween(j, hi)

           require(i*i + j*j == k*k)
           return (i, j, k)
       end

```

### `ambrun(f)`

Runs a zero-argument function `f` in the amb-world, where the language knows that it needs to search for a set of assignments to amb variables that runs the code till the end without rejection. If no such path is found, ambrun returns nothing.

In other words, `ambrun` computes one admissible return value of the function passed to it.

```julia
julia> ambrun(()->a_pythagoras_triple(1, 20))
(3, 4, 5)
```

### `ambiter(f)`

return a Channel which gives back `f()` for all admissible assignments. `collect` on gives an array of all possible answers.

```julia
julia> collect(ambiter(()->a_pythagoras_triple(1, 20)))
6-element Array{Any,1}:
 (3, 4, 5)
 (5, 12, 13)
 (6, 8, 10)
 (8, 15, 17)
 (9, 12, 15)
 (12, 16, 20)
```

## Caveats

- recursive `amb` construction is kinda broken.

```julia
intbetween(lo, hi) = (require(lo < hi); amb(lo, amb(lo+1, hi)))
```

does not work -- it fails at the `amb()` in the base case.

```julia
intbetween(lo, hi) = (lo == hi ? hi : amb(lo, intbetween(lo+1, hi)))
```

works, but generates 38 values (20 values and a lots of 1s).

- ambrun doesn't really backtrack in the sense that it goes back to where the last amb assignment changed, instead it runs the whole function again chosing the same values as before until the last amb. It does more work than a backtracking algorithm.

continuations would be a beautiful way to solve these problems.

---
Thanks to Prof. Jerry Sussman for introducing us to `amb` in [6.945](https://groups.csail.mit.edu/mac/users/gjs/6.945/). Thanks to Jarrett Revels for writing Cassette!
