module Amb

export amb, require, ambrun, ambiter

using Cassette
using Distributed

function amb end

Cassette.@context AmbCtx

struct RunState
    f::Any
    path::Vector{Int}
    cursor::Base.RefValue{Int}
end


# 'Error' types:

struct Escaped{T}
    val::T
end

struct Exhausted end

function ambrun(f, ctx = AmbCtx(metadata=RunState(f, [], Ref(0))))
    try
        Cassette.overdub(ctx, f)
    catch err
        if err isa Escaped
            return err.val
        elseif err isa Exhausted
            return nothing
        else
            rethrow(err)
        end
    end
end

function ambiter(f)
    Channel() do c
        ambrun() do
            put!(c, f())
            amb()
        end
    end
end

function Cassette.overdub(ctx::AmbCtx, ::typeof(amb), args...)
    state = ctx.metadata
    i = (state.cursor[] += 1)
    if i > length(state.path)
        push!(state.path, 1)
        @assert i == length(state.path)
    end

    if state.path[i] > length(args)
        if i == 1
            throw(Exhausted()) # came back all the way up
        end
        # no more branches down here, also we've exhausted this amb
        resize!(state.path, i-1)
        state.path[end] += 1
        state.cursor[] = 0
        # repeat
        val = ambrun(state.f, ctx)
        throw(Escaped(val))
    end
    args[state.path[i]]
end

require(cond) = cond ? nothing : amb()

end # module
