module Amb

export @amb, require, ambrun, @ambrun, ambiter

function _amb end

# more warning
macro amb(state, expr...)
    :(_amb($(esc(state)), $(map(x-> esc(:(($state) -> $x)), expr)...)))
end

struct RunState
    path::Vector{Int}
    cursor::Base.RefValue{Int}
end

struct Escape end

ambrun(f) = ambrun(RunState([], Ref(0)), f)
function ambrun(state, f)
    @label beginning
    try
        return f(state)
    catch err
        if err isa Escape
            # no more branches down here, also we've exhausted this amb
            # back up
            resize!(state.path, length(state.path)-1)
            if isempty(state.path)
                return nothing
            end
            state.path[end] += 1
            state.cursor[] = 0
            # repeat
            @goto beginning
        else
            rethrow(err)
        end
    end
end

macro ambrun(st, expr)
    @assert st isa Symbol
    :(ambrun(esc(:(($st)->$(expr)))), $(esc(st)))
end

ambiter(f) = ambiter(RunState([], Ref(0)), f)
function ambiter(state, f)
    Channel() do c
        ambrun(state, state-> begin
            put!(c, f(state))
            @amb state
        end)
    end
end

function _amb(state, args...)
    i = (state.cursor[] += 1)
    if i > length(state.path)
        push!(state.path, 1) # discovered a new @amb
        @assert i == length(state.path)
    end

    if state.path[i] > length(args)
        throw(Escape())
    end

    args[state.path[i]](state)
end

require(state, cond) = cond ? nothing : @amb(state)

end # module
