-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Michael Reading
-- Create date: 26 Apr 18
-- Description:	Clean camera records from dbo.HM_HealthCamera_Archive after seven days
-- =============================================
CREATE PROCEDURE PurgeArchiveCameras

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM dbo.HM_HealthCamera_Archive WHERE CreatedDate > DATEADD(day, -7, GETDATE());
END
GO
