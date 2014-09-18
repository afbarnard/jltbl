Design and Implementation
=========================


Implementation
--------------

* rows are deleted by marking them in a bit array so that data is not
  moved and row indices are preserved (which preserves views)
* tables can be compacted which removes deleted rows and consolidates
  storage and results in a new storage version
* column deletion is immediate (not virtual via bit array) and results
  in a new storage version
* row and column appends do not result in a new storage version
* a new storage version invalidates views; their contents must then be
  regenerated
* null values are tracked with a bit array rather than using the extra
  storage inherent in a nullable type (which is typically implemented
  either via reference or extra bit(s))
* reads can coexist with appends because they will store the current
  maximum row index when started; table size won't be updated until
  append transaction completes (which must wait for existing readers to
  finish)


Design
------

* single-table queries
  * select
  * project
  * sort
  * group by (with standard and user-defined aggregates)
  * update
  * delete
  * partition by?

* two-table methods
  * join
    * inner/natural
    * Cartesian product
    * outer?
  * stack/append
  * set operations
    * union
    * intersect
    * difference
    * symmetric difference?

* header fields
  * list of column names
  * mapping of column names to column indices
* header methods
  * number of columns
  * column names
  * column index for name

* table fields
  * header reference
  * list of columns accessible by index
  * count of rows
  * storage version number
  * bit array for valid rows
  * lock(s) for concurrency control
* table methods
  * perform query (either read or write)
  * size
  * get column (by index or name)
  * get row (by index)
  * get value (cell) (by index) (with default value if null)
  * set value (cell) (by index)
  * append row
  * append column
  * bulk append rows
  * rename column

* column fields
  * count of rows
  * list of extents (fixed-size arrays)
  * type information
  * bit array for null values (if column is nullable)
  * index (if indexed)
* column methods
  * size
  * get value (by index) (with default value if null)
  * convert between nullable and non-nullable columns (using default
    value in place of previous nulls)

* view fields
  * header reference
  * table reference
  * list of column indices (which maps view column indices to table
    column indices)
  * list of row indices
  * query reference (for regenerating the contents of the view)
    (presence can indicate intention to regenerate or fail when
    encountering a new storage version)
* view methods
  * same as for table
  * regenerate contents
* read-only view methods are a subset of regular view methods

* view row fields
  * view reference
  * row index
* material row fields
  * header reference
  * list of values
* row methods
  * size
  * get value (by index or name)
  * get value of a particular type (by index or name)


Issues
------

* how handle computed results, e.g. result of a group by or a column
  function? mix of referenced and actual columns? as a table or as a
  view?
* relatedly, how handle join results? learn about binary association
  table algebra?


Copyright (c) 2014 Aubrey Barnard.  This is free software.  See LICENSE
for details.
