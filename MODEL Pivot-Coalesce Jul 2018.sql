
--1) Unique Names

select Distinct U.FullName
From DimUser U
Where U.DisabledDate is Null
and U.FullName like 'M%'


--2) Create Column LIst
DECLARE @Columns as VARCHAR(MAX)
SELECT @Columns =
COALESCE(@Columns + ', ','') + QUOTENAME(FullName)
FROM
   (SELECT DISTINCT U.FullName
    FROM   DimUser U
   ) AS B
   Where FullName like 'M%'
ORDER BY FullName

--3) Construct a pivot table

DECLARE @SQL as VARCHAR(MAX)
SET @SQL = 'SELECT ' + @Columns + '
FROM
(
 SELECT U.Fullname
 FROM   DimUser U
 ) as PivotData
PIVOT
(
   COUNT(FullName)
   FOR FullName IN (' + @Columns + ')
 ) AS PivotResult
'

Exec(@Sql)

