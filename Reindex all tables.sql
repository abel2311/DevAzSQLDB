Have you re-indexed your database lately?
As our production database gets more and more data in it, we noticed that things were slowing down. I ran SQL Profiler trying to figure out if we needed to ad more indexes, better arrange the data, or anything we could do to improve the performance. After about an hour of running queries, creating indexes, profiling, and looking at execution plans; I had gotten barely anything for performance gains.

I then decided to take a different track and wondered if our indexes needed to be rebuilt.  A quick Google later, and I came across an article on Tips for Rebuilding Indexes over at SQL Server Performance.

The gist of the article is your indexes get fragmented and need to be rebuilt. I ran the script present in the article and noticed a substantial improvement in performance.  I failed to capture metrics to quantify the performance improvements, but the users definitely noticed.

Without further ado, here is the script from the article:

If your using MS SQL Server 2000:

USE DatabaseName --Enter the name of the database you want to reindex

DECLARE @TableName varchar(255)

DECLARE TableCursor CURSOR FOR
SELECT table_name FROM information_schema.tables
WHERE table_type = 'base table'

OPEN TableCursor

FETCH NEXT FROM TableCursor INTO @TableName
WHILE @@FETCH_STATUS = 0
BEGIN
DBCC DBREINDEX(@TableName,' ',90)
FETCH NEXT FROM TableCursor INTO @TableName
END

CLOSE TableCursor

DEALLOCATE TableCursor 
If your using MS SQL Server 2005:
USE DatabaseName --Enter the name of the database you want to reindex

DECLARE @TableName varchar(255)

DECLARE TableCursor CURSOR FOR
SELECT table_name FROM information_schema.tables
WHERE table_type = 'base table'

OPEN TableCursor

FETCH NEXT FROM TableCursor INTO @TableName
WHILE @@FETCH_STATUS = 0
BEGIN
ALTER INDEX ON schema.table REBUILD/REORGANIZE
FETCH NEXT FROM TableCursor INTO @TableName
END

CLOSE TableCursor

DEALLOCATE TableCursor