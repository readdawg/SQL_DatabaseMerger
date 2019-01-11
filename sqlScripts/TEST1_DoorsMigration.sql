
--Create DoorCount Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.Door
ADD DoorCount int;
GO

--Create DoorCount Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.Door
ADD DoorCount int;
GO

-- Copy Door Info From Donor To Gaining If DoorID Not In Gaining Table
USE VMSDatabase
DECLARE @count int = 1
DECLARE @maxID int 

SET @maxID = (SELECT COUNT(*) FROM VMSDatabase.dbo.Door)

WHILE @count <= @maxID

BEGIN

DECLARE @minID int = (SELECT min(DoorID) FROM VMSDatabase.dbo.Door WHERE DoorCount IS NULL)
DECLARE @doorID nvarchar(50) = (SELECT DoorID FROM VMSDatabase.dbo.Door WHERE DoorID = @minID)
DECLARE @qCount nvarchar(10) = '1'

DECLARE @sql NVARCHAR(max) = '

				IF NOT EXISTS (SELECT LayoutID FROM InsightEnt.dbo.Door WHERE DoorID = ' + @doorID + ')
					BEGIN						
						INSERT INTO InsightEnt.dbo.Door
						SELECT * FROM VMSDatabase.dbo.Door
						WHERE VMSDatabase.dbo.Door.DoorID = ' + @doorID + '
						
						UPDATE VMSDatabase.dbo.Door
						SET DoorCount = 1 WHERE DoorID = ' + @doorID +'
					END				

				ELSE
					BEGIN
						UPDATE VMSDatabase.dbo.Door
						SET DoorCount = 0 WHERE DoorID = ' + @doorID +'
					END				
				'			

EXECUTE (@sql)

SET @count = @count + 1
SET @doorID = ''
SET @qCount = ''

END

GO