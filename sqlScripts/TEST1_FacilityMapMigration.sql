
--Create RuleCount Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.FM_FacilityMap
ADD MapCount int;
GO

--Create RuleCount Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.FM_FacilityMap
ADD MapCount int;
GO

-- Copy From Rule, Action, Condition, and Schedule Info From Donor To Gaining If TaskID Not In Gaining Table
USE VMSDatabase
DECLARE @count int = 1
DECLARE @maxID int 

SET @maxID = (SELECT COUNT(*) FROM VMSDatabase.dbo.FM_FacilityMap)

WHILE @count <= @maxID

BEGIN

DECLARE @minID int = (SELECT min(FaciMapID) FROM VMSDatabase.dbo.FM_FacilityMap WHERE MapCount IS NULL)
DECLARE @mapID nvarchar(50) = (SELECT FaciMapID FROM VMSDatabase.dbo.FM_FacilityMap WHERE FaciMapID = @minID)
DECLARE @qCount nvarchar(10) = '1'

DECLARE @sql NVARCHAR(max) = '

				IF NOT EXISTS (SELECT FaciMapID FROM InsightEnt.dbo.FM_FacilityMap WHERE FaciMapID = ' + @mapID + ')
					BEGIN						
						INSERT INTO InsightEnt.dbo.FM_FacilityMap
						SELECT * FROM VMSDatabase.dbo.FM_FacilityMap
						WHERE VMSDatabase.dbo.FM_FacilityMap.FaciMapID = ' + @mapID + '

						INSERT INTO InsightEnt.dbo.FM_FacilityMapItems
						SELECT * FROM VMSDatabase.dbo.FM_FacilityMapItems
						WHERE VMSDatabase.dbo.FM_FacilityMapItems.FaciMapID = ' + @mapID + '

						UPDATE VMSDatabase.dbo.FM_FacilityMap
						SET MapCount = 1 WHERE FaciMapID = ' + @mapID +'
					END				

				ELSE
					BEGIN
						UPDATE VMSDatabase.dbo.FM_FacilityMap
						SET MapCount = 0 WHERE FaciMapID = ' + @mapID +'
					END				
				'			

EXECUTE (@sql)

SET @count = @count + 1
SET @mapID = ''
SET @qCount = ''

END

GO