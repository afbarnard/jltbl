# Copyright (c) 2014 Aubrey Barnard.  This is free software.  See
# LICENSE for details.

# A mapping between names and columns.

module jltbl

import Base: length

# TODO symbols or strings or both?
# TODO generalize type to a mapping between T and Int? yes, also works for storing categorical values and ordinals

type Header
    namesToIndices::Dict{Symbol,Int}
    indicesToNames::Vector{Symbol}
end

Header() = Header(Dict{Symbol,Int}(), Array(Symbol, 0))

length(h::Header) = length(h.indicesToNames)

function addColumn!(h::Header, name::Symbol)
    append!(h.indicesToNames, [name])
    h.namesToIndices[name] = length(h.indicesToNames)
    return h
end
addColumn!(h::Header, name::String) = addColumn!(h, symbol(name))

columnIndex(h::Header, name::Symbol) = h.namesToIndices[name]
columnIndex(h::Header, name::String) = columnIndex(h, symbol(name))

columnName(h::Header, index::Int) = h.indicesToNames[index]

end # module jltbl
