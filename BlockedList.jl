# Copyright (c) 2014 Aubrey Barnard.  This is free software.  See
# LICENSE for details.

# List with block-based storage that supports random access.  The
# benefits are that allocation and deallocation do not require copying
# and that at most a constant amount of memory is unused (the block
# size).  The costs are an extra level of indirection for access and
# potentially more allocations (although no copies) for a given data
# size.

module jltbl

import Base: length, size, getindex, setindex!, append!, start, next, done

# Constants

const _defaultBlockSize = 1024
const _defaultTopLevelCapacity = 16

# BlockedList
type BlockedList{T} <: AbstractVector{T}
    blockSize::Int
    blocks::Vector{Vector{T}} # The top-level array is pointer-based
    blocksLength::Int # Number of valid top-level elements
    length::Int # Total number of valid elements

    function BlockedList(blockSize::Int, blocks::Vector{Vector{T}})
        # Check for valid arguments
        blockSize > 0 || error("Block size not positive: $(blockSize)")
        # Construct
        return new(blockSize, blocks, 0, 0)
    end
end

# Constructors

BlockedList{T}(eltype::Type{T}) = BlockedList(eltype, _defaultBlockSize)
BlockedList{T}(eltype::Type{T}, blockSize::Int) = BlockedList{T}(blockSize, Array(Vector{T}, _defaultTopLevelCapacity))
BlockedList{T}(blockSize::Int, blocks::Vector{Vector{T}}) = BlockedList{T}(blockSize, blocks)

# Length, size, capacity

length(list::BlockedList) = list.length

size(list::BlockedList) = (list.length,)

capacity(list::BlockedList) = list.blocksLength * list.blockSize

# Element access

function getindex(list::BlockedList, index::Int)
    checkbounds(list.length, index)
    index, subindex = divrem(index - 1, list.blockSize)
    return list.blocks[index + 1][subindex + 1]
end

function setindex!{T}(list::BlockedList{T}, value::T, index::Int)
    checkbounds(list.length, index)
    return _setindex!(list, value, index)
end

function _setindex!{T}(list::BlockedList{T}, value::T, index::Int)
    index, subindex = divrem(index - 1, list.blockSize)
    list.blocks[index + 1][subindex + 1] = value
    return list
end

# Appending

function ensureCapacity!{T}(list::BlockedList{T}, newCapacity::Int)
    # How many blocks are needed for the new capacity?
    newBlocksLength = iceil(newCapacity / list.blockSize)
    blocksCapacity = length(list.blocks)
    # Allocate top level as needed
    newBlocksCapacity = blocksCapacity
    while newBlocksCapacity < newBlocksLength
        newBlocksCapacity *= 2
    end
    if newBlocksCapacity > blocksCapacity
        resize!(list.blocks, newBlocksCapacity)
    end
    # Allocate blocks as needed
    while list.blocksLength < newBlocksLength
        list.blocksLength += 1
        list.blocks[list.blocksLength] = Array(T, list.blockSize)
    end
    return list
end

# Append like in the standard library, where the number of new elements
# is known
function append!{T}(list::BlockedList{T}, items::AbstractVector{T})
    numberItems = length(items)
    ensureCapacity!(list, list.length + numberItems)
    for index in 1:numberItems
        _setindex!(list, items[index], list.length + index)
    end
    list.length += numberItems
    return list
end

# Append like in the standard library, where the number of new elements
# is not known
function append!{T}(list::BlockedList{T}, items) # TODO items::Iterable
    baseIndex = list.length
    cap = capacity(list)
    index = 1
    for (index, item) in enumerate(items) # TODO start index at baseIndex
        # Check the type of the item
        typeof(item) == T || error("Wrong element type: $(typeof(item)) is not $(T): $(item)")
        # Add capacity for this item if needed
        if baseIndex + index > cap
            ensureCapacity!(list, baseIndex + index)
            cap = capacity(list)
        end
        _setindex!(list, item, baseIndex + index)
    end
    list.length += index
    return list
end

# Append like in Go
function append!{T}(list::BlockedList{T}, items::T...)
    return append!(list, items)
end

# Iteration

start(list::BlockedList) = Int[1, 1]

function next(list::BlockedList, state)
    # Get the next item
    item = list.blocks[state[1]][state[2]]
    # Advance the indices
    state[2] += 1
    if state[2] > list.blockSize
        state[1] += 1
        state[2] = 1
    end
    return (item, state)
end

function done(list::BlockedList, state)
    lastLength = (list.length - 1) % list.blockSize + 1
    return (state[1] > list.blocksLength ||
        (state[1] == list.blocksLength && state[2] > lastLength))
end

# TODO implement the following functions:
# deleteat! (2 variants) (?)
# splice! (2 variants) (?)
# insert! (?)

end # module jltbl
