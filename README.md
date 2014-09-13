JlTbl
=====

JlTbl is a column-store table data structure and accessories written in
Julia.  It is designed and optimized for data analysis but can also be
used for data processing and transformation.  It is intended for
single-machine in-memory use but does not preclude permanent-storage
realizations nor use as a building block in distributed storage and
processing.


Goals and Features
------------------

* designed and optimized for reading, querying, and bulk loading
* supports all relational table operations and queries, including
  multi-table queries
* size is known at all times and so is constant time to query
* lightweight dynamic views that can be materialized as new tables
* dynamic views can be used to modify the underlying table and reflect
  underlying modifications
* read-only views
* tables and views share the same core API
* convertable to a matrix (or a matrix view)
* in-memory implementation but API design does not preclude a permanent
  storage implementation
* supports random access of rows, columns, and cells (values)
* columns can store:
  * any of the core data types, or arrays, or objects
  * homogeneous values or a mix of sub-types
  * sets or enumerations of values
  * null
* columns can be indexed (and compressed?)
* both lightweight rows for reading and instantiated rows for streaming
  data processing
* table-level concurrency control that permits many concurrent readers
  but writers are serialized; appends can coexist with reads, but other
  writes are exclusive
* extent-based storage and allocation so that resizing does not need
  copying
* reading and writing a number of external file formats (CSV, YAML,
  ARFF, Prolog)
* tables can be grown by
  * appending columns
  * appending rows


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


License
-------

JlTbl is free, open source software.  It is released under the MIT
License.  See the file `LICENSE` for details.


Contact
-------

Contact for this software is handled through GitHub.  Start by checking
to see if there are any [relevant
issues](https://github.com/afbarnard/jltbl/issues?q=is%3Aissue).  Then
[open a new issue](https://github.com/afbarnard/jltbl/issues/new) to
report a bug or ask a new question.


Copyright (c) 2014 Aubrey Barnard.  This is free software.  See LICENSE
for details.
