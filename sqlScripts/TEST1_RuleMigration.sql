
--Create RuleCount Column in Gaining InsightEnt
USE InsightEnt
ALTER TABLE dbo.VITask
ADD RuleCount int;
GO

--Create RuleCount Column in Donor InsightEnt
USE VMSDatabase
ALTER TABLE dbo.VITask
ADD RuleCount int;
GO

-- Copy From Rule, Action, Condition, and Schedule Info From Donor To Gaining If TaskID Not In Gaining Table
USE VMSDatabase
DECLARE @count int = 1
DECLARE @maxID int 

SET @maxID = (SELECT COUNT(*) FROM VMSDatabase.dbo.VITask)

WHILE @count <= @maxID

BEGIN

DECLARE @minID int = (SELECT min(TaskID) FROM VMSDatabase.dbo.VITask WHERE RuleCount IS NULL)
DECLARE @ruleID nvarchar(50) = (SELECT TaskID FROM VMSDatabase.dbo.VITask WHERE TaskID = @minID)
DECLARE @qCount nvarchar(10) = '1'

DECLARE @sql NVARCHAR(max) = '

				IF NOT EXISTS (SELECT TaskID FROM InsightEnt.dbo.VITask WHERE TaskID = ' + @ruleID + ')
					BEGIN						
						INSERT INTO InsightEnt.dbo.VITask
						SELECT * FROM VMSDatabase.dbo.VITask
						WHERE VMSDatabase.dbo.VITask.TaskID = ' + @ruleID + '

						INSERT INTO InsightEnt.dbo.TaskAction
						SELECT * FROM VMSDatabase.dbo.TaskAction
						WHERE VMSDatabase.dbo.TaskAction.TaskID = ' + @ruleID + '

						INSERT INTO InsightEnt.dbo.TaskCondition
						SELECT * FROM VMSDatabase.dbo.TaskCondition
						WHERE VMSDatabase.dbo.TaskCondition.TaskID = ' + @ruleID + '

						INSERT INTO InsightEnt.dbo.TaskSchedule
						SELECT * FROM VMSDatabase.dbo.TaskSchedule
						WHERE VMSDatabase.dbo.TaskSchedule.TaskID = ' + @ruleID + '

						UPDATE VMSDatabase.dbo.VITask
						SET RuleCount = 1 WHERE TaskID = ' + @ruleID +'
					END				

				ELSE
					BEGIN
						UPDATE VMSDatabase.dbo.VITask
						SET RuleCount = 0 WHERE TaskID = ' + @ruleID +'
					END				
				'			

EXECUTE (@sql)

SET @count = @count + 1
SET @ruleID = ''
SET @qCount = ''

END

GO