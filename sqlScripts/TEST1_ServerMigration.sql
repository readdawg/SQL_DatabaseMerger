
--Create CameraCount Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.Servers
ADD ServerCount int;
GO

--Create CameraCount Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.Servers
ADD ServerCount int;
GO

-- Copy From Camera Info From Donor To Gaining If CameraID Not In Gaining Table
USE VMSDatabase
DECLARE @count int = 1
DECLARE @maxID int 

SET @maxID = (SELECT COUNT(*) FROM VMSDatabase.dbo.Servers)

WHILE @count <= @maxID

BEGIN

DECLARE @minID int = (SELECT min(ServerID) FROM VMSDatabase.dbo.Servers WHERE ServerCount IS NULL)
DECLARE @serverID nvarchar(10) = (SELECT ServerID FROM VMSDatabase.dbo.Servers WHERE ServerID = @minID)
DECLARE @minCamID nvarchar(10) = @minID
DECLARE @qCount nvarchar(10) = '1'

DECLARE @sql NVARCHAR(max) = '

				IF NOT EXISTS (SELECT ServerID FROM InsightEnt.dbo.Servers WHERE ServerID = ' + @serverID + ')
					BEGIN						
						INSERT INTO InsightEnt.dbo.Servers
						SELECT * FROM VMSDatabase.dbo.Servers
						WHERE VMSDatabase.dbo.Servers.ServerID = ' + @serverID + '

						UPDATE VMSDatabase.dbo.Servers
						SET ServerCount = 1 WHERE ServerID = ' + @serverID +'
					END				

				ELSE
					BEGIN
						UPDATE VMSDatabase.dbo.Servers
						SET ServerCount = 0 WHERE ServerID = ' + @serverID +'
					END				
				'			

EXECUTE (@sql)

SET @count = @count + 1
SET @minID = ''
SET @serverID = ''
SET @qCount = ''

END

GO