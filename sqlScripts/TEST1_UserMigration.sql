/*
--Create CameraCount Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.UM_Users
ADD UserCount int;
GO

--Create CameraCount Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.UM_Users
ADD UserCount int;
GO
*/


-- Copy From Camera Info From Donor To Gaining If CameraID Not In Gaining Table
USE VMSDatabase
DECLARE @count int = 1
DECLARE @maxID int 

SET @maxID = (SELECT COUNT(*) FROM VMSDatabase.dbo.UM_Users)

WHILE @count <= @maxID

BEGIN

DECLARE @minID bigint = (SELECT min(UserID) FROM VMSDatabase.dbo.UM_Users WHERE UserCount IS NULL)
DECLARE @userID nvarchar(50) = (SELECT UserID FROM VMSDatabase.dbo.UM_Users WHERE UserID = @minID)
--DECLARE @minCamID nvarchar(10) = @minID
DECLARE @qCount nvarchar(10) = '1'

DECLARE @sql NVARCHAR(max) = '

				IF NOT EXISTS (SELECT UserID FROM InsightEnt.dbo.UM_Users WHERE UserID = ' + @userID + ')
					BEGIN						
						INSERT INTO InsightEnt.dbo.UM_Users
						SELECT * FROM VMSDatabase.dbo.UM_Users
						WHERE VMSDatabase.dbo.UM_Users.UserID = ' + @userID + '

						INSERT INTO InsightEnt.dbo.UM_Permissions
						SELECT * FROM VMSDatabase.dbo.UM_Permissions
						WHERE VMSDatabase.dbo.UM_Permissions.UserOrGroup_ID = ' + @userID + '

						UPDATE VMSDatabase.dbo.UM_Users
						SET UserCount = 1 WHERE UserID = ' + @userID +'
					END				

				ELSE
					BEGIN
						UPDATE VMSDatabase.dbo.UM_Users
						SET UserCount = 0 WHERE UserID = ' + @userID +'
					END				
				'			

EXECUTE (@sql)

SET @count = @count + 1
--SET @minID = ''
SET @userID = ''
SET @qCount = ''

END

GO