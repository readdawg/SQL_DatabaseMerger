USE InsightEnt

DECLARE @count int = (SELECT MIN(FileID) WHERE StartTime < dateadd(day,datediff(day,-1,GETDATE()),0));

DECLARE @fileId nvarchar(10) = (SELECT FileID FROM dbo.VideoFilesLog WHERE FileID = @count)

BEGIN

IF (FileManipulationStatus = 0)
	UPDATE dbo.VideoFileLog
	SET LastCheck = GETDATE()
	
ELSE IF (FileManipulationStatus = 1)
	UPDATE dbo.VideoFileLog
	SET Identified = GETDATE()

ELSE IF (FileManipulationStatus = 2)
	UPDATE dbo.VideoFileLog
	SET Started = GETDATE()

ELSE IF (FileManipulationStatus = 1001)
	UPDATE dbo.VideoFileLog
	SET Completed = GETDATE()


END

@count = @count + 1;
@fileId = '';
