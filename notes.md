```
VACUUM ANALYZE
```

plan nodes

There are different types of scan nodes for different table access methods: sequential scans, index scans, and bitmap index scans.

There are also non-table row sources

If the query requires joining, aggregation, sorting, or other operations on the raw rows, then there will be additional nodes above the scan nodes to perform these operations.

nodes at the bottom level are scan nodes

**seq scan**

Scan of Entire Table: PostgreSQL reads every row of the table from start to finish.
No Index Utilization: It doesn't utilize any indexes on the table.
Full Table Read: This method reads every block of data in the table, even if the required rows are found earlier in the scan.
Performance Impact: It might be slower compared to other methods, especially on larger tables, because it reads all rows regardless of meeting the query's conditions early in the process.
