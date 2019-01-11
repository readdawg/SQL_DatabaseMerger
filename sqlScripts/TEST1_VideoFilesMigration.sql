
--Create FilesCount Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.VideoFiles
ADD FilesCount int;
GO

--Create FilesCount Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.VideoFiles
ADD FilesCount int;
GO

--Create oFileID Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.VideoFiles
ADD oFileID int;
GO

--Create oFileID Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.VideoFiles
ADD oFileID int;
GO

--Create LogCount Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.VideoFilesLog
ADD LogCount int;
GO

--Create LogCount Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.VideoFilesLog
ADD LogCount int;
GO

--Create oLogID Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.VideoFilesLog
ADD oLogID int;
GO

--Create oLogID Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.VideoFilesLog
ADD oLogID int;
GO

USE VMSDatabase
ALTER TABLE dbo.VideoFilesLog
ADD oFileID int;
GO

USE InsightEnt
ALTER TABLE dbo.VideoFilesLog
ADD oFileID int;
GO

-- Copy Door Info From Donor To Gaining If DoorID Not In Gaining Table
USE VMSDatabase
DECLARE @count int = 1
DECLARE @maxID int 

SET @maxID = (SELECT COUNT(*) FROM VMSDatabase.dbo.VideoFiles)

WHILE @count <= @maxID

BEGIN

DECLARE @minID int = (SELECT min(FileID) FROM VMSDatabase.dbo.VideoFiles WHERE FilesCount IS NULL)
DECLARE @filesID nvarchar(50) = (SELECT FileID FROM VMSDatabase.dbo.VideoFiles WHERE FileID = @minID)
DECLARE @serverID nvarchar(50) = (SELECT ServerID FROM VMSDatabase.dbo.VideoFiles WHERE FileID = @minID)

DECLARE @maxFileID nvarchar(50) = (SELECT MAX(FileID) FROM InsightEnt.dbo.VideoFiles)
DECLARE @maxLogID nvarchar(50) = (SELECT MAX(LogID) FROM InsightEnt.dbo.VideoFilesLog)

DECLARE @oldFileID nvarchar(50) = (SELECT MIN(FileID) FROM VMSDatabase.dbo.VideoFiles WHERE FileID = @minID)
DECLARE @oldLogID nvarchar(50) = (SELECT MIN(LogID) FROM VMSDatabase.dbo.VideoFilesLog WHERE FileID = @minID)

DECLARE @newFileID nvarchar(50) = (SELECT MAX(FileID) FROM InsightEnt.dbo.VideoFiles) + 1
DECLARE @newLogID nvarchar(50) = (SELECT MAX(LogID) FROM InsightEnt.dbo.VideoFilesLog) + 1

DECLARE @qCount nvarchar(10) = '1'

DECLARE @sql NVARCHAR(max) = '

				IF NOT EXISTS (SELECT FileID FROM InsightEnt.dbo.VideoFiles WHERE FileID = ' + @filesID + ')
					BEGIN
						
						--Update old File and Log fields
						UPDATE VMSDatabase.dbo.VideoFiles
						SET oFileID = ' + @oldFileID + ' WHERE FileID = ' + @oldFileID + '

						UPDATE VMSDatabase.dbo.VideoFilesLog
						SET oFileID = ' + @oldFileID + ' WHERE FileID = ' + @oldFileID + '

						UPDATE VMSDatabase.dbo.VideoFilesLog
						SET LogID = ' + @oldLogID + ' WHERE LogID = ' + @oldLogID + '

						UPDATE VMSDatabase.dbo.VideoFilesLog
						SET FileID = ' + @newFileID + ' WHERE oFileID = ' + @filesID + '

						UPDATE VMSDatabase.dbo.VideoFilesLog
						SET LogID = ' + @newLogID + ' WHERE  = ' + @oldLogID + '

						--Copy table data from donor to gaining tables
						INSERT INTO InsightEnt.dbo.VideoFiles
						SELECT * FROM VMSDatabase.dbo.VideoFiles
						WHERE VMSDatabase.dbo.VideoFiles.oFileID = ' + @filesID + '

						INSERT INTO InsightEnt.dbo.VideoFilesLog
						SELECT * FROM VMSDatabase.dbo.VideoFilesLog
						WHERE VMSDatabase.dbo.VideoFilesLog.oFileID = ' + @filesID + '

					END				

				ELSE
					BEGIN

						UPDATE VMSDatabase.dbo.VideoFiles
						SET FilesCount = 0 WHERE oFileID = ' + @filesID +'

						UPDATE VMSDatabase.dbo.VideoFilesLog
						SET LogCount = 0 WHERE oFileID = ' + @filesID +'

					END				
				'			

EXECUTE (@sql)

SET @count = @count + 1
SET @filesID = ''
SET @qCount = ''

END

GO