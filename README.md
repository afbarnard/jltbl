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
* table size is known at all times and so is constant time to query
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
