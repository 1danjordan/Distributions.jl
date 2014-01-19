
immutable AliasTable <: AbstractCategoricalSampler
    accept::Vector{Float64}
    alias::Vector{Int}
    isampler::RandIntSampler
end

function AliasTable(probs)

    n = length(probs)
    accept = float64(probs*n)

    alias = Array(Int,n)
    larges = Array(Int,0)
    smalls = Array(Int,0)

    for i = 1:n
        acci = accept[i] 
        if acci > 1.0 
            push!(larges,i)
        elseif acci < 1.0
            push!(smalls,i)
        end
    end
    while !isempty(larges) && !isempty(smalls)
        s = pop!(smalls)
        l = pop!(larges)
        alias[s] = l
        accept[l] = (accept[l] - 1.0) + accept[s]
        if accept[l] > 1
            push!(larges,l)
        else
            push!(smalls,l)
        end
    end

    # this loop should be redundant, except for rounding
    for s = smalls
        accept[s] = 1.0
    end

    AliasTable(accept, alias, RandIntSampler(n))
end

function rand(a::AliasTable)
    i = rand(a.isampler)
    u = rand()
    u < a.accept[i] ? i : a.alias[i]
end

Base.show(io::IO, a::AliasTable) = @printf io "AliasTable with %d entries" length(a.accept)
