# Copyright (c) 2014 Aubrey Barnard.  This is free software.  See
# LICENSE for details.

# A table.

module jltbl

import Base: length, size

type Table
    header::Header
    columns::Vector{Column}
end

end # module jltbl
