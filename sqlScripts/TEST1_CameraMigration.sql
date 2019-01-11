
--Create CameraCount Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.Cameras
ADD CameraCount int;
GO

--Create CameraCount Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.Cameras
ADD CameraCount int;
GO

-- Copy From Camera Info From Donor To Gaining If CameraID Not In Gaining Table
USE VMSDatabase
DECLARE @count int = 1
DECLARE @maxID int 

SET @maxID = (SELECT COUNT(*) FROM VMSDatabase.dbo.Cameras)

WHILE @count <= @maxID

BEGIN

DECLARE @minID int = (SELECT min(CameraID) FROM VMSDatabase.dbo.Cameras WHERE CameraCount IS NULL)
DECLARE @cameraID nvarchar(10) = (SELECT cameraID FROM VMSDatabase.dbo.Cameras WHERE CameraID = @minID)
DECLARE @minCamID nvarchar(10) = @minID
DECLARE @qCount nvarchar(10) = '1'

DECLARE @sql NVARCHAR(max) = '

				IF NOT EXISTS (SELECT CameraID FROM InsightEnt.dbo.Cameras WHERE CameraID = ' + @cameraID + ')
					BEGIN						
						INSERT INTO InsightEnt.dbo.Cameras
						SELECT * FROM VMSDatabase.dbo.Cameras
						WHERE VMSDatabase.dbo.Cameras.CameraID = ' + @cameraID + '

						UPDATE VMSDatabase.dbo.Cameras
						SET CameraCount = 1 WHERE CameraID = ' + @cameraID +'
					END				

				ELSE
					BEGIN
						UPDATE VMSDatabase.dbo.Cameras
						SET CameraCount = 0 WHERE CameraID = ' + @cameraID +'
					END				
				'			

EXECUTE (@sql)

SET @count = @count + 1
SET @minID = ''
SET @cameraID = ''
SET @qCount = ''

END

GO