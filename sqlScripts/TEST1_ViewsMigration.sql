
--Create ViewCount Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.Layout
ADD ViewCount int;
GO

--Create ViewCount Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.Layout
ADD ViewCount int;
GO

-- Copy From Layout, LayoutGroups, and LayoutMapping Info From Donor To Gaining If LayoutID Not In Gaining Table
USE VMSDatabase
DECLARE @count int = 1
DECLARE @maxID int 

SET @maxID = (SELECT COUNT(*) FROM VMSDatabase.dbo.Layout)

WHILE @count <= @maxID

BEGIN

DECLARE @minID int = (SELECT min(LayoutID) FROM VMSDatabase.dbo.Layout WHERE ViewCount IS NULL)
DECLARE @viewID nvarchar(50) = (SELECT LayoutID FROM VMSDatabase.dbo.Layout WHERE LayoutID = @minID)
DECLARE @qCount nvarchar(10) = '1'

DECLARE @sql NVARCHAR(max) = '

				IF NOT EXISTS (SELECT LayoutID FROM InsightEnt.dbo.Layout WHERE LayoutID = ' + @viewID + ')
					BEGIN						
						INSERT INTO InsightEnt.dbo.Layout
						SELECT * FROM VMSDatabase.dbo.Layout
						WHERE VMSDatabase.dbo.Layout.LayoutID = ' + @viewID + '

						/*
						INSERT INTO InsightEnt.dbo.LayoutGroups
						SELECT * FROM VMSDatabase.dbo.LayoutGroups
						WHERE VMSDatabase.dbo.LayoutGroups.LayoutID = ' + @viewID + '

						INSERT INTO InsightEnt.dbo.LayoutMapping
						SELECT * FROM VMSDatabase.dbo.LayoutMapping
						WHERE VMSDatabase.dbo.LayoutMapping.LayoutID = ' + @viewID + '
						*/

						UPDATE VMSDatabase.dbo.Layout
						SET ViewCount = 1 WHERE LayoutID = ' + @viewID +'
					END				

				ELSE
					BEGIN
						UPDATE VMSDatabase.dbo.Layout
						SET ViewCount = 0 WHERE LayoutID = ' + @viewID +'
					END				
				'			

EXECUTE (@sql)

SET @count = @count + 1
SET @viewID = ''
SET @qCount = ''

END

GO