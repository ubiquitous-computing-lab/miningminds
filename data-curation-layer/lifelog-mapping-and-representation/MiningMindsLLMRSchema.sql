USE [DBMiningMindsV1_5]
GO
/****** Object:  User [mmuser2]    Script Date: 12/18/2016 12:04:07 PM ******/
CREATE USER [mmuser2] FOR LOGIN [mmuser] WITH DEFAULT_SCHEMA=[db_datareader]
GO
ALTER ROLE [db_datareader] ADD MEMBER [mmuser2]
GO
/****** Object:  StoredProcedure [dbo].[porCurrentLifeLogv]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[porCurrentLifeLogv] --21 ,1 , Current_timestamp

	@uid numeric(18,0),
	--@uid int,
	@actname int,
	@sttime datetime
	------------------------
	/* @uid numeric(18,0),
 @sttime datetime,
 @actid int;*/
	
	----------------
AS
BEGIN   --- start of procedure
SET NOCOUNT ON;
----------------------------- variaqble of populateActivelog---------------
    declare @trgval int;
	declare @ucount int;
	declare @mapid int;
---------------------------variable of cons_mapid---------------------------------------
declare @keyor nvarchar(Max),
 @keyvalue nvarchar(Max),
 @cons nvarchar(Max), 
 @fullq nvarchar(Max),
 @keyore nvarchar(Max),
 @keyoreg nvarchar(Max),
 @cntid int,
 @userchk int,
 @chk int;
---------------------------------------------------variable of cons_mapid---------------	
----------------------------- old procedure code--- populateActivelog---------------	
	
	delete from tblCurrentLifeLog where ActivyStatus='DM';
	select @ucount=COUNT(UserID) from tblUsers where UserID=@uid;
	
	
	
	if @ucount>0
	begin
		
	select top 1  @trgval=tme.MeasuringTargetValue, @mapid=tme.mapperid from tblMonitoringEvents tme join lkptActivities lka on(lka.ActivityDescription=tme.ActivityValue) where lka.ActivityID=@actname order by CONVERT(INT,tme.MeasuringTargetValue)
		
	end
	
	------------------------------------- code for deleting the row------------------
	/* highlighting the users which have now new activities*/
	

	select @chk=count(UserID)from tblCurrentLifeLog
	where UserID=@uid;
	
	if(@chk>0)
	begin
	
	update tblCurrentLifeLog
	set ActivyStatus='DM'
	where UserID=@uid
	and ActivityID!=@actname;
	
	end

-----------------------------end of old procedure code--- populateActivelog-------------

----------------------------old procedure code-------- cons_mapid----------------------- 

  
--BEGIN


select @userchk=COUNT(mapperid)from tblSituationConstraints where mapperid= @mapid;


set @chk=0;
print (@userchk)
if @userchk>0
begin
declare cur cursor for 

 
 select ConstraintKey, ConstraintValue from tblSituationConstraints where mapperid=@mapid
open cur
fetch next from cur into @keyor, @keyvalue
set @cons=' '
while(@@FETCH_STATUS=0)
    begin
    

    if @keyor= 'Age' and @keyvalue='Adult'
        
        set @keyore=' and DATEDIFF(year, convert(date, DateOfBirth),convert(date,current_timeStamp))between 18 and 45'
    
    else if @keyor= 'Age' and @keyvalue='Old'

        set @keyore=' and DATEDIFF(year, convert(date, DateOfBirth),convert(date,current_timeStamp))>= 46'
        
    else if @keyor= 'Age' and @keyvalue='Kid'
       
        set @keyore=' and DATEDIFF(year, convert(date, DateOfBirth),convert(date,current_timeStamp))<= 17'
		
	else if @keyor= 'Gender' and @keyvalue='Male'
       
         set @keyoreg=' and GenderID= 1'
        
     else if @keyor= 'Gender' and @keyvalue='Female'
       
         set @keyoreg=' and GenderID= 0'
    
     else
         begin 
         set @cons=COALESCE(@cons + ' and ', Space(2))+ @keyor +'='+ char(39)+ @keyvalue+char(39)
      end
         
fetch next from cur into @keyor, @keyvalue
end
--begin Transaction

/*  ---  updated on 29-10-2015----------
*/
if @keyore is not null and 	@keyoreg is null			
set @fullq=Coalesce('Select @chk=count(UserID) from tblUsers where UserID=' + convert(varchar, @uid), Space(1))+ @cons +@keyore 		
else if @keyoreg is not null and @keyore is null			
set @fullq=Coalesce('Select @chk=count(UserID) from tblUsers where UserID=' + convert(varchar, @uid), Space(1))+ @cons  + @keyoreg	
else 
set @fullq=Coalesce('Select @chk=count(UserID) from tblUsers where UserID=' + convert(varchar, @uid), Space(1))+ @cons +@keyore + @keyoreg
				
exec sp_executesql @fullq,N'@chk int OUTPUT', @chk=@chk OUTPUT

select @chk
print (@chk)

print (@fullq)
deallocate cur
if @chk>0
begin


insert into tblCurrentLifeLog
values(@uid, @actname, @sttime, @trgval, 'CM',@mapid)


end


end
else if @trgval is null
print ('sorry')
else
begin

insert into tblCurrentLifeLog
values(@uid, @actname, @sttime, @trgval, 'CM',@mapid)
end
delete from tblCurrentLifeLog where ActivyStatus='DM';

--end

----------------------------old procedure code-------- cons_mapid-----------------------

END --- end of procedure

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_Achievements]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 05 May, 2015               
-- Description: add Achievements              
-- =============================================                

Create PROCEDURE [dbo].[usp_Add_Achievements]                
@UserID numeric(18, 0),
@AchievementValue varchar(50),
@AchievementDescription varchar(500),
@AchievementDate DateTime,
@SupportingLink varchar(50),
@AchievementStatusID int,
@AchievementID  numeric(18, 0) output             

AS                

BEGIN                
 Insert Into tblAchievements
(                
UserID,
AchievementValue,
AchievementDescription,
AchievementDate,
SupportingLink,
AchievementStatusID
)                
 values                
(                

@UserID ,
@AchievementValue,
@AchievementDescription,
@AchievementDate,
@SupportingLink,
@AchievementStatusID
 )                

 Select @AchievementID = Ident_Current('tblAchievements')                



END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_ActiveSession]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Taqdir Ali      
-- Create date: 02 November, 2014      
-- Description: add Active session of user      
-- =============================================      
CREATE PROCEDURE [dbo].[usp_Add_ActiveSession]      
       
	@UserID numeric(18, 0),
	@HashCode varchar(50),
	@Status int,
	@ActiveSessionID  numeric(18, 0) output      
      
AS      
BEGIN  

if Not Exists( Select * from tblActiveSession Where UserID = @UserID)
Begin
	Insert Into tblActiveSession     
 (      
	UserID,
	HashCode,
	[Status]     
 )      
 values      
 (      
	@UserID,
	@HashCode,
	@Status     
 )      
       
 Select @ActiveSessionID = Ident_Current('tblActiveSession') 
End
Else
Begin
	Update tblActiveSession     
Set    
	HashCode = @HashCode,
	[Status] =  @Status    
 Where UserID = @UserID  
End   
       
      
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_ActivityFeedback]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Add Activity Feedback 
-- =============================================                



CREATE PROCEDURE [dbo].[usp_Add_ActivityFeedback]
@RecognizedActivityID numeric(18, 0),
@UserID numeric(18, 0),
@Rate int,
@Reason varchar(1000),
@FeedbackDate datetime,
@ActivityFeedbackID  numeric(18, 0) output             

AS                

BEGIN                
 Insert Into tblActivityFeedback
 (                
 	RecognizedActivityID,
	UserID,
	Rate,
	Reason,
	FeedbackDate
)                
 values                
(                
@RecognizedActivityID ,
@UserID,
@Rate,
@Reason,
@FeedbackDate
)                

 Select @ActivityFeedbackID = Ident_Current('tblActivityFeedback')                
 END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_ActivityPlan]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 November, 2014                  
-- Description: add ActivityPlan                 
-- =============================================                  
CREATE PROCEDURE [dbo].[usp_Add_ActivityPlan]                  
	@UserGoalID numeric(18, 0),
	@PlanDescription varchar(200),
	@Explanation varchar(1000),   
	@ActivityPlanID  numeric(18, 0) output               
                  
AS                  
BEGIN                  
                   
 Insert Into tblActivityPlan          
 (                  
UserGoalID,
PlanDescription,
Explanation      
 )                  
 values                  
 (                  
@UserGoalID,
@PlanDescription,
@Explanation     
 )                  
                   
 Select @ActivityPlanID = Ident_Current('tblActivityPlan')                  
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_ActivityRecommendation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                    
-- Author:  Taqdir Ali                    
-- Create date: 02 November, 2014                    
-- Description: add ActivityRecommendation                   
-- =============================================                    
CREATE PROCEDURE [dbo].[usp_Add_ActivityRecommendation]                    
 @ActivityPlanID numeric(18, 0),
@Description varchar(1000),
@Timestamp DateTime = Null ,     
 @ActivityRecommendationID  numeric(18, 0) output                 
                    
AS                    
BEGIN                    
                     
 Insert Into tblActivityRecommendation            
 (                    
ActivityPlanID,
[Description],
[Timestamp]      
 )                    
 values                    
 (                    
@ActivityPlanID,
@Description,
@Timestamp     
 )                    
                     
 Select @ActivityRecommendationID = Ident_Current('tblActivityRecommendation')                    
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_ActivityRecommendationLog]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                    
-- Author:  Taqdir Ali                    
-- Create date: 02 November, 2014                    
-- Description: add ActivityRecommendation                   
-- =============================================                    
Create PROCEDURE [dbo].[usp_Add_ActivityRecommendationLog]                    
 @ActivityPlanID numeric(18, 0),
@Description varchar(1000),
@Timestamp DateTime = Null ,     
 @ActivityRecommendationLogID  numeric(18, 0) output                 
                    
AS                    
BEGIN                    
                     
 Insert Into tblActivityRecommendationLog            
 (                    
ActivityPlanID,
[Description],
[Timestamp]      
 )                    
 values                    
 (                    
@ActivityPlanID,
@Description,
@Timestamp     
 )                    
                     
 Select @ActivityRecommendationLogID = Ident_Current('tblActivityRecommendationLog')                    
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_Device]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Taqdir Ali    
-- Create date: 02 November, 2014    
-- Description: Register Device    
-- =============================================    
CREATE PROCEDURE [dbo].[usp_Add_Device]    
	@DeviceName varchar(50),
	@DeviceTypeID int,
	@DeviceModel varchar(50),
	@RegistrationDate  DateTime = Null,
	@DeviceID  numeric(18, 0) output    
    
AS    
BEGIN    
     
 Insert Into tblDevice    
 (    
	DeviceName,
	DeviceTypeID,
	DeviceModel,
	RegistrationDate
 )    
 values    
 (    
	@DeviceName,
	@DeviceTypeID,
	@DeviceModel,
	@RegistrationDate 
 )    
     
 Select @DeviceID = Ident_Current('tblDevice')    
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_ExpertReview]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Add Recommendation Feedback         
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Add_ExpertReview]
@UserID numeric(18, 0),
@UserExpertID numeric(18, 0),
@ReviewDescription varchar(1000),
@ReviewDate datetime,
@ReviewStatusID int,
@ExpertReviewID  numeric(18, 0) output             

AS                

BEGIN                

 Insert Into tblExpertReview
 (                
	UserID,
	UserExpertID,
	ReviewDescription,
	ReviewDate,
	ReviewStatusID
)                
values                
(                
@UserID,
@UserExpertID,
@ReviewDescription,
@ReviewDate,
@ReviewStatusID
)                
Select @ExpertReviewID = Ident_Current('tblExpertReview')                

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_Facts]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 05 May, 2015               
-- Description: add Facts              
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Add_Facts]                
@SituationID numeric(18, 0),
@FactDescription varchar(500),
@SupportingLinks varchar(500),
@FactDate DateTime,
@FactStatusID int,
@FactID  numeric(18, 0) output             

AS                

BEGIN                
 Insert Into tblFacts
(                
SituationID,
FactDescription,
SupportingLinks,
FactDate,
FactStatusID
)                
 values                
(                

@SituationID,
@FactDescription,
@SupportingLinks,
@FactDate,
@FactStatusID
 )                

 Select @FactID = Ident_Current('tblFacts')                



END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_FactsFeedback]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Add Facts Feedback         
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Add_FactsFeedback]
@FactID numeric(18, 0),
@UserID numeric(18, 0),
@Rate int,
@Reason varchar(1000),
@FeedbackDate datetime,
@FactsFeedbackID  numeric(18, 0) output             

AS                
BEGIN                
 Insert Into tblFactsFeedback
  (                
  	FactID,
	UserID,
	Rate,
	Reason,
	FeedbackDate
)                
 values                
(                
@FactID ,
@UserID,
@Rate,
@Reason,
@FeedbackDate
)                
 Select @FactsFeedbackID = Ident_Current('tblFactsFeedback')                
 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_FoodLog]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================    

-- Author:  Taqdir Ali    

-- Create date: 02 November, 2014    

-- Description: Register User    

-- =============================================    

CREATE PROCEDURE [dbo].[usp_Add_FoodLog]    
  
 @UserID  numeric(18, 0),    
 @FoodName varchar(200),    
 @EatingTime Datetime = Null,    
 @FoodImage varbinary(max) = null,
 @FoodLogID  numeric(18, 0) output    

AS    

BEGIN    

 Insert Into tblFoodLog    
 (    
	UserID,
	FoodName,
	EatingTime,
	FoodImage
	)    

 values    
 (    
	@UserID,
	@FoodName,
	@EatingTime,
	@FoodImage
 )    

 Select @FoodLogID = Ident_Current('tblFoodLog')    

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_PhysiologicalFactors]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: add PhysiologicalFactors      
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Add_PhysiologicalFactors]        
 @UserID  numeric(18, 0),  
 @Weight float,  
 @height float, 
 @Date DateTime = Null, 
 @IdealWeight float = Null,
 @TargetWeight float = Null,
 @PhysiologicalFactorID  numeric(18, 0) output     
        
AS        
BEGIN        
         
 Insert Into tblPhysiologicalFactors 
 (        

UserID,
[Weight],
height,
[Date],
IdealWeight,
TargetWeight
 )        
 values        
 (        
 @UserID ,  
 @Weight,  
 @height, 
 @Date,
 @IdealWeight,
 @TargetWeight
 )        
         
 Select @PhysiologicalFactorID = Ident_Current('tblPhysiologicalFactors')        
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_Recommendation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: add Recommendation              
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Add_Recommendation]                

@RecommendationIdentifier varchar(50),
@SituationID numeric(18, 0),
@RecommendationDescription  varchar(1000),
@RecommendationTypeID int,
@ConditionValue   varchar(1000),
@RecommendationLevelID int,
@RecommendationStatusID int,
@RecommendationDate datetime,
@RecommendationID  numeric(18, 0) output             

AS                

BEGIN                
 Insert Into tblRecommendation
(                
RecommendationIdentifier,
SituationID,
RecommendationDescription,
RecommendationTypeID,
ConditionValue,
RecommendationLevelID,
RecommendationStatusID,
RecommendationDate
 )                
 values                
(                
@RecommendationIdentifier,
@SituationID,
@RecommendationDescription,
@RecommendationTypeID,
@ConditionValue,
@RecommendationLevelID,
@RecommendationStatusID,
@RecommendationDate 
 )                

 Select @RecommendationID = Ident_Current('tblRecommendation')                

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_RecommendationException]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- ============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: add Recommendation Exception             
-- =============================================                



CREATE PROCEDURE [dbo].[usp_Add_RecommendationException]

@RecommendationID numeric(18, 0),
@Exception varchar(1000),
@CustomRule  varchar(500),
@ExceptionReason varchar(1000),
@RecommendationExceptionID  numeric(18, 0) output             

AS                

BEGIN                

 Insert Into tblRecommendationException
 (                
RecommendationID,
Exception,
CustomRule,
ExceptionReason
)                
 values                
(                
@RecommendationID,
@Exception,
@CustomRule,
@ExceptionReason

)                

 Select @RecommendationExceptionID = Ident_Current('tblRecommendationException')                







END


GO
/****** Object:  StoredProcedure [dbo].[usp_Add_RecommendationExplanation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: add Recommendation Explanation             
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Add_RecommendationExplanation]

@RecommendationID numeric(18, 0),
@FactExplanation varchar(100),
@FactCategoryID int, 
@RecommendationExplanationID  numeric(18, 0) output             

AS                

BEGIN                

 Insert Into tblRecommendationExplanation
 (                
	RecommendationID,
	FactExplanation,
	FactCategoryID
)                
 values                
(                
@RecommendationID,
@FactExplanation,
@FactCategoryID
)                
 Select @RecommendationExplanationID = Ident_Current('tblRecommendationExplanation')                



END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_RecommendationFeedback]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Add Recommendation Feedback         
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Add_RecommendationFeedback]

@RecommendationID numeric(18, 0),
@UserID numeric(18, 0),
@Rate int,
@Reason varchar(1000),
@FeedbackDate datetime,
@RecommendationFeedbackID  numeric(18, 0) output             

AS                

BEGIN                

 Insert Into tblRecommendationFeedback
 (                
	RecommendationID,
	UserID,
	Rate,
	Reason,
	FeedbackDate
)                
 values                
(                
@RecommendationID ,
@UserID,
@Rate,
@Reason,
@FeedbackDate
)                

 Select @RecommendationFeedbackID = Ident_Current('tblRecommendationFeedback')                







END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_Situation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: add Situatin              
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Add_Situation]                
@UserID numeric(18, 0),  
@SituationCategoryID int,
@SituationDescription varchar(1000),
@SituationDate dateTime,
--@TimeInterval int,
@SituationID  numeric(18, 0) output             

AS                

BEGIN                

--Declare @StartTime as DateTime
--Set @StartTime = DateAdd(MINUTE, -@TimeInterval, @SituationDate)
--Declare @ExistingSituationID as numeric(18,0)
--Set @ExistingSituationID = 0

--Select @ExistingSituationID = SituationID from tblSituation
--Where UserID = @UserID and SituationDate >= @StartTime and SituationDate <= @SituationDate

--if @ExistingSituationID = 0
--Begin
	 Insert Into tblSituation
	(                
	UserID,
	SituationCategoryID,
	SituationDescription,
	SituationDate
	 )                
	 values                
	(                
	@UserID,
	@SituationCategoryID,
	@SituationDescription,
	@SituationDate
	 )                

	 Select @SituationID = Ident_Current('tblSituation')  
--End
--Else
--Begin
--	Select @SituationID = 0  
--End

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_User]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================    

-- Author:  Taqdir Ali    

-- Create date: 02 November, 2014    

-- Description: Register User    

-- =============================================    

CREATE PROCEDURE [dbo].[usp_Add_User]    
  

 @FirstName varchar(200),    
 @LastName varchar(200),    
 @MiddleName varchar(200),    
 @GenderID int,    
 @DateOfBirth Datetime = Null,    
 @ContactNumber varchar(50),    
 @EmailAddress varchar(50), 
 @Password varchar(50),   
 @MaritalStatusID int,    
 @ActivityLevelID int,    
 @OccupationID int,  
 @UserTypeID int,  
 @UserID  numeric(18, 0) output    

AS    

BEGIN    

 Insert Into tblUsers    
 (    
  FirstName,    
  LastName,    
  MiddleName,    
  GenderID,    
  DateOfBirth,    
  ContactNumber,    
  EmailAddress,  
  [Password],  
  MaritalStatusID,    
  ActivityLevelID,    
  OccupationID,
  UserTypeID
 )    

 values    
 (    
  @FirstName,    
  @LastName,    
  @MiddleName,    
  @GenderID,    
  @DateOfBirth,    
  @ContactNumber,    
  @EmailAddress,  
  @Password ,
  @MaritalStatusID,    
  @ActivityLevelID,    
  @OccupationID,
  @UserTypeID 
 )    

     

 Select @UserID = Ident_Current('tblUsers')    

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserAccelerometerData]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserGPSData            
-- =============================================              
CREATE PROCEDURE [dbo].[usp_Add_UserAccelerometerData]            
@UserDeviceID numeric(18, 0),
@XCoordinate float,
@YCoordinate float,
@ZCoordinate float,
@Timestamp  DateTime = Null,
 @UserAccelerometerDataID  numeric(18, 0) output           
              
AS              
BEGIN              
               
 Insert Into tblUserAcceleromaterData      
 (              
UserDeviceID,
XCoordinate,
YCoordinate,
ZCoordinate,
[Timestamp]   
 )              
 values              
 (              
@UserDeviceID,
@XCoordinate,
@YCoordinate,
@ZCoordinate,
@Timestamp  
 )              
               
 Select @UserAccelerometerDataID = Ident_Current('tblUserAcceleromaterData')              
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserDetectedLocation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: add tUserDetectedLocation              
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Add_UserDetectedLocation]               
@UserID numeric(18, 0),
@LocationLabel varchar(50),
@StartTime DateTime = Null,
@UserDetectedLocationID  numeric(18, 0) output             
                
AS                
BEGIN                
            
set @UserDetectedLocationID = 0
Declare @PreviousUserDetectedLocationID as numeric(18, 0)
Declare @PreviousStartTime as DateTime
Declare @PreviousDuration as int
 
 Select top 1 @PreviousUserDetectedLocationID = UserDetectedLocationID, 
 @PreviousStartTime = StartTime from tblUserDetectedLocation
 Where UserID = @UserID
 Order By UserDetectedLocationID Desc

If @LocationLabel Not Like 'NoLocation'
 Begin
	Insert Into tblUserDetectedLocation        
	 (                

	UserID,
	LocationLabel,
	StartTime,
	EndTime,
	Duration     
	 )                
	 values                
	 (                
	@UserID,
	@LocationLabel,
	@StartTime,
	Null,
	Null   
	 )                
	 Select @UserDetectedLocationID = Ident_Current('tblUserDetectedLocation') 
	 Set @PreviousDuration = DATEDIFF(SECOND, @PreviousStartTime, @StartTime)
	 Update tblUserDetectedLocation
	 Set EndTime = @StartTime,
	     Duration = @PreviousDuration
		 Where UserDetectedLocationID = @PreviousUserDetectedLocationID

 End
 Else
 Begin
	Set @PreviousDuration = DATEDIFF(SECOND, @PreviousStartTime, @StartTime)
	 Update tblUserDetectedLocation
	 Set EndTime = @StartTime,
	     Duration = @PreviousDuration
		 Where UserDetectedLocationID = @PreviousUserDetectedLocationID
		 set @UserDetectedLocationID = @PreviousUserDetectedLocationID
 End      
                
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserDevice]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: Register Device        
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Add_UserDevice]        
 @UserID numeric(18, 0),  
 @DeviceID numeric(18, 0),  
 @SubscriptionStatusID int ,  
 @RegisterDate DateTime = Null,  
 @UserDeviceID  numeric(18, 0) output     
        
AS        
BEGIN        

if @DeviceID = 1
Begin     
 Insert Into tblUserDevice        
 (        
 UserID,  
 DeviceID,  
 SubscriptionStatusID,  
 RegisterDate  
 )        
 values        
 (        
 @UserID,  
 @DeviceID,  
 @SubscriptionStatusID,  
 @RegisterDate    
 )  
 Insert Into tblUserDevice        
 (        
 UserID,  
 DeviceID,  
 SubscriptionStatusID,  
 RegisterDate  
 )        
 values        
 (        
 @UserID,  
 2,  
 @SubscriptionStatusID,  
 @RegisterDate    
 )        
 End
         
 Select @UserDeviceID = Ident_Current('tblUserDevice')        
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserDisabilities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Taqdir Ali      
-- Create date: 02 November, 2014      
-- Description: add UserRiskFactors    
-- =============================================      

CREATE PROCEDURE [dbo].[usp_Add_UserDisabilities]      
	@UserID  numeric(18, 0),
	@DisabilityID int,
	@StatusID int,
	@UserDisabilityID  numeric(18, 0) output   

AS      

BEGIN      

 Insert Into tblUserDisabilities  
 (      
	UserID,
	DisabilityID,
	StatusID
 )      
 values      
 (      
	@UserID,
	@DisabilityID,
	@StatusID
 )      

 Select @UserDisabilityID = Ident_Current('tblUserDisabilities')      

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserFacilities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: add UserRiskFactors      
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Add_UserFacilities]        
 @UserID  numeric(18, 0),  
 @FacitlityID int,  
 @UserFacilityID  numeric(18, 0) output     
        
AS        
BEGIN        
         
 Insert Into tblUserFacilities  
 (        
UserID,
FacitlityID 
 )        
 values        
 (        
 @UserID ,  
 @FacitlityID
 )        
         
 Select @UserFacilityID = Ident_Current('tblUserFacilities')        
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserGoal]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                

-- Author:  Taqdir Ali                

-- Create date: 02 November, 2014                

-- Description: add UserGoal              

-- =============================================                

CREATE PROCEDURE [dbo].[usp_Add_UserGoal]                

@UserID numeric(18, 0),  

@WeightStatusID int,

@DailyCaloriesIntake int,

@IdealWeight float,

@GoalDescription varchar(200),

@TotalCaloriesToBurn int,

@BurnedCalories int,

@Date DateTime = Null,

@DailyBurnedCal int,

@WeeklyBurnedCal int,

@MonthlyBurnedCal int,

@QuarterlyBurnedCal int,  

@BMI float,

 @UserGoalID  numeric(18, 0) output             

                

AS                

BEGIN                

                 

 Insert Into tblUserGoal        

 (                



UserID,

WeightStatusID,

DailyCaloriesIntake,

IdealWeight,

GoalDescription,

TotalCaloriesToBurn,

BurnedCalories,

[Date],

DailyBurnedCal,

WeeklyBurnedCal,

MonthlyBurnedCal,

QuarterlyBurnedCal,
BMI     

 )                

 values                

 (                

@UserID,

@WeightStatusID,

@DailyCaloriesIntake,

@IdealWeight,

@GoalDescription,

@TotalCaloriesToBurn,

@BurnedCalories,

@Date,

@DailyBurnedCal,

@WeeklyBurnedCal,

@MonthlyBurnedCal,

@QuarterlyBurnedCal,
@BMI  

 )                

                 

 Select @UserGoalID = Ident_Current('tblUserGoal')                

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserGPSData]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserGPSData            
-- =============================================              
CREATE PROCEDURE [dbo].[usp_Add_UserGPSData]              
 @UserDeviceID  numeric(18, 0),        
 @Latitude float,     
 @Longitude float,    
 @Speed float = Null,  
 @timestamp DateTime = Null,  
 @UserGPSDataID  numeric(18, 0) output           
              
AS              
BEGIN              
               
 Insert Into tblUserGPSData        
 (              
UserDeviceID,  
Latitude,  
Longitude,  
Speed,  
[timestamp]    
 )              
 values              
 (              
 @UserDeviceID,        
 @Latitude,     
 @Longitude,    
 @Speed,  
 @timestamp  
 )              
               
 Select @UserGPSDataID = Ident_Current('tblUserGPSData')              
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserPreferredActivities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================          
-- Author:  Taqdir Ali          
-- Create date: 02 November, 2014          
-- Description: add UserPreferredActivities        
-- =============================================          
CREATE PROCEDURE [dbo].[usp_Add_UserPreferredActivities]          
 @UserID  numeric(18, 0),    
 @ActivityID int, 
 @PreferenceLevelID int,   
 @UserPreferredActivityID  numeric(18, 0) output       
          
AS          
BEGIN          
           
 Insert Into tblUserPreferredActivities    
 (          
UserID,
ActivityID,
PreferenceLevelID 
 )          
 values          
 (          
 @UserID ,    
 @ActivityID,
 @PreferenceLevelID
 )          
           
 Select @UserPreferredActivityID = Ident_Current('tblUserPreferredActivities')          
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserPreferredLocation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 18 November, 2015                
-- Description: add tblUserPreferredLocation              
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Add_UserPreferredLocation]               
@UserID numeric(18, 0),
@Latitude float,
@Longitude float = Null,
@LocationLabel varchar(500) = Null,
@LocationDescription varchar(500),
@UserPreferredLocationID  numeric(18, 0) output             
                
AS                
BEGIN                
                 
 Insert Into tblUserPreferredLocation        
 (                
UserID,
Latitude,
Longitude,
LocationLabel,
LocationDescription    
 )                
 values                
 (                
@UserID,
@Latitude,
@Longitude,
@LocationLabel,
@LocationDescription  
 )                
                 
 Select @UserPreferredLocationID = Ident_Current('tblUserPreferredLocation')                
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserRecognizedActivity]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserRecognizedActivity            
-- =============================================              
CREATE PROCEDURE [dbo].[usp_Add_UserRecognizedActivity]              
@UserID numeric(18, 0),
@ActivityID int,
@StartTime DateTime = Null,
@UserRecognizedActivityID  numeric(18, 0) output           
              
AS              
BEGIN              
 Set @UserRecognizedActivityID = 0  
 Declare @PreviousUserRecognizedActivityID as numeric(18, 0)
 Declare @PreviousStartTime as DateTime
 Declare @PreviousDuration as int
 Declare @PreviousActivityID as int
 Declare @PreviousEndTime as DateTime

 set @PreviousUserRecognizedActivityID = 0
 Select top 1 @PreviousUserRecognizedActivityID = UserRecognizedActivityID, 
 @PreviousStartTime = StartTime,
 @PreviousActivityID = ActivityID,
 @PreviousEndTime = EndTime
 from tblUserRecognizedActivity
 Where UserID = @UserID
 Order By UserRecognizedActivityID Desc


 
 If @ActivityID <> 21
 Begin
	
	Insert Into tblUserRecognizedActivity      
	(              
	UserID,
	ActivityID,
	StartTime,
	EndTime,
	Duration    
	)              
	values              
	(              
	@UserID,
	@ActivityID,
	@StartTime,
	Null,
	Null  
	)              
	 Select @UserRecognizedActivityID = Ident_Current('tblUserRecognizedActivity')
	 Set @PreviousDuration = DATEDIFF(SECOND, @PreviousStartTime, @StartTime)
	 if @PreviousEndTime is null
	 Begin
		Update tblUserRecognizedActivity
		 Set EndTime = @StartTime,
			 Duration = @PreviousDuration
			 Where UserRecognizedActivityID = @PreviousUserRecognizedActivityID
	 End
	 
  End 
  Else
  Begin
	Set @PreviousDuration = DATEDIFF(SECOND, @PreviousStartTime, @StartTime)
	if @PreviousEndTime is null
	Begin
		Update tblUserRecognizedActivity
		 Set EndTime = @StartTime,
			 Duration = @PreviousDuration
			 Where UserRecognizedActivityID = @PreviousUserRecognizedActivityID
	End
  End
  
 
 if  @PreviousUserRecognizedActivityID <> 0 and @PreviousEndTime is null
 Begin
	Declare @UserRecognizedActivityAccumulateID numeric(18,0)
	Declare @AccDuration  int


	Set @UserRecognizedActivityAccumulateID = 0
	Select @UserRecognizedActivityAccumulateID = UserRecognizedActivityAccumulateID,
	@AccDuration = Duration
	from tblUserRecognizedActivityAccumulate
	Where UserID = @UserID and  ActivityID = @PreviousActivityID and Cast(ActivityDate as Date) = Cast(@StartTime as Date)

	if @UserRecognizedActivityAccumulateID = 0
	Begin
		 Insert Into tblUserRecognizedActivityAccumulate      
		 (              
			UserID,
			ActivityID,
			ActivityDate,
			Duration    
		 )              
		values              
		 (              
			@UserID,
			@PreviousActivityID,
			Cast(@StartTime as Date),
			@PreviousDuration  
		 ) 
	End
	Else
	Begin
		Update tblUserRecognizedActivityAccumulate      
		 Set              
			Duration = @AccDuration + @PreviousDuration
		Where UserRecognizedActivityAccumulateID = @UserRecognizedActivityAccumulateID
	End

 End   
 Else
 Begin
	Set @UserRecognizedActivityID = @PreviousUserRecognizedActivityID
 End   
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserRecognizedActivityAccumulate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserRecognizedActivity            
-- =============================================              
Create PROCEDURE [dbo].[usp_Add_UserRecognizedActivityAccumulate]              
@UserID numeric(18, 0),
@ActivityID int,
@ActivityDate DateTime = Null,
@Duration  numeric(18, 0),  
@UserRecognizedActivityAccumulateID  numeric(18, 0) output           
              
AS              
BEGIN              
               
 Insert Into tblUserRecognizedActivityAccumulate      
 (              
UserID,
ActivityID,
ActivityDate,
Duration  
 )              
 values              
 (              
@UserID,
@ActivityID,
@ActivityDate,
@Duration
 )              
               
 Select @UserRecognizedActivityAccumulateID = Ident_Current('tblUserRecognizedActivityAccumulate')  
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserRecognizedActivityLog]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserRecognizedActivityLog            
-- =============================================              
Create PROCEDURE [dbo].[usp_Add_UserRecognizedActivityLog]              
@UserID numeric(18, 0),
@ActivityID int,
@StartTime DateTime = Null,
@EndTime DateTime = Null,
@UserRecognizedActivityLogID  numeric(18, 0) output           
              
AS              
BEGIN              
               
 Insert Into tblUserRecognizedActivityLog      
 (              
UserID,
ActivityID,
StartTime,
EndTime   
 )              
 values              
 (              
@UserID,
@ActivityID,
@StartTime,
@EndTime 
 )              
               
 Select @UserRecognizedActivityLogID = Ident_Current('tblUserRecognizedActivityLog')              
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserRecognizedEmotion]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 17 November, 2015                
-- Description: add UserRecognizedEmotion              
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Add_UserRecognizedEmotion]               
@UserID numeric(18, 0),
@EmotionLabel varchar(100),
@StartTime DateTime = Null,
@UserRecognizedEmotionID  numeric(18, 0) output             
                
AS                
BEGIN   

set @UserRecognizedEmotionID = 0
Declare @PreviousUserRecognizedEmotionID as numeric(18, 0)
Declare @PreviousStartTime as DateTime
Declare @PreviousDuration as int             

 Select top 1 @PreviousUserRecognizedEmotionID = UserRecognizedEmotionID, 
 @PreviousStartTime = StartTime from tblUserRecognizedEmotion
 Where UserID = @UserID
 Order By UserRecognizedEmotionID Desc

 If @EmotionLabel Not Like 'NoEmotion'
 Begin
	 Insert Into tblUserRecognizedEmotion        
	 (                

	UserID,
	EmotionLabel,
	StartTime,
	EndTime,
	Duration     
	 )                
	 values                
	 (                
	@UserID,
	@EmotionLabel,
	@StartTime,
	Null,
	Null   
	 )                
	 Select @UserRecognizedEmotionID = Ident_Current('tblUserRecognizedEmotion') 
	 Set @PreviousDuration = DATEDIFF(SECOND, @PreviousStartTime, @StartTime)
	 Update tblUserRecognizedEmotion
	 Set EndTime = @StartTime,
	     Duration = @PreviousDuration
		 Where UserRecognizedEmotionID = @PreviousUserRecognizedEmotionID
 End
 Else
 Begin
	Set @PreviousDuration = DATEDIFF(SECOND, @PreviousStartTime, @StartTime)
	 Update tblUserRecognizedEmotion
	 Set EndTime = @StartTime,
	     Duration = @PreviousDuration
		 Where UserRecognizedEmotionID = @PreviousUserRecognizedEmotionID
		 set @UserRecognizedEmotionID = @PreviousUserRecognizedEmotionID

 End
               
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserRecognizedHLC]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 17 November, 2015                
-- Description: add User Recognized HLC              
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Add_UserRecognizedHLC]               
@UserID numeric(18, 0),
@HLCLabel varchar(100),
@StartTime DateTime = Null,
@UserRecognizedHLCID  numeric(18, 0) output             
                
AS                
BEGIN   

set @UserRecognizedHLCID = 0
Declare @PreviousUserRecognizedHLCID as numeric(18, 0)
Declare @PreviousStartTime as DateTime
Declare @PreviousDuration as int
 
 Select top 1 @PreviousUserRecognizedHLCID = UserRecognizedHLCID, 
 @PreviousStartTime = StartTime from tblUserRecognizedHLC
 Where UserID = @UserID
 Order By UserRecognizedHLCID Desc

If @HLCLabel Not Like 'NoHLC'
 Begin
	Insert Into tblUserRecognizedHLC        
	 (                

	UserID,
	HLCLabel,
	StartTime,
	EndTime,
	Duration     
	 )                
	 values                
	 (                
	@UserID,
	@HLCLabel,
	@StartTime,
	Null,
	Null   
	 )                
	 Select @UserRecognizedHLCID = Ident_Current('tblUserRecognizedHLC') 
	 Set @PreviousDuration = DATEDIFF(SECOND, @PreviousStartTime, @StartTime)
	 Update tblUserRecognizedHLC
	 Set EndTime = @StartTime,
	     Duration = @PreviousDuration
		 Where UserRecognizedHLCID = @PreviousUserRecognizedHLCID
 
 End
 Else
 Begin
	Set @PreviousDuration = DATEDIFF(SECOND, @PreviousStartTime, @StartTime)
	 Update tblUserRecognizedHLC
	 Set EndTime = @StartTime,
	     Duration = @PreviousDuration
		 Where UserRecognizedHLCID = @PreviousUserRecognizedHLCID
		 set @UserRecognizedHLCID = @PreviousUserRecognizedHLCID
 End             
                 
                
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserRewards]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================    

-- Author:  Taqdir Ali    

-- Create date: 02 November, 2014    

-- Description: add User rewards

-- =============================================    

Create PROCEDURE [dbo].[usp_Add_UserRewards]    
  
@UserID  numeric(18, 0),
@RewardPoints int,
@RewardDescription varchar(100),
@RewardDate DateTime,
@RewardTypeID int,
@UserRewardID numeric(18, 0) output    

AS    

BEGIN    

 Insert Into tblUserRewards    
 (    
	UserID,
	RewardPoints,
	RewardDescription,
	RewardDate,
	RewardTypeID  
 )    

 values    
 (    
	@UserID ,
	@RewardPoints ,
	@RewardDescription ,
	@RewardDate ,
	@RewardTypeID   
 )    

     

 Select @UserRewardID = Ident_Current('tblUserRewards')    

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserRiskFactors]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Taqdir Ali      
-- Create date: 02 November, 2014      
-- Description: add UserRiskFactors    
-- =============================================      
CREATE PROCEDURE [dbo].[usp_Add_UserRiskFactors]      
	@UserID  numeric(18, 0),
	@RiskFactorID int,
	@StatusID int,
	@UserRiskFactorID  numeric(18, 0) output   
      
AS      
BEGIN      
       
 Insert Into tbluserRiskFactors  
 (      
	UserID ,
	RiskFactorID,
	StatusID
 )      
 values      
 (      
	@UserID ,
	@RiskFactorID,
	@StatusID
 )      
       
 Select @UserRiskFactorID = Ident_Current('tbluserRiskFactors')      
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Add_UserSchedule]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Taqdir Ali    
-- Create date: 02 November, 2014    
-- Description: Add User Schedule    
-- =============================================    

CREATE PROCEDURE [dbo].[usp_Add_UserSchedule]    

@UserID  numeric(18, 0) = null,
@ScheduledTask varchar(500) = null,
@StartTime datetime = null,
@EndTime datetime = null,
@Extra  varchar(500) = null,
@UserScheduleID  numeric(18, 0) output    


AS    

BEGIN    

 Insert Into tblUserSchedule    
(    
 
	UserID,
	ScheduledTask,
	StartTime,
	EndTime,
	Extra  
)    
values    
(    
	@UserID,
	@ScheduledTask,
	@StartTime,
	@EndTime,
	@Extra 
 )    

 Select @UserScheduleID = Ident_Current('tblUserSchedule')    

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_AchievementsByUser]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 May, 2015                  
-- Description: get Facts By User ID        
-- =============================================                  

Create PROCEDURE [dbo].[usp_Get_AchievementsByUser]                  
 @UserID  numeric(18, 0) 
AS                  

BEGIN                  

 Select               
AchievementID,
UserID,
AchievementValue,
AchievementDescription,
AchievementDate,
SupportingLink,
AchievementStatusID,
lkptRecommendationStatus.RecommendationStatusDescription

 from tblAchievements
 Left outer join lkptRecommendationStatus on tblAchievements.AchievementStatusID = lkptRecommendationStatus.RecommendationStatusID

 Where UserID = @UserID and AchievementStatusID = 1


END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_AchievementsByUserIDDate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 May, 2015                  
-- Description: get Facts By User ID and Date Range       
-- =============================================                  

Create PROCEDURE [dbo].[usp_Get_AchievementsByUserIDDate]                  
 @UserID  numeric(18, 0),
 @StartTime datetime,    
 @EndTime datetime  
AS                  

BEGIN                  

 Select               
AchievementID,
UserID,
AchievementValue,
AchievementDescription,
AchievementDate,
SupportingLink,
AchievementStatusID,
lkptRecommendationStatus.RecommendationStatusDescription

 from tblAchievements
 Left outer join lkptRecommendationStatus on tblAchievements.AchievementStatusID = lkptRecommendationStatus.RecommendationStatusID

 Where UserID = @UserID 
 and (cast(AchievementDate as Date) >= Cast(@StartTime as Date) and cast(AchievementDate as Date) <= Cast(@EndTime as Date))


END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ActivityFeedbackByRecognizedActivityID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: get Recommendation Feedback By RecognizedActivityID
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_ActivityFeedbackByRecognizedActivityID]
@RecognizedActivityID numeric(18, 0)
AS                

BEGIN                

Select 

ActivityFeedbackID,
RecognizedActivityID,
tblActivityFeedback.UserID,
Rate,
Reason,
FeedbackDate,
tblActivityFeedback.RecognizedActivityID,
lkptActivities.ActivityDescription

From tblActivityFeedback
Inner Join tblUserRecognizedActivity on tblActivityFeedback.RecognizedActivityID = tblUserRecognizedActivity.UserRecognizedActivityID
Left outer join lkptActivities on tblUserRecognizedActivity.ActivityID = lkptActivities.ActivityID


Where RecognizedActivityID = @RecognizedActivityID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ActivityFeedbackByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: get Recommendation Feedback By User ID
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_ActivityFeedbackByUserID]
@UserID numeric(18, 0)
AS                

BEGIN                

Select 

ActivityFeedbackID,
RecognizedActivityID,
tblActivityFeedback.UserID,
Rate,
Reason,
FeedbackDate,
tblActivityFeedback.RecognizedActivityID,
lkptActivities.ActivityDescription

From tblActivityFeedback
Inner Join tblUserRecognizedActivity on tblActivityFeedback.RecognizedActivityID = tblUserRecognizedActivity.UserRecognizedActivityID
Left outer join lkptActivities on tblUserRecognizedActivity.ActivityID = lkptActivities.ActivityID

Where tblActivityFeedback.UserID = @UserID order by ActivityFeedbackID Desc 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ActivityPlanByUserGoalID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 November, 2014                  
-- Description: get User Activity Plan By User ID and time stamp            
-- =============================================                  
CREATE PROCEDURE [dbo].[usp_Get_ActivityPlanByUserGoalID]                  
 @UserGoalID  numeric(18, 0)      
AS                  
BEGIN                  
        
If @UserGoalID <> 0
Begin
 Select               
ActivityPlanID,
UserGoalID,
PlanDescription,
Explanation   
               
 from tblActivityPlan 
       Where UserGoalID = @UserGoalID 
End
Else
Begin
 Select  top 10           
ActivityPlanID,
UserGoalID,
PlanDescription,
Explanation   
               
 from tblActivityPlan  Order by ActivityPlanID Desc

End
                
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ActivityRecommendationByActivityPlanID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                    
-- Author:  Taqdir Ali                    
-- Create date: 02 November, 2014                    
-- Description: get User Activity Plan By User ID and time stamp              
-- =============================================                    
CREATE PROCEDURE [dbo].[usp_Get_ActivityRecommendationByActivityPlanID]        
 @ActivityPlanID  numeric(18, 0)        
AS                    
BEGIN                    
If @ActivityPlanID <> 0
Begin
	Select                 
	ActivityRecommendationID,
	tblActivityRecommendation.ActivityPlanID,
	[Description],
	[Timestamp],
	PlanDescription   
                 
	 from tblActivityRecommendation 
	 Left outer join tblActivityPlan on tblActivityRecommendation.ActivityPlanID = tblActivityPlan.ActivityPlanID
		   Where tblActivityRecommendation.ActivityPlanID = @ActivityPlanID    
End
Else
Begin
	Select Top 10                
	ActivityRecommendationID,
	tblActivityRecommendation.ActivityPlanID,
	[Description],
	[Timestamp],
	PlanDescription
                 
	 from tblActivityRecommendation 
	 Left outer join tblActivityPlan on tblActivityRecommendation.ActivityPlanID = tblActivityPlan.ActivityPlanID
	 Order by ActivityRecommendationID Desc
End          
                
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ActivityRecommendationByUserDate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                    
-- Author:  Taqdir Ali                    
-- Create date: 02 November, 2014                    
-- Description: get User Activity Plan By User ID and time stamp              
-- =============================================                    
CREATE PROCEDURE [dbo].[usp_Get_ActivityRecommendationByUserDate]        
 @UserID  numeric(18, 0),
 @StartTimeStamp DateTime,
 @EndTimeStamp DateTime      
AS                    
BEGIN                    
If @UserID <> 0
Begin
	Select                 
	ActivityRecommendationID,
	tblActivityRecommendation.ActivityPlanID,
	[Description],
	[Timestamp],
	PlanDescription   
                 
	 from tblActivityRecommendation 
	 Left outer join tblActivityPlan on tblActivityRecommendation.ActivityPlanID = tblActivityPlan.ActivityPlanID
	 Inner Join tblUserGoal on tblActivityPlan.UserGoalID = tblUserGoal.UserGoalID
	 
		   Where tblUserGoal.UserID = @UserID    And  [Timestamp] between @StartTimeStamp and @EndTimeStamp  
		   Order by ActivityRecommendationID Desc
End
Else 
Begin
	Select Top 100                
	ActivityRecommendationID,
	tblActivityRecommendation.ActivityPlanID,
	[Description],
	[Timestamp],
	PlanDescription
                 
	 from tblActivityRecommendation 
	 Left outer join tblActivityPlan on tblActivityRecommendation.ActivityPlanID = tblActivityPlan.ActivityPlanID
	 Inner Join tblUserGoal on tblActivityPlan.UserGoalID = tblUserGoal.UserGoalID
	 --Where tblUserGoal.UserID = @UserID
	 Where  [Timestamp] between @StartTimeStamp and @EndTimeStamp
	 Order by ActivityRecommendationID Desc
End          
                
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ActivityRecommendationLogByActivityPlanID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                    
-- Author:  Taqdir Ali                    
-- Create date: 02 November, 2014                    
-- Description: get User Activity Plan By User ID and time stamp              
-- =============================================                    
Create PROCEDURE [dbo].[usp_Get_ActivityRecommendationLogByActivityPlanID]        
 @ActivityPlanID  numeric(18, 0)        
AS                    
BEGIN                    
If @ActivityPlanID <> 0
Begin
	Select                 
	ActivityRecommendationLogID,
	tblActivityRecommendationLog.ActivityPlanID,
	[Description],
	[Timestamp],
	PlanDescription   
                 
	 from tblActivityRecommendationLog 
	 Left outer join tblActivityPlan on tblActivityRecommendationLog.ActivityPlanID = tblActivityPlan.ActivityPlanID
		   Where tblActivityRecommendationLog.ActivityPlanID = @ActivityPlanID    
End
Else
Begin
	Select Top 10                
	ActivityRecommendationLogID,
	tblActivityRecommendationLog.ActivityPlanID,
	[Description],
	[Timestamp],
	PlanDescription
                 
	 from tblActivityRecommendationLog 
	 Left outer join tblActivityPlan on tblActivityRecommendationLog.ActivityPlanID = tblActivityPlan.ActivityPlanID
	 Order by ActivityRecommendationLogID Desc
End          
                
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ActivityRecommendationLogByUserDate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                    
-- Author:  Taqdir Ali                    
-- Create date: 02 November, 2014                    
-- Description: get User Activity Plan By User ID and time stamp              
-- =============================================                    
Create PROCEDURE [dbo].[usp_Get_ActivityRecommendationLogByUserDate]        
 @UserID  numeric(18, 0),
 @StartTimeStamp DateTime,
 @EndTimeStamp DateTime      
AS                    
BEGIN                    
If @UserID <> 0
Begin
	Select                 
	ActivityRecommendationLogID,
	tblActivityRecommendationLog.ActivityPlanID,
	[Description],
	[Timestamp],
	'' as PlanDescription   
                 
	 from tblActivityRecommendationLog
	 --Left outer join tblActivityPlan on tblActivityRecommendation.ActivityPlanID = tblActivityPlan.ActivityPlanID
	 --Inner Join tblUserGoal on tblActivityPlan.UserGoalID = tblUserGoal.UserGoalID
	 
		   Where [Timestamp] between @StartTimeStamp and @EndTimeStamp  
		   Order by ActivityRecommendationLogID Desc
End
Else 
Begin
	Select Top 100                
	ActivityRecommendationLogID,
	tblActivityRecommendationLog.ActivityPlanID,
	[Description],
	[Timestamp],
	'' as PlanDescription
                 
	 from tblActivityRecommendationLog 
	 --Left outer join tblActivityPlan on tblActivityRecommendation.ActivityPlanID = tblActivityPlan.ActivityPlanID
	 --Inner Join tblUserGoal on tblActivityPlan.UserGoalID = tblUserGoal.UserGoalID
	 --Where tblUserGoal.UserID = @UserID
	 Where  [Timestamp] between @StartTimeStamp and @EndTimeStamp
	 Order by ActivityRecommendationLogID Desc
End          
                
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_BurnedCaloriesByUserIDDate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                

-- Author:  Taqdir Ali                

-- Create date: 02 November, 2014                

-- Description: get User Burned Calories By User ID and time stamp          

-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_BurnedCaloriesByUserIDDate]  

 @UserID  numeric(18, 0),    
 @StartTime datetime,    
 @EndTime datetime    

            

AS                

BEGIN                
	
select UserGoalID,
	UserID,
	WeightStatusID,
	DailyCaloriesIntake,
	IdealWeight,
	GoalDescription,
	TotalCaloriesToBurn,
	BurnedCalories,
	[Date],
	DailyBurnedCal,
	WeeklyBurnedCal,
	MonthlyBurnedCal,
	QuarterlyBurnedCal,
	BMI
from
  (
    select UserGoalID,
	UserID,
	WeightStatusID,
	DailyCaloriesIntake,
	IdealWeight,
	GoalDescription,
	TotalCaloriesToBurn,
	BurnedCalories,
	[Date],
	DailyBurnedCal,
	WeeklyBurnedCal,
	MonthlyBurnedCal,
	QuarterlyBurnedCal,
	BMI,
       row_number() 
       over (partition by cast([Date] as date)
             order by [Date] desc) as rn
    from tblUserGoal Where UserID = 2 and (cast([Date] as Date) >= Cast(@StartTime as Date) and cast([Date] as Date) <= Cast(@EndTime as Date))
  ) as dt
 where rn = 1;

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_CurrentUserDetectedLocationByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: get User Detected Location By User ID and time stamp          
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Get_CurrentUserDetectedLocationByUserID]                
 @UserID  numeric(18, 0)           
AS                
BEGIN                
     
	 Declare @EndTime DateTime
	 Select Top 1 @EndTime = EndTime From tblUserDetectedLocation Order by  UserDetectedLocationID Desc

if @EndTime is null
Begin
 Select  top 1         
	UserDetectedLocationID,
	UserID,
	LocationLabel,
	StartTime,
	EndTime,
	Duration 
    from tblUserDetectedLocation
		   Where UserID = @UserID and EndTime is null 
		   Order By  UserDetectedLocationID Desc  

End
Else
Begin
 Select  top 0         
	UserDetectedLocationID,
	UserID,
	LocationLabel,
	StartTime,
	EndTime,
	Duration 
    from tblUserDetectedLocation

End    

--Select   
--	UserDetectedLocationID,
--	UserID,
--	LocationLabel,
--	StartTime,
--	EndTime,
--	Duration 
--    from tblUserDetectedLocation
--		   Where UserID = @UserID 
		  
 
              
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_CurrentUserRecognizedActivityByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: get User latest Recognized Activity By User ID and time stamp          
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Get_CurrentUserRecognizedActivityByUserID]  
 @UserID  numeric(18, 0)
AS                
BEGIN  
Declare @EndTime DateTime

Select Top 1 @EndTime = EndTime From tblUserRecognizedActivity Order by  UserRecognizedActivityID Desc

if @EndTime is null
Begin
	Select   
	top 1          
	UserRecognizedActivityID,  
	UserID,  
	tblUserRecognizedActivity.ActivityID, 
	ActivityDescription, 
	StartTime,  
	EndTime,  
	Duration    

	 from tblUserRecognizedActivity  
			Inner Join lkptActivities on tblUserRecognizedActivity.ActivityID = lkptActivities.ActivityID
		   Where UserID = @UserID 
		   Order by  UserRecognizedActivityID Desc

End
Else
Begin
	Select   
	top 0    
	UserRecognizedActivityID,  
	UserID,  
	tblUserRecognizedActivity.ActivityID, 
	ActivityDescription, 
	StartTime,  
	EndTime,  
	Duration
	 from tblUserRecognizedActivity  
			Inner Join lkptActivities on tblUserRecognizedActivity.ActivityID = lkptActivities.ActivityID
End

	--Select   
	         
	--UserRecognizedActivityID,  
	--UserID,  
	--tblUserRecognizedActivity.ActivityID, 
	--ActivityDescription, 
	--StartTime,  
	--EndTime,  
	--Duration    

	-- from tblUserRecognizedActivity  
	--		Inner Join lkptActivities on tblUserRecognizedActivity.ActivityID = lkptActivities.ActivityID
	--	   Where UserID = @UserID 
		   
End


GO
/****** Object:  StoredProcedure [dbo].[usp_Get_CurrentUserRecognizedEmotionByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: get Current User Recognized emotion By User ID
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Get_CurrentUserRecognizedEmotionByUserID]                
 @UserID  numeric(18, 0) 
            
AS                
BEGIN                
     Declare @EndTime DateTime
	 Select Top 1 @EndTime = EndTime From tblUserRecognizedEmotion Order by  UserRecognizedEmotionID Desc

if @EndTime is null
Begin
	Select    
	 top 1         
	UserRecognizedEmotionID,
	UserID,
	EmotionLabel,
	StartTime,
	EndTime,
	Duration
             
	 from tblUserRecognizedEmotion
		   Where UserID = @UserID  and EndTime is null 
		order by UserRecognizedEmotionID Desc 

End
Else
Begin
	Select    
	 top 0         
	UserRecognizedEmotionID,
	UserID,
	EmotionLabel,
	StartTime,
	EndTime,
	Duration
  from tblUserRecognizedEmotion

End
           
	--	   	Select    
     
	--UserRecognizedEmotionID,
	--UserID,
	--EmotionLabel,
	--StartTime,
	--EndTime,
	--Duration
             
	-- from tblUserRecognizedEmotion
	--	   Where UserID = @UserID  
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_CurrentUserRecognizedHLCByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: get Current User Recognized HLC By User ID
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Get_CurrentUserRecognizedHLCByUserID]                
 @UserID  numeric(18, 0)
            
AS                
BEGIN                
     Declare @EndTime DateTime
	 Select Top 1 @EndTime = EndTime From tblUserRecognizedHLC Order by  UserRecognizedHLCID Desc

if @EndTime is null
Begin
	 Select
	 top 1             
	UserRecognizedHLCID,
	UserID,
	HLCLabel,
	StartTime,
	EndTime,
	Duration
             
	 from tblUserRecognizedHLC
		   Where UserID = @UserID and EndTime is null 

		   Order by UserRecognizedHLCID Desc

End
Else
Begin
	 Select
	 top 0             
	UserRecognizedHLCID,
	UserID,
	HLCLabel,
	StartTime,
	EndTime,
	Duration
             
	 from tblUserRecognizedHLC
		  
End
    
	--	 Select
         
	--UserRecognizedHLCID,
	--UserID,
	--HLCLabel,
	--StartTime,
	--EndTime,
	--Duration
             
	-- from tblUserRecognizedHLC
	--	   Where UserID = @UserID 

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_DeviceByID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Taqdir Ali      
-- Create date: 02 November, 2014      
-- Description: get User by device id  
-- =============================================      
CREATE PROCEDURE [dbo].[usp_Get_DeviceByID]      
  
 @DeviceID  numeric(18, 0)      
  
AS      
BEGIN      
   
 Select   
 DeviceID,
DeviceName,
DeviceTypeID,
DeviceModel,
RegistrationDate
   
 from tblDevice
   Where DeviceID =  @DeviceID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ExpertReviewByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: get Expert Review By UserID
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_ExpertReviewByUserID]
@UserID numeric(18, 0)
AS                

BEGIN                

Select 

ExpertReviewID,
UserID,
UserExpertID,
ReviewDescription,
ReviewDate,
ReviewStatusID

From tblExpertReview

Where UserID = @UserID order by ExpertReviewID Desc
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ExpertReviewByUserIDDate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Get_ExpertReviewByUserIDDate]
@UserID numeric(18, 0),
@StartTime DateTime = Null,
@EndTime DateTime = Null 
AS                

BEGIN                

Select 

ExpertReviewID,
UserID,
UserExpertID,
ReviewDescription,
ReviewDate,
ReviewStatusID

From tblExpertReview

Where UserID = @UserID
and (ReviewDate >= @StartTime And ReviewDate <= @EndTime)
and ReviewStatusID=1  -- updated by bilal ali on demand of shujaat bhaiii.
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Get_FactsByUser]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 May, 2015                  
-- Description: get Facts By User ID        
-- =============================================                  

CREATE PROCEDURE [dbo].[usp_Get_FactsByUser]                  
 @UserID  numeric(18, 0) 
AS                  

BEGIN                  

 Select               
FactID,
tblFacts.SituationID,
FactDescription,
SupportingLinks,
FactDate,
FactStatusID,
lkptRecommendationStatus.RecommendationStatusDescription

 from tblFacts

 left outer join lkptRecommendationStatus on tblFacts.FactStatusID = lkptRecommendationStatus.RecommendationStatusID
 Inner Join tblSituation on tblFacts.SituationID = tblSituation.SituationID 
 Where tblSituation.UserID = @UserID and FactStatusID = 1


END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_FactsByUserIDDate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 May, 2015                  
-- Description: get Facts By User ID        
-- =============================================                  

CREATE PROCEDURE [dbo].[usp_Get_FactsByUserIDDate]                  
 @UserID  numeric(18, 0),
 @StartTime datetime,    
 @EndTime datetime  
AS                  

BEGIN                  

 Select               
FactID,
tblFacts.SituationID,
FactDescription,
SupportingLinks,
FactDate,
FactStatusID,
lkptRecommendationStatus.RecommendationStatusDescription

 from tblFacts

 left outer join lkptRecommendationStatus on tblFacts.FactStatusID = lkptRecommendationStatus.RecommendationStatusID
 Inner Join tblSituation on tblFacts.SituationID = tblSituation.SituationID 
 Where tblSituation.UserID = @UserID 
 and (cast(FactDate as Date) >= Cast(@StartTime as Date) and cast(FactDate as Date) <= Cast(@EndTime as Date))


END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_FactsFeedbackByFactID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: get Facts Feedback By FactID
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_FactsFeedbackByFactID]
@FactID numeric(18, 0)
AS                

BEGIN                

Select 
FactsFeedbackID,
tblFactsFeedback.FactID,
tblFactsFeedback.UserID,
Rate,
Reason,
FeedbackDate,
tblSituation.SituationCategoryID,
lkptSituationCategory.SituationCategoryDescription


From tblFactsFeedback
Inner Join tblFacts on tblFactsFeedback.FactID = tblFacts.FactID
Inner Join tblSituation on tblFacts.SituationID = tblSituation.SituationID
Left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID

Where tblFactsFeedback.FactID = @FactID


END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_FactsFeedbackByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: get Facts Feedback By User ID
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_FactsFeedbackByUserID]
@UserID numeric(18, 0)
AS                

BEGIN                

Select 
FactsFeedbackID,
tblFactsFeedback.FactID,
tblFactsFeedback.UserID,
Rate,
Reason,
FeedbackDate,
tblSituation.SituationCategoryID,
lkptSituationCategory.SituationCategoryDescription

From tblFactsFeedback
Inner Join tblFacts on tblFactsFeedback.FactID = tblFacts.FactID
Inner Join tblSituation on tblFacts.SituationID = tblSituation.SituationID
Left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID

Where tblFactsFeedback.UserID = @UserID

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_FoodLogByUserIDandDateRange]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserRecognizedActivity  accumulate           
-- =============================================              
CREATE PROCEDURE [dbo].[usp_Get_FoodLogByUserIDandDateRange] 
@UserID numeric(18, 0),
@StartTime DateTime = Null,
@EndTime DateTime = Null
AS              
BEGIN 


If(@StartTime IS NULL) And (@EndTime IS NULL) And (@UserID != 0)
	 begin
	 select
	 
	 l.UserID,  
	 l.FoodName ,
	 convert(date, l.EatingTime)  as EatingTime, 
	 count(l.FoodName) TotalFoodItem, 
	 count(l.FoodName)*n.Fat TotalFat, 
	 count(l.FoodName)*n.Protein TotalProtein, 
	 count(l.FoodName)*n.Carbohydrate TotalCarbohydrate
	from tblfoodlog l, lkptfoodnutrient n
	 where l.FoodName=n.FoodName
	 And l.userid=@userID
	 And  CONVERT(date, GETDATE())=convert (date, EatingTime) -- data for one day with date conversiton function use for SCL
	 group by l.UserID,l.FoodName, n.fat, n.protein, n.carbohydrate, convert(date, l.EatingTime) 
	 end 
 
 else if (@StartTime is Not NULL) AND (@EndTime is  Not NULL) And (@UserID != 0)
		 begin 
		 select
		 
		 l.UserID,  
		 l.FoodName ,
		 convert(date, l.EatingTime)  as EatingTime, 
		 count(l.FoodName) TotalFoodItem, 
		 count(l.FoodName)*n.Fat TotalFat, 
		 count(l.FoodName)*n.Protein TotalProtein, 
		 count(l.FoodName)*n.Carbohydrate TotalCarbohydrate
		from tblfoodlog l, lkptfoodnutrient n
		 where l.FoodName=n.FoodName
		 And l.userid=@userID
		 And (EatingTime >= @StartTime And EatingTime <= @EndTime) -- data for day ranges with date conversiton function use for SL
		 group by  l.UserID,l.FoodName, n.fat, n.protein, n.carbohydrate, convert(date, l.EatingTime) 
		end         

else if (@UserID = 0) 
		 begin 
		 select
		
		 l.UserID,  
		 l.FoodName ,
		 convert(date, l.EatingTime)  as EatingTime, 
		 count(l.FoodName) TotalFoodItem, 
		 count(l.FoodName)*n.Fat TotalFat, 
		 count(l.FoodName)*n.Protein TotalProtein, 
		 count(l.FoodName)*n.Carbohydrate TotalCarbohydrate
		from tblfoodlog l, lkptfoodnutrient n
		 where l.FoodName=n.FoodName
		-- And l.userid=@userID
		 And (EatingTime >= @StartTime And EatingTime <= @EndTime) -- data for day ranges with date conversiton function use for SL
		 group by  l.UserID,l.FoodName, n.fat, n.protein, n.carbohydrate, convert(date, l.EatingTime) 
		   end         
 END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_FoodLogByUserLatest]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserRecognizedActivity  accumulate           
-- =============================================              
Create PROCEDURE [dbo].[usp_Get_FoodLogByUserLatest] 
@UserID numeric(18, 0)
AS              
BEGIN              

Select 

Top 1

FoodLogID,
UserID,
FoodName,
EatingTime

from tblFoodLog

 Where  UserID = @UserID   
 Order By EatingTime Desc
 END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_MonitorLifeLogByActivities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: Monitor Life log by activities          
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_MonitorLifeLogByActivities]  --39,  '2015-05-12 18:18:59', 2, 1
 @UserID  numeric(18, 0) = null,   
 @EndTime DateTime = null, 
 @TimeInterval int = null,
 @Threshold int = null

AS                
BEGIN                

Declare @StartTime as DateTime
--Set @TimeInterval = 60


Set @StartTime = DateAdd(MINUTE, -@TimeInterval, @EndTime)



--Set @StartTime = '2015-05-12 18:16:59'
--Set @EndTime = '2015-05-12 18:18:59'

Print @StartTime
Print @EndTime

Select 
UserID,
tblUserRecognizedActivity.ActivityID,
ActivityDescription,
CEILING((Sum(Cast(Duration as float)) / 60)) as TotalTime
 from tblUserRecognizedActivity
 left outer join lkptActivities on tblUserRecognizedActivity.ActivityID = lkptActivities.ActivityID
Where UserID = @UserID And ((StartTime >= @StartTime ) and ( EndTime <= @EndTime)) 
Group By UserID, tblUserRecognizedActivity.ActivityID, ActivityDescription

END



GO
/****** Object:  StoredProcedure [dbo].[usp_Get_PhysiologicalFactorsByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: get User Physiological Factors By UserID 
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Get_PhysiologicalFactorsByUserID]        
    
 @UserID  numeric(18, 0)        
    
AS        
BEGIN        
     
 Select     
PhysiologicalFactorID,
UserID,
[Weight],
height,
[Date],
IdealWeight,
TargetWeight
     
 from tblPhysiologicalFactors    
       Where UserID = @UserID  order by PhysiologicalFactorID Desc
      
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_ProfileDataByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: get User Profile by user id    
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Get_ProfileDataByUserID] --1       
    
 @UserID  numeric(18, 0)        
    
AS        
BEGIN        
     
 Select     
 tblUsers.UserID,    
 FirstName,    
 LastName,    
 MiddleName,    
 tblUsers.GenderID, 
 GenderDescription,   
 DateOfBirth,    
 ContactNumber,    
 EmailAddress,    
 [Password],  
 MaritalStatusID,    
 tblUsers.ActivityLevelID, 
 AC.ActivityLevelDescription,   
 OccupationID,
 UPF.Height,
 UPF.[Weight]
 
     
 from tblUsers  
 left outer join lkptActivityLevel AC on tblUsers.ActivityLevelID = AC.ActivityLevelID
 left outer Join tblPhysiologicalFactors UPF on tblUsers.UserID = UPF.UserID
 Left outer Join lkptGender on tblUsers.GenderID = lkptGender.GenderID
 Where tblUsers.UserID =  @UserID 
         
      
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_RecommendationByUser]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 May, 2015                  
-- Description: get Recommendation By User ID        
-- =============================================                  

CREATE PROCEDURE [dbo].[usp_Get_RecommendationByUser]                  
 @UserID  numeric(18, 0) 
AS                  

BEGIN                  

 Select               
RecommendationID,
RecommendationIdentifier,
tblRecommendation.SituationID,
RecommendationDescription,
tblRecommendation.RecommendationTypeID,
ConditionValue,
tblRecommendation.RecommendationLevelID,
tblRecommendation.RecommendationStatusID,
RecommendationDate,
RecommendationTypeDescription,
RecommendationLevelDescription,
RecommendationStatusDescription,
tblSituation.SituationCategoryID,
SituationCategoryDescription


 from tblRecommendation
 left outer join lkptRecommendationType on tblRecommendation.RecommendationTypeID = lkptRecommendationType.RecommendationTypeID
 left outer join lkptRecommendationLevel on tblRecommendation.RecommendationLevelID = lkptRecommendationLevel.RecommendationLevelID
 left outer join lkptRecommendationStatus on tblRecommendation.RecommendationStatusID = lkptRecommendationStatus.RecommendationStatusID

 Inner Join tblSituation on tblRecommendation.SituationID = tblSituation.SituationID 
 left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID

        Where tblSituation.UserID = @UserID and tblRecommendation.RecommendationStatusID = 1 order by RecommendationID desc
		
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_RecommendationByUserIDDate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 May, 2015                  
-- Description: get Recommendation By User ID and date range            
-- =============================================                  

CREATE PROCEDURE [dbo].[usp_Get_RecommendationByUserIDDate]                  
 @UserID  numeric(18, 0),
 @StartTime datetime,    
 @EndTime datetime    
AS                  

BEGIN                  

 Select               
RecommendationID,
RecommendationIdentifier,
tblRecommendation.SituationID,
RecommendationDescription,
tblRecommendation.RecommendationTypeID,
ConditionValue,
tblRecommendation.RecommendationLevelID,
tblRecommendation.RecommendationStatusID,
RecommendationDate,
RecommendationTypeDescription,
RecommendationLevelDescription,
RecommendationStatusDescription,
tblSituation.SituationCategoryID,
SituationCategoryDescription


 from tblRecommendation
 left outer join lkptRecommendationType on tblRecommendation.RecommendationTypeID = lkptRecommendationType.RecommendationTypeID
 left outer join lkptRecommendationLevel on tblRecommendation.RecommendationLevelID = lkptRecommendationLevel.RecommendationLevelID
 left outer join lkptRecommendationStatus on tblRecommendation.RecommendationStatusID = lkptRecommendationStatus.RecommendationStatusID

 Inner Join tblSituation on tblRecommendation.SituationID = tblSituation.SituationID 
 left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID

        Where tblSituation.UserID = @UserID --and tblRecommendation.RecommendationStatusID = 1
		and (cast(RecommendationDate as Date) >= Cast(@StartTime as Date) and cast(RecommendationDate as Date) <= Cast(@EndTime as Date))
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_RecommendationExceptionByRecommendationID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: get Recommendation Exception by RecommendationID
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_RecommendationExceptionByRecommendationID]
@RecommendationID numeric(18, 0)
AS                

BEGIN                

Select 

RecommendationExceptionID,
RecommendationID,
Exception,
CustomRule,
ExceptionReason

From tblRecommendationException

Where RecommendationID = @RecommendationID


END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_RecommendationExplanationByRecommendationID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: get Recommendation Explanation by RecommendationID
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_RecommendationExplanationByRecommendationID]
@RecommendationID numeric(18, 0)
AS                

BEGIN                

Select 

RecommendationExplanationID,
RecommendationID,
FactExplanation,
tblRecommendationExplanation.FactCategoryID,
FactCategoryDescription

From tblRecommendationExplanation
left outer join lkptFactCategory on tblRecommendationExplanation.FactCategoryID = lkptFactCategory.FactCategoryID
Where RecommendationID = @RecommendationID


END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_RecommendationFeedbackByRecommendationID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: get Recommendation Feedback By RecommendationID
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_RecommendationFeedbackByRecommendationID]
@RecommendationID numeric(18, 0)
AS                

BEGIN                

Select 

RecommendationFeedbackID,
tblRecommendationFeedback.RecommendationID,
tblRecommendationFeedback.UserID,
Rate,
Reason,
FeedbackDate,
tblSituation.SituationCategoryID,
lkptSituationCategory.SituationCategoryDescription

From tblRecommendationFeedback
Inner Join tblRecommendation on tblRecommendationFeedback.RecommendationID = tblRecommendation.RecommendationID
Inner Join tblSituation on tblRecommendation.SituationID = tblSituation.SituationID
Left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID

Where tblRecommendationFeedback.RecommendationID = @RecommendationID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_RecommendationFeedbackByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: get Recommendation Feedback By User ID
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_RecommendationFeedbackByUserID]
@UserID numeric(18, 0)
AS                

BEGIN                

Select 

RecommendationFeedbackID,
tblRecommendationFeedback.RecommendationID,
tblRecommendationFeedback.UserID,
Rate,
Reason,
FeedbackDate,
tblSituation.SituationCategoryID,
lkptSituationCategory.SituationCategoryDescription

From tblRecommendationFeedback
Inner Join tblRecommendation on tblRecommendationFeedback.RecommendationID = tblRecommendation.RecommendationID
Inner Join tblSituation on tblRecommendation.SituationID = tblSituation.SituationID
Left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID

Where tblRecommendationFeedback.UserID = @UserID order by RecommendationFeedbackID Desc
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_RecommendationsByDateRangeActivityIDs]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 13 November, 2015              
-- Description: Get Recommendation by date range and activity ids           
-- =============================================              
CREATE PROCEDURE [dbo].[usp_Get_RecommendationsByDateRangeActivityIDs] 
@ActivityIDs varchar(max),
@StartDate DateTime = Null,
@EndDate DateTime = Null
AS              
BEGIN              

declare @sqlQuery varchar(max)
 
 Set @sqlQuery = 
'Select 

RecommendationID,
RecommendationIdentifier,
tblRecommendation.SituationID,
RecommendationDescription,
tblRecommendation.RecommendationTypeID,
ConditionValue,
tblRecommendation.RecommendationLevelID,
tblRecommendation.RecommendationStatusID,
RecommendationDate,
RecommendationTypeDescription,
RecommendationLevelDescription,
RecommendationStatusDescription,
tblSituation.SituationCategoryID,
SituationCategoryDescription



from tblRecommendation

 left outer join lkptRecommendationType on tblRecommendation.RecommendationTypeID = lkptRecommendationType.RecommendationTypeID
 left outer join lkptRecommendationLevel on tblRecommendation.RecommendationLevelID = lkptRecommendationLevel.RecommendationLevelID
 left outer join lkptRecommendationStatus on tblRecommendation.RecommendationStatusID = lkptRecommendationStatus.RecommendationStatusID

left outer join tblSituation on tblRecommendation.SituationID = tblSituation.SituationID
left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID

 Where (RecommendationDate >= ' + CHAR(39) +  CONVERT(VARCHAR(10),@StartDate, 101) + CHAR(39) + ' And RecommendationDate <= ' + CHAR(39) + CONVERT(VARCHAR(10),@EndDate, 101) + CHAR(39) + ')
 and tblSituation.SituationCategoryID in ( ' + @ActivityIDs + ')'

 print @sqlQuery
 Exec (@sqlQuery)
 
END



GO
/****** Object:  StoredProcedure [dbo].[usp_Get_SituationBySituationID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 November, 2014                  
-- Description: get Situation By SituationID ID            
-- =============================================                  

Create PROCEDURE [dbo].[usp_Get_SituationBySituationID]                  
 @SituationID  numeric(18, 0)
AS                  

BEGIN                  

 Select               
 SituationID,
UserID,
tblSituation.SituationCategoryID,
SituationDescription,
SituationDate,
SituationCategoryDescription


 from tblSituation
 left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID
        Where SituationID = @SituationID 
	   
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_SituationByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 November, 2014                  
-- Description: get Situation By User ID            
-- =============================================                  

CREATE PROCEDURE [dbo].[usp_Get_SituationByUserID]                  
 @UserID  numeric(18, 0)
AS                  

BEGIN                  

 Select               
 SituationID,
UserID,
tblSituation.SituationCategoryID,
SituationDescription,
SituationDate,
SituationCategoryDescription


 from tblSituation
 left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID
        Where UserID = @UserID 
	   order by SituationID desc
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_SituationByUserIDDate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  
-- Author:  Taqdir Ali                  
-- Create date: 02 May, 2015                  
-- Description: get Situation By User ID and date range            
-- =============================================                  

CREATE PROCEDURE [dbo].[usp_Get_SituationByUserIDDate]                  
 @UserID  numeric(18, 0),
 @StartTime datetime,    
 @EndTime datetime    
AS                  

BEGIN                  

 Select               
 SituationID,
UserID,
tblSituation.SituationCategoryID,
SituationDescription,
SituationDate,
SituationCategoryDescription


 from tblSituation
 left outer join lkptSituationCategory on tblSituation.SituationCategoryID = lkptSituationCategory.SituationCategoryID
        Where UserID = @UserID 
		and (cast(SituationDate as Date) >= Cast(@StartTime as Date) and cast(SituationDate as Date) <= Cast(@EndTime as Date))
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserAccelerometerData]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: get Use rAccelerometer Data by User ID and time stamp        
-- =============================================              
CREATE PROCEDURE [dbo].[usp_Get_UserAccelerometerData]             
 @UserDeviceID  numeric(18, 0),  
 @StartTimeStamp DateTime = Null,  
 @EndTimeStamp DateTime = Null  
          
AS              
BEGIN              
           
 Select           
UserAccelerometerDataID,
tblUserAcceleromaterData.UserDeviceID,
XCoordinate,
YCoordinate,
ZCoordinate,
[Timestamp]  
           
 from tblUserAcceleromaterData
 Inner Join tblUserDevice on tblUserAcceleromaterData.UserDeviceID = tblUserDevice.UserDeviceID       
       Where tblUserAcceleromaterData.UserDeviceID = @UserDeviceID and [timestamp] between @StartTimeStamp and  @EndTimeStamp      
            
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserAccelerometerDataForVisualization]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================            
-- Author:  Taqdir Ali            
-- Create date: 02 November, 2014            
-- Description: get User GPS Data By User ID and time stamp      
-- =============================================            
CREATE PROCEDURE [dbo].[usp_Get_UserAccelerometerDataForVisualization]            
 @StartTimeStamp DateTime = Null,
 @EndTimeStamp DateTime = Null
        
AS            
BEGIN  
         
 Select  Top 100       
UserAccelerometerDataID,
tblUserAcceleromaterData.UserDeviceID,
XCoordinate,
YCoordinate,
ZCoordinate,
[Timestamp]  
           
 from tblUserAcceleromaterData 
 --Inner Join tblUserDevice on tblUserAcceleromaterData.UserDeviceID = tblUserDevice.UserDeviceID
	--Inner Join tblUserDevice on tblUserGPSData.UserDeviceID = tblUserDevice.UserDeviceID   Order by   [timestamp] Desc
       Where [timestamp] between @StartTimeStamp and  @EndTimeStamp    
	   Order by  [timestamp] Desc
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserByID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: get User by user id    
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Get_UserByID]        
    
 @UserID  numeric(18, 0)        
    
AS        
BEGIN        
     
 Select     
 UserID,    
 FirstName,    
 LastName,    
 MiddleName,    
 tblUsers.GenderID,    
 DateOfBirth,    
 ContactNumber,    
 EmailAddress,    
 [Password],  
 tblUsers.MaritalStatusID,    
 tblUsers.ActivityLevelID, 
 AC.ActivityLevelDescription,   
 tblUsers.OccupationID,
 tblUsers.UserTypeID,
 UserTypeDescription,
 GenderDescription,
 MaritalStatusDescription,
 OccupationDescription


     
     
 from tblUsers  
 left outer join lkptActivityLevel AC on tblUsers.ActivityLevelID = AC.ActivityLevelID
 left outer join lkptUserType on tblUsers.UserTypeID = lkptUserType.UserTypeID
 left outer join lkptMaritalStatus on tblUsers.MaritalStatusID = lkptMaritalStatus.MaritalStatusID
 left outer join lkptGender on tblUsers.GenderID = lkptGender.GenderID
 left outer join lkptOccupation on tblUsers.OccupationID = lkptOccupation.OccupationID
 
 Where UserID =  @UserID 
         
      
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserDetectedLocationByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: get User Detected Location By User ID and time stamp          
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Get_UserDetectedLocationByUserID]                
 @UserID  numeric(18, 0),    
 @StartTime DateTime = Null,    
 @EndTime DateTime = Null    
            
AS                
BEGIN                
   
   if @UserID <> 0
   Begin
	Select             
		UserDetectedLocationID,
		UserID,
		LocationLabel,
		StartTime,
		EndTime,
		Duration 
             
		 from tblUserDetectedLocation
			   Where UserID = @UserID and (StartTime > @StartTime Or StartTime = @StartTime)  and (EndTime <  @EndTime Or EndTime = @EndTime)
   
   End
   Else
   Begin
	Select             
		UserDetectedLocationID,
		UserID,
		LocationLabel,
		StartTime,
		EndTime,
		Duration 
             
		 from tblUserDetectedLocation
			   Where (StartTime > @StartTime Or StartTime = @StartTime)  and (EndTime <  @EndTime Or EndTime = @EndTime)
   
   End          
         
              
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserDeviceByID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Taqdir Ali      
-- Create date: 02 November, 2014      
-- Description: get User by use device by id  
-- =============================================      
CREATE PROCEDURE [dbo].[usp_Get_UserDeviceByID]      
  
 @UserDeviceID  numeric(18, 0)      
  
AS      
BEGIN      
   
 Select   
UserDeviceID,
UserID,
DeviceID,
SubscriptionStatusID,
RegisterDate
   
 from tblUserDevice
   Where UserDeviceID =  @UserDeviceID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserDisabilitiesByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Taqdir Ali      
-- Create date: 02 November, 2014      
-- Description: get User Disabilities By User ID 
-- =============================================      

CREATE PROCEDURE [dbo].[usp_Get_UserDisabilitiesByUserID]      

 @UserID  numeric(18, 0)      

AS      

BEGIN      

Select   

UserDisabilityID,
UserID,
tblUserDisabilities.DisabilityID,
tblUserDisabilities.StatusID,
DisabilityDescription,
StatusDescription

from tblUserDisabilities  
left outer join lkptDisability on tblUserDisabilities.DisabilityID = lkptDisability.DisabilityID
left outer join lkptStatus on tblUserDisabilities.StatusID = lkptStatus.StatusID

       Where UserID = @UserID order by UserDisabilityID desc

    

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserFacilitiesByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: get User Facilities By User ID   
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Get_UserFacilitiesByUserID]        
    
 @UserID  numeric(18, 0)        
    
AS        
BEGIN        
     
 Select     
UserFacilityID,
UserID,
FacitlityID  
     
 from tblUserFacilities   
       Where UserID = @UserID  
      
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserGoalByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                  

-- Author:  Taqdir Ali                  

-- Create date: 02 November, 2014                  

-- Description: get User Goal By User ID and time stamp            

-- =============================================                  

CREATE PROCEDURE [dbo].[usp_Get_UserGoalByUserID]                  

 @UserID  numeric(18, 0)

AS                  

BEGIN                  

               

 Select               

TOP 1 UserGoalID,  

UserID,  

WeightStatusID,  

DailyCaloriesIntake,  

IdealWeight,  

GoalDescription,  

TotalCaloriesToBurn,  

BurnedCalories,  

[Date],  

DailyBurnedCal,  

WeeklyBurnedCal,  

MonthlyBurnedCal,  

QuarterlyBurnedCal,
BMI    

               

 from tblUserGoal  

       Where UserID = @UserID Order by UserGoalID Desc

                

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserGPSDataByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================            
-- Author:  Taqdir Ali            
-- Create date: 02 November, 2014            
-- Description: get User GPS Data By User ID and time stamp      
-- =============================================            
CREATE PROCEDURE [dbo].[usp_Get_UserGPSDataByUserID]            
 @UserDeviceID  numeric(18, 0),
 @StartTimeStamp DateTime = Null,
 @EndTimeStamp DateTime = Null
        
AS            
BEGIN  

if   @UserDeviceID <> 0
Begin        
         
 Select         
UserGPSDataID,
tblUserGPSData.UserDeviceID,
Latitude,
Longitude,
Speed,
[timestamp] 
         
 from tblUserGPSData
	Inner Join tblUserDevice on tblUserGPSData.UserDeviceID = tblUserDevice.UserDeviceID     
       Where tblUserGPSData.UserDeviceID = @UserDeviceID and [timestamp] between @StartTimeStamp and  @EndTimeStamp    
    End
	Else
	Begin
	
	Select         
UserGPSDataID,
tblUserGPSData.UserDeviceID,
Latitude,
Longitude,
Speed,
[timestamp] 
         
 from tblUserGPSData
       Where [timestamp] between @StartTimeStamp and  @EndTimeStamp    
	End     
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserGPSDataForVisualization]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================            
-- Author:  Taqdir Ali            
-- Create date: 02 November, 2014            
-- Description: get User GPS Data By User ID and time stamp      
-- =============================================            
CREATE PROCEDURE [dbo].[usp_Get_UserGPSDataForVisualization]            
 @StartTimeStamp DateTime = Null,
 @EndTimeStamp DateTime = Null
        
AS            
BEGIN  
         
 Select  Top 100     
UserGPSDataID,
tblUserGPSData.UserDeviceID,
Latitude,
Longitude,
Speed,
[timestamp] 
         
 from tblUserGPSData
	Inner Join tblUserDevice on tblUserGPSData.UserDeviceID = tblUserDevice.UserDeviceID   
       Where [timestamp] between @StartTimeStamp and  @EndTimeStamp
	   Order by   [timestamp] Desc    

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserPreferredActivitiesByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================          
-- Author:  Taqdir Ali          
-- Create date: 02 November, 2014          
-- Description: get User Preferred Activities By UserID    
-- =============================================          
CREATE PROCEDURE [dbo].[usp_Get_UserPreferredActivitiesByUserID]          
      
 @UserID  numeric(18, 0)          
      
AS          
BEGIN          
       
 Select       
UserPreferredActivityID,
UserID,
ActivityID,
PreferenceLevelID  
       
 from tblUserPreferredActivities   
       Where UserID = @UserID  order by  UserPreferredActivityID desc
        
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserPreferredLocationByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Taqdir Ali      
-- Create date: 02 November, 2014      
-- Description: get User Disabilities By User ID 
-- =============================================      

Create PROCEDURE [dbo].[usp_Get_UserPreferredLocationByUserID]      
 @UserID  numeric(18, 0)      
AS      
BEGIN      
Select   
UserPreferredLocationID,
UserID,
Latitude,
Longitude,
LocationLabel,
LocationDescription

from tblUserPreferredLocation
Where UserID = @UserID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRecognizedActivityAccumulateByActivityIDs]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 13 November, 2015              
-- Description: add UserRecognizedActivity  accumulate By           
-- =============================================              
CREATE PROCEDURE [dbo].[usp_Get_UserRecognizedActivityAccumulateByActivityIDs] 
@ActivityIDs varchar(max),
@StartDate DateTime = Null,
@EndDate DateTime = Null
AS              
BEGIN              

declare @sqlQuery varchar(max)
 
 Set @sqlQuery = 
'Select 
UserRecognizedActivityAccumulateID,
UserID,
tblUserRecognizedActivityAccumulate.ActivityID,
ActivityDate,
Duration,
ActivityDescription

From tblUserRecognizedActivityAccumulate
Left outer join lkptActivities on tblUserRecognizedActivityAccumulate.ActivityID = lkptActivities.ActivityID

 Where (ActivityDate >= ' + CHAR(39) +  CONVERT(VARCHAR(10),@StartDate, 101) + CHAR(39) + ' And ActivityDate <= ' + CHAR(39) + CONVERT(VARCHAR(10),@EndDate, 101) + CHAR(39) + ')
 and tblUserRecognizedActivityAccumulate.ActivityID in ( ' + @ActivityIDs + ')'

 print @sqlQuery
 Exec (@sqlQuery)
 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRecognizedActivityAccumulateByUserIDDateRange]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserRecognizedActivity  accumulate           
-- =============================================              
CREATE PROCEDURE [dbo].[usp_Get_UserRecognizedActivityAccumulateByUserIDDateRange] 
@UserID numeric(18, 0),
@StartDate DateTime = Null,
@EndDate DateTime = Null
AS              
BEGIN              

if @UserID = 0
Begin   
   
Select 
UserRecognizedActivityAccumulateID,
UserID,
tblUserRecognizedActivityAccumulate.ActivityID,
ActivityDate,
Duration,
ActivityDescription

From tblUserRecognizedActivityAccumulate
Left outer join lkptActivities on tblUserRecognizedActivityAccumulate.ActivityID = lkptActivities.ActivityID

 Where (ActivityDate >= @StartDate And ActivityDate <= @EndDate)
 End
 Else
 Begin

 Select 
UserRecognizedActivityAccumulateID,
UserID,
tblUserRecognizedActivityAccumulate.ActivityID,
ActivityDate,
Duration,
ActivityDescription

From tblUserRecognizedActivityAccumulate
Left outer join lkptActivities on tblUserRecognizedActivityAccumulate.ActivityID = lkptActivities.ActivityID

 Where  UserID = @UserID   
 And (ActivityDate >= @StartDate And ActivityDate <= @EndDate)

 End

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRecognizedActivityAccumulateByUserIDOneDate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserRecognizedActivity  accumulate           
-- =============================================              
Create PROCEDURE [dbo].[usp_Get_UserRecognizedActivityAccumulateByUserIDOneDate] --39, '2015-05-12 00:00:00.000', '2015-05-12 00:00:00.000'
@UserID numeric(18, 0),
@ActivityDate DateTime = Null
AS              
BEGIN              
               
Select 
UserRecognizedActivityAccumulateID,
UserID,
tblUserRecognizedActivityAccumulate.ActivityID,
ActivityDate,
Duration,
ActivityDescription

From tblUserRecognizedActivityAccumulate
Left outer join lkptActivities on tblUserRecognizedActivityAccumulate.ActivityID = lkptActivities.ActivityID

 Where  UserID = @UserID   
 And (ActivityDate = @ActivityDate)

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRecognizedActivityByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: get User Recognized Activity By User ID and time stamp          
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Get_UserRecognizedActivityByUserID]   
 @UserID  numeric(18, 0),    
 @StartTime datetime,    
 @EndTime datetime    

AS                
BEGIN                
If @UserID <> 0
Begin
 Select             
UserRecognizedActivityID,  
UserID,  
tblUserRecognizedActivity.ActivityID, 
ActivityDescription, 
StartTime,  
EndTime,  
Duration    

 from tblUserRecognizedActivity  
		Inner Join lkptActivities on tblUserRecognizedActivity.ActivityID = lkptActivities.ActivityID
       Where UserID = @UserID and (StartTime >= @StartTime and StartTime <= @EndTime)  --and (EndTime <  @EndTime Or EndTime = @EndTime) 
	   Order by  UserRecognizedActivityID Desc
End
Else
Begin
 Select             
UserRecognizedActivityID,  
UserID,  
tblUserRecognizedActivity.ActivityID, 
ActivityDescription, 
StartTime,  
EndTime,  
Duration    

 from tblUserRecognizedActivity  
		Inner Join lkptActivities on tblUserRecognizedActivity.ActivityID = lkptActivities.ActivityID
       Where (StartTime >= @StartTime and StartTime <= @EndTime)  --and (EndTime <  @EndTime Or EndTime = @EndTime)  
	   Order by  UserRecognizedActivityID Desc 
End
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRecognizedActivityByUserIDAccumulate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: get User Recognized Activity By User ID and time stamp          
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Get_UserRecognizedActivityByUserIDAccumulate]   --39, '2015-05-12 18:18:59', '2015-05-12 18:19:02.000' 
 @UserID  numeric(18, 0),    
 @StartTime datetime,    
 @EndTime datetime    

AS                
BEGIN                
 Select             
Null as  UserRecognizedActivityID,  
UserID,  
tblUserRecognizedActivity.ActivityID, 
ActivityDescription, 
Null as StartTime,  
Null as EndTime,  
Sum(Duration) as Duration

 from tblUserRecognizedActivity  
		Inner Join lkptActivities on tblUserRecognizedActivity.ActivityID = lkptActivities.ActivityID
       Where UserID = @UserID and (StartTime >= @StartTime)  and (EndTime <= @EndTime) 
Group By tblUserRecognizedActivity.ActivityID, ActivityDescription, UserID

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRecognizedActivityLogByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                

-- Author:  Taqdir Ali                

-- Create date: 02 November, 2014                

-- Description: get User Recognized Activity Log By User ID and time stamp          

-- =============================================                

Create PROCEDURE [dbo].[usp_Get_UserRecognizedActivityLogByUserID]   

 @UserID  numeric(18, 0),    
 @StartTime datetime,    
 @EndTime datetime    

            

AS                

BEGIN                
	
             
If @UserID <> 0
Begin
 Select             
UserRecognizedActivityLogID,  
UserID,  
tblUserRecognizedActivityLog.ActivityID, 
ActivityDescription, 
StartTime,  
EndTime   

 from tblUserRecognizedActivityLog  

		Inner Join lkptActivities on tblUserRecognizedActivityLog.ActivityID = lkptActivities.ActivityID
       Where UserID = @UserID and (StartTime > @StartTime Or StartTime = @StartTime)  and (EndTime <  @EndTime Or EndTime = @EndTime)   
	    
End
Else
Begin
 Select             

UserRecognizedActivityLogID,  
UserID,  
tblUserRecognizedActivityLog.ActivityID, 
ActivityDescription, 
StartTime,  
EndTime   

 from tblUserRecognizedActivityLog  
 		Inner Join lkptActivities on tblUserRecognizedActivityLog.ActivityID = lkptActivities.ActivityID
        Where (StartTime > @StartTime Or StartTime = @StartTime)  and (EndTime <  @EndTime Or EndTime = @EndTime)   
	    
End
            

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRecognizedEmotionByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: get User Recognized emotion By User ID and time stamp          
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Get_UserRecognizedEmotionByUserID]                
 @UserID  numeric(18, 0),    
 @StartTime DateTime = Null,    
 @EndTime DateTime = Null    
            
AS                
BEGIN                
             
 Select             
UserRecognizedEmotionID,
UserID,
EmotionLabel,
StartTime,
EndTime,
Duration
             
 from tblUserRecognizedEmotion
       Where UserID = @UserID and 
	   (StartTime > @StartTime Or StartTime = @StartTime)  and (EndTime <  @EndTime Or EndTime = @EndTime)
              
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRecognizedHLCByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: get User Recognized HLC By User ID and time stamp          
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Get_UserRecognizedHLCByUserID]                
 @UserID  numeric(18, 0),    
 @StartTime DateTime = Null,    
 @EndTime DateTime = Null    
            
AS                
BEGIN                
             
 Select             
UserRecognizedHLCID,
UserID,
HLCLabel,
StartTime,
EndTime,
Duration
             
 from tblUserRecognizedHLC
       Where UserID = @UserID and 
	   (StartTime > @StartTime Or StartTime = @StartTime)  and (EndTime <  @EndTime Or EndTime = @EndTime)
              
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRewardsByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                  

-- Author:  Taqdir Ali                  

-- Create date: 02 November, 2014                  

-- Description: get User Reward By User ID           

-- =============================================                  

CREATE PROCEDURE [dbo].[usp_Get_UserRewardsByUserID] 

 @UserID  numeric(18, 0)

AS                  

BEGIN                  
              

 Select   
UserRewardID,
UserID,
RewardPoints,
RewardDescription,
RewardDate,
tblUserRewards.RewardTypeID,        
RewardTypeDescription

from tblUserRewards 
left outer join lkptRewardType on tblUserRewards.RewardTypeID = lkptRewardType.RewardTypeID

       Where UserID = @UserID order by UserRewardID Desc

                

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserRiskFactorsByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Taqdir Ali      
-- Create date: 02 November, 2014      
-- Description: get User Risk Factors By User ID 
-- =============================================      
CREATE PROCEDURE [dbo].[usp_Get_UserRiskFactorsByUserID]      
  
 @UserID  numeric(18, 0)      
  
AS      
BEGIN      
   
 Select   
UserRiskFactorID,
UserID,
RiskFactorID,
StatusID
   
 from tblUserRiskFactors  
       Where UserID = @UserID
    
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UserScheduleByUserID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 November, 2014                
-- Description: Get User Schedule  By UserID and time stamp          
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Get_UserScheduleByUserID]   
 @UserID  numeric(18, 0),    
 @StartTime datetime,    
 @EndTime datetime    
 
 AS                

BEGIN                
 Select             
 UserScheduleID,
 UserID,
 ScheduledTask,
 StartTime,
 EndTime,
 Extra
 from tblUserSchedule  

 Where UserID = @UserID and @StartTime between StartTime and EndTime

--Where UserID = @UserID and (StartTime > @StartTime Or StartTime = @StartTime)  and (EndTime <  @EndTime Or EndTime = @EndTime) 



END

GO
/****** Object:  StoredProcedure [dbo].[usp_Get_UsersListByExpertID]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: get Users List by Expert id    
-- =============================================        
Create PROCEDURE [dbo].[usp_Get_UsersListByExpertID]        
    
 @UserID  numeric(18, 0)        
    
AS        
BEGIN        
     
 Select     
 UserID,    
 FirstName,    
 LastName,    
 MiddleName,    
 tblUsers.GenderID,    
 DateOfBirth,    
 ContactNumber,    
 EmailAddress,    
 [Password],  
 tblUsers.MaritalStatusID,    
 tblUsers.ActivityLevelID, 
 AC.ActivityLevelDescription,   
 tblUsers.OccupationID,
 tblUsers.UserTypeID,
 UserTypeDescription,
 GenderDescription,
 MaritalStatusDescription,
 OccupationDescription


     
     
 from tblUsers  
 left outer join lkptActivityLevel AC on tblUsers.ActivityLevelID = AC.ActivityLevelID
 left outer join lkptUserType on tblUsers.UserTypeID = lkptUserType.UserTypeID
 left outer join lkptMaritalStatus on tblUsers.MaritalStatusID = lkptMaritalStatus.MaritalStatusID
 left outer join lkptGender on tblUsers.GenderID = lkptGender.GenderID
 left outer join lkptOccupation on tblUsers.OccupationID = lkptOccupation.OccupationID
 
 Where tblUsers.UserTypeID = 1
         
      
END

GO
/****** Object:  StoredProcedure [dbo].[usp_IsExist_User]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2015        
-- Description: check User by user Email Address a
-- =============================================        
Create PROCEDURE [dbo].[usp_IsExist_User]        
 @EmailAddress  varchar(100)
AS        

BEGIN        

 Select     
  UserID,    
 FirstName,    
 LastName,    
 MiddleName,    
 tblUsers.GenderID,    
 DateOfBirth,    
 ContactNumber,    
 EmailAddress,    
 [Password],  
 tblUsers.MaritalStatusID,    
 tblUsers.ActivityLevelID, 
 AC.ActivityLevelDescription,   
 tblUsers.OccupationID,
 tblUsers.UserTypeID,
 UserTypeDescription,
 GenderDescription,
 MaritalStatusDescription,
 OccupationDescription
   
 from tblUsers 
 left outer join lkptActivityLevel AC on tblUsers.ActivityLevelID = AC.ActivityLevelID
 left outer join lkptUserType on tblUsers.UserTypeID = lkptUserType.UserTypeID
 left outer join lkptMaritalStatus on tblUsers.MaritalStatusID = lkptMaritalStatus.MaritalStatusID
 left outer join lkptGender on tblUsers.GenderID = lkptGender.GenderID
 left outer join lkptOccupation on tblUsers.OccupationID = lkptOccupation.OccupationID  

 Where EmailAddress = @EmailAddress

END

GO
/****** Object:  StoredProcedure [dbo].[usp_NutiritionMonitor]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bilal Ali
-- Create date: 11-05-2016
-- Description:	To monitor nutrition
-- =============================================
CREATE PROCEDURE [dbo].[usp_NutiritionMonitor] --35, 'Chicken' 
 
	@uid int , 
	@foodName nvarchar(max)
	,@result int output,
	@ActStatus nvarchar(max) output,
	@mapId int output,
	@ConsumeFat int output,
	@usid int output
AS
Begin


	declare @issedentary int=0;
	declare @activityIntensity int; 
	declare @targetfoodFat float;
	declare @mapperId int;
	declare @currentFoodFat float=0;
	declare @accumulateFoodFat float=0;
	declare @accumulateFoodFata float=0;
	declare @activeCond nvarchar(max);
	-------------------------------
	--declare	@result int ;
	--declare	@ActStatus nvarchar(max);
	--declare	@targetFat int ;
	--declare	@ConsumeFat int ;
	--declare	@usid int ;
	
  
	--======================================================================================
	-- Check for Sedentary 
	  
	   select 
		@activityIntensity =ISNULL(SUM(duration), 0 )
		from tblUserRecognizedActivity
		where CONVERT (time, StartTime) between '06:01:01.0001' and '23:59:59.0001'
		and CONVERT(date, GETDATE())=convert (date, StartTime)
		and ActivityID in(1,6,9,10,11,13,14) and UserID=@uid;
		
		
			if @activityIntensity<=1600
			begin
			set @activeCond ='Sedentary';
			Print 'You are sedentary the last whole day';
			end
			else if @activityIntensity >1600
			begin
			set @activeCond='Active'; 
			Print 'You are active for whole day'  
			end 
	
	--==========================================================================
	-- Rule Selection
		
	select 
	@mapperId=mapperid,
	@targetfoodFat=MeasuringTargetValue
	from tblMonitoringEvents 
	where mapperid =(
		select mapperid from tblSituationConstraints
		where ConstraintValue =@activeCond)
	    and lower(ActivityValue)= 'eating'
	    
   print N'Rule id selected from Monitoring Events table: ' +  convert(varchar(10), @mapperId)
   
   
   --=============================================================================
   --food fat caluculation
   
    
	select
	@currentFoodFat= Fat 
	from lkptFoodNutrient
	where FoodName=@foodName;
	print N' Current Fat in the most recent Food:  ' +  convert(varchar(10), @currentFoodFat)
	
	select
	@accumulateFoodFat=ISNULL(sum(l.fat),0)
    from lkptFoodNutrient l , tblFoodLog t 
    where l.FoodName=t.FoodName
    and t.USERID=@uid 
    and CONVERT (time, t.Eatingtime) between '06:01:01.0001' and '23:59:59.0001'
    and CONVERT(date, GETDATE())=convert (date, t.Eatingtime)

	
		set @accumulateFoodFata= @accumulateFoodFat + @currentFoodFat;--+@currentFoodFat
		print N' Previous Fat of the person in that day Food: ' +  convert(varchar(10),@accumulateFoodFat)
		print N' Toal Fat of the person in that day Food: ' +  convert(varchar(10),@accumulateFoodFata)
		print N' TARGET Fat of the person in the whole day Food: ' +  convert(varchar(10),@targetfoodFat)
		
	
	
	

		if 	@accumulateFoodFata >= @targetfoodFat 
	 	--Print @targetfoodFat+ '0000' + @accumulateFoodFat
	 	Begin 
		set @result=1
		insert into tbllog_CurrentLifeLog (UserId, ActivityID, StartTime,ActivityTargetDuration, Mapperid, RecordedTime,ActivityStatus)
		values (@uid,16, CURRENT_TIMESTAMP, @accumulateFoodFata, @mapperId, CURRENT_TIMESTAMP, 'NCM' )
		end
		else if @accumulateFoodFata < @targetfoodFat 
		--Print @targetfoodFat+ '8888' +@accumulateFoodFat
		set @result=0
		else
		set @result=0;
		Print '*********************************************';
		Print N'2->> Means Fat is greater than Target,';
		Print N'3-->> Means fat is less than target';
		Print N'0--> No issue just ignore it';
		Print N'So the real result is' +  convert(varchar(10),@result)	
		
		set @ActStatus=	@activeCond
		set @mapId= @mapperId
		set @ConsumeFat=@accumulateFoodFata
		set @usid=@uid
		
		--print @ActStatus +'  '+ convert(varchar(10),@targetFat) +'  ' +convert(varchar(10),@ConsumeFat)+ '  '+convert(varchar(10),@usid )+'  '+ convert(varchar(10),@mapperid );
		--select @ActStatus,@targetFat,@ConsumeFat,@usid,@result
end

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Achievements]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 05 May, 2015               
-- Description: Update Achievements              
-- =============================================                

Create PROCEDURE [dbo].[usp_Update_Achievements] 
@AchievementID  numeric(18, 0),               
@UserID numeric(18, 0),
@AchievementValue varchar(50),
@AchievementDescription varchar(500),
@AchievementDate DateTime,
@SupportingLink varchar(50),
@AchievementStatusID int

AS                

BEGIN                
Update tblAchievements
Set            
UserID = @UserID,
AchievementValue = @AchievementValue,
AchievementDescription = @AchievementDescription,
AchievementDate = @AchievementDate,
SupportingLink = @SupportingLink,
AchievementStatusID = @AchievementStatusID

Where AchievementStatusID = @AchievementStatusID          



END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_ActivityFeedback]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Update Activity Feedback 
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Update_ActivityFeedback]
@ActivityFeedbackID  numeric(18, 0),
@RecognizedActivityID numeric(18, 0),
@UserID numeric(18, 0),
@Rate int,
@Reason varchar(1000),
@FeedbackDate datetime

AS                

BEGIN                
Update tblActivityFeedback
Set            
 	RecognizedActivityID = @RecognizedActivityID,
	UserID = @UserID,
	Rate = @Rate,
	Reason = @Reason,
	FeedbackDate = @FeedbackDate
Where  ActivityFeedbackID = @ActivityFeedbackID        
           
 END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Device]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Taqdir Ali    
-- Create date: 02 November, 2014    
-- Description: update Device    
-- =============================================    
CREATE PROCEDURE [dbo].[usp_Update_Device] 
 
	@DeviceID  numeric(18, 0),
	@DeviceName varchar(50),
	@DeviceTypeID int,
	@DeviceModel varchar(50),
	@RegistrationDate  DateTime
    
AS    
BEGIN    
     
 Update tblDevice    
	Set  
	DeviceName = @DeviceName,
	DeviceTypeID = @DeviceTypeID,
	DeviceModel = @DeviceModel,
	RegistrationDate = @RegistrationDate
	Where DeviceID = @DeviceID
     
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_ExpertReview]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Update Expert Review        
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Update_ExpertReview]
@ExpertReviewID  numeric(18, 0),
@ReviewStatusID numeric(18, 0)

AS                

BEGIN                

 Update tblExpertReview
Set              
	ReviewStatusID = @ReviewStatusID
Where ExpertReviewID = @ExpertReviewID         
           
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Facts]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 05 May, 2015               
-- Description: Update Facts              
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Update_Facts]   
@FactID  numeric(18, 0),             
@SituationID numeric(18, 0),
@FactDescription varchar(500),
@SupportingLinks varchar(500),
@FactDate DateTime,
@FactStatusID int            

AS                

BEGIN                
 Update tblFacts
 Set               
 SituationID = @SituationID,
 FactDescription = @FactDescription,
 SupportingLinks = @SupportingLinks,
 FactDate = @FactDate,
 FactStatusID = @FactStatusID

Where FactID = @FactID

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_FactsFeedback]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Update Facts Feedback         
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Update_FactsFeedback]
@FactsFeedbackID numeric(18, 0),
@FactID numeric(18, 0),
@UserID numeric(18, 0),
@Rate int,
@Reason varchar(1000),
@FeedbackDate datetime
AS                
BEGIN                
Update tblFactsFeedback
Set              
  	FactID = @FactID,
	UserID = @UserID,
	Rate = @Rate,
	Reason = @Reason,
	FeedbackDate = @FeedbackDate
Where FactsFeedbackID = @FactsFeedbackID          
 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_PhysiologicalFactors]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: Update PhysiologicalFactors      
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Update_PhysiologicalFactors]  
 @PhysiologicalFactorID numeric(18, 0),        
 @UserID  numeric(18, 0),  
 @Weight float,  
 @height float, 
 @Date DateTime = Null,   
 @IdealWeight float = Null,
 @TargetWeight float = Null 
        
AS        
BEGIN        
         
 Update tblPhysiologicalFactors 
Set 
UserID = @UserID,
[Weight] = @Weight,
height = @height,
[Date] = @Date,
IdealWeight = @IdealWeight,
TargetWeight = @TargetWeight
Where PhysiologicalFactorID = @PhysiologicalFactorID
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Recommendation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Update Recommendation              
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Update_Recommendation]                
@RecommendationID  numeric(18, 0),
@RecommendationIdentifier varchar(50),
@SituationID numeric(18, 0),
@RecommendationDescription  varchar(1000),
@RecommendationTypeID int,
@ConditionValue   varchar(1000),
@RecommendationLevelID int,
@RecommendationStatusID int,
@RecommendationDate datetime          

AS                

BEGIN                
 Update tblRecommendation
Set              
RecommendationIdentifier = @RecommendationIdentifier,
SituationID = @SituationID,
RecommendationDescription = @RecommendationDescription,
RecommendationTypeID = @RecommendationTypeID,
ConditionValue = @ConditionValue,
RecommendationLevelID = @RecommendationLevelID,
RecommendationStatusID = @RecommendationStatusID,
RecommendationDate = @RecommendationDate
 
 Where RecommendationID = @RecommendationID            

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_RecommendationException]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- ============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Update Recommendation Exception             
-- =============================================                



CREATE PROCEDURE [dbo].[usp_Update_RecommendationException]
@RecommendationExceptionID  numeric(18, 0),
@RecommendationID numeric(18, 0),
@Exception varchar(1000),
@CustomRule  varchar(500),
@ExceptionReason varchar(1000)
AS                

BEGIN                

 Update tblRecommendationException
Set              
RecommendationID = @RecommendationID,
Exception = @Exception,
CustomRule = @CustomRule,
ExceptionReason = @ExceptionReason
Where RecommendationExceptionID = @RecommendationExceptionID

END


GO
/****** Object:  StoredProcedure [dbo].[usp_Update_RecommendationExplanation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: add Recommendation Explanation             
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Update_RecommendationExplanation]
@RecommendationExplanationID  numeric(18, 0),
@RecommendationID numeric(18, 0),
@FactExplanation varchar(100),
@FactCategoryID int
AS                

BEGIN                

Update tblRecommendationExplanation
Set              
	RecommendationID = @RecommendationID,
	FactExplanation = @FactExplanation,
	FactCategoryID = @FactCategoryID
Where RecommendationExplanationID = @RecommendationExplanationID


END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_RecommendationFeedback]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: Add Recommendation Feedback         
-- =============================================                

CREATE PROCEDURE [dbo].[usp_Update_RecommendationFeedback]

@RecommendationFeedbackID  numeric(18, 0),
@RecommendationID numeric(18, 0),
@UserID numeric(18, 0),
@Rate int,
@Reason varchar(1000),
@FeedbackDate datetime            

AS                

BEGIN                

Update tblRecommendationFeedback
set              
	RecommendationID = @RecommendationID,
	UserID = @UserID,
	Rate = @Rate,
	Reason = @Reason,
	FeedbackDate = @FeedbackDate 
Where  RecommendationFeedbackID = @RecommendationFeedbackID           


END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Situation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 02 May, 2015               
-- Description: add Situatin              
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Update_Situation]  
@SituationID  numeric(18, 0),              
@UserID numeric(18, 0),  
@SituationCategoryID int,
@SituationDescription varchar(1000),
@SituationDate dateTime
AS                

BEGIN                


Update tblSituation
Set               
UserID = @UserID,
SituationCategoryID = @SituationCategoryID,
SituationDescription = @SituationDescription,
SituationDate = @SituationDate

Where SituationID = @SituationID
 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_User]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Author:  Taqdir Ali  
-- Create date: 02 November, 2014  
-- Description: Update User Registration  
-- =============================================  
CREATE PROCEDURE [dbo].[usp_Update_User]  
 @UserID  numeric(18, 0),  
 @FirstName varchar(200),  
 @LastName varchar(200),  
 @MiddleName varchar(200),  
 @GenderID int,  
 @DateOfBirth Datetime = null,  
 @ContactNumber varchar(50),  
 @EmailAddress varchar(50),  
 @Password varchar(50),  
 @MaritalStatusID int,  
 @ActivityLevelID int,  
 @OccupationID int,
 @UserTypeID int
   
  
AS  
BEGIN  
   
 Update tblUsers  
 Set   
  FirstName = @FirstName,  
  LastName = @LastName,  
  MiddleName = @MiddleName,  
  GenderID = @GenderID,  
  DateOfBirth = @DateOfBirth,  
  ContactNumber = @ContactNumber,  
  EmailAddress = @EmailAddress,
  [Password]   = @Password,
  MaritalStatusID = @MaritalStatusID,  
  ActivityLevelID = @ActivityLevelID,  
  OccupationID = @OccupationID,
  UserTypeID = @UserTypeID
   
 Where UserID = @UserID  
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserDevice]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================          
-- Author:  Taqdir Ali          
-- Create date: 02 November, 2014          
-- Description: Update User Device          
-- =============================================          
CREATE PROCEDURE [dbo].[usp_Update_UserDevice]          
 @UserID numeric(18, 0),    
 @DeviceID numeric(18, 0),    
 @SubscriptionStatusID int  
    
          
AS          
BEGIN          
  
       
 Update tblUserDevice          
 Set          
 SubscriptionStatusID = @SubscriptionStatusID   
 Where UserID = @UserID And DeviceID = @DeviceID   
 
         
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserDisabilities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Taqdir Ali      
-- Create date: 02 November, 2014      
-- Description: Update   UserDisabilities  
-- =============================================      

CREATE PROCEDURE [dbo].[usp_Update_UserDisabilities]  
	@UserDisabilityID  numeric(18, 0),    
	@UserID  numeric(18, 0),
	@DisabilityID int,
	@StatusID int

AS      

BEGIN      

Update tblUserDisabilities  
Set 
	UserID = @UserID,
	DisabilityID = @DisabilityID,
	StatusID = @StatusID
 Where  UserDisabilityID = @UserDisabilityID

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserFacilities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: update UserFacilities      
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Update_UserFacilities]
 @UserFacilityID  numeric(18, 0),         
 @UserID  numeric(18, 0),  
 @FacitlityID int  
        
AS        
BEGIN        
         
 Update tblUserFacilities  
Set      
UserID = @UserID ,
FacitlityID = @FacitlityID 
Where UserFacilityID = @UserFacilityID 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserGPSData]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================            
-- Author:  Taqdir Ali            
-- Create date: 02 November, 2014            
-- Description: Update UserGPSData          
-- =============================================            
CREATE PROCEDURE [dbo].[usp_Update_UserGPSData]
 @UserGPSDataID numeric(18, 0),              
 @UserDeviceID  numeric(18, 0),      
 @Latitude float,   
 @Longitude float,  
 @Speed float,
 @timestamp varchar(50)       
            
AS            
BEGIN            
             
 Update tblUserGPSData      
Set           
UserDeviceID = @UserDeviceID,
Latitude = @Latitude,
Longitude = @Longitude,
Speed = @Speed,
[timestamp] = @timestamp  
Where  UserGPSDataID = @UserGPSDataID        
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserPreferredActivities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================          
-- Author:  Taqdir Ali          
-- Create date: 02 November, 2014          
-- Description: update UserPreferredActivities        
-- =============================================          
CREATE PROCEDURE [dbo].[usp_Update_UserPreferredActivities]  
 @UserPreferredActivityID  numeric(18, 0),        
 @UserID  numeric(18, 0),    
 @ActivityID int, 
 @PreferenceLevelID int  
          
AS          
BEGIN          
           
Update tblUserPreferredActivities    
Set         
UserID = @UserID,
ActivityID = @ActivityID,
PreferenceLevelID = @PreferenceLevelID 
Where UserPreferredActivityID = @UserPreferredActivityID 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserPreferredLocation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                
-- Author:  Taqdir Ali                
-- Create date: 18 November, 2015                
-- Description: Update tblUserPreferredLocation              
-- =============================================                
CREATE PROCEDURE [dbo].[usp_Update_UserPreferredLocation] 
@UserPreferredLocationID  numeric(18, 0),              
@UserID numeric(18, 0),
@Latitude float = Null,
@Longitude float = Null,
@LocationLabel varchar(500) = Null,
@LocationDescription varchar(500) 
                
AS                
BEGIN                
                 
 Update tblUserPreferredLocation        
Set               
UserID  = @UserID,
Latitude = @Latitude,
Longitude = @Longitude,
LocationLabel = @LocationLabel,
LocationDescription = @LocationDescription
 
 Where UserPreferredLocationID = @UserPreferredLocationID      
           
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserRecognizedActivityAccumulate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================              
-- Author:  Taqdir Ali              
-- Create date: 02 November, 2014              
-- Description: add UserRecognizedActivity  accumulate           
-- =============================================              
Create PROCEDURE [dbo].[usp_Update_UserRecognizedActivityAccumulate] 
@UserRecognizedActivityAccumulateID  numeric(18, 0),             
@UserID numeric(18, 0),
@ActivityID int,
@ActivityDate DateTime = Null,
@Duration  numeric(18, 0)         
              
AS              
BEGIN              
               
Update tblUserRecognizedActivityAccumulate      
Set              
UserID = @UserID,
ActivityID = @ActivityID,
ActivityDate = @ActivityDate,
Duration  = @Duration
 Where  UserRecognizedActivityAccumulateID = @UserRecognizedActivityAccumulateID   

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserRewards]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================    

-- Author:  Taqdir Ali    

-- Create date: 02 November, 2014    

-- Description: add User rewards

-- =============================================    

Create PROCEDURE [dbo].[usp_Update_UserRewards]    
  
@UserRewardID numeric(18, 0),
@UserID  numeric(18, 0),
@RewardPoints int,
@RewardDescription varchar(100),
@RewardDate DateTime,
@RewardTypeID int 

AS    

BEGIN    

Update tblUserRewards    
Set  
	RewardPoints = @RewardPoints,
	RewardDescription = @RewardDescription,
	RewardDate = @RewardDate,
	RewardTypeID = @RewardTypeID
 Where UserRewardID = @UserRewardID

    
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserRiskFactors]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: add UserRiskFactors      
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Update_UserRiskFactors]
 @UserRiskFactorID   numeric(18, 0),     
 @UserID  numeric(18, 0),  
 @RiskFactorID int,  
 @StatusID int 
        
AS        
BEGIN        
         
 Update tbluserRiskFactors    
Set       
 UserID = @UserID ,  
 RiskFactorID = @RiskFactorID,  
 StatusID =   @StatusID
 Where    UserRiskFactorID = @UserRiskFactorID 
         
END

GO
/****** Object:  StoredProcedure [dbo].[usp_Update_UserSchedule]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Taqdir Ali    
-- Create date: 02 November, 2014    
-- Description: Update User Schedule    
-- =============================================    

CREATE PROCEDURE [dbo].[usp_Update_UserSchedule]    

@UserScheduleID numeric(18, 0),
@UserID  numeric(18, 0) = null,
@ScheduledTask varchar(500) = null,
@StartTime datetime = null,
@EndTime datetime = null,
@Extra  varchar(500) = null

AS    

BEGIN    

Update tblUserSchedule    
Set
 
	UserID = @UserID,
	ScheduledTask = @ScheduledTask,
	StartTime = @StartTime,
	EndTime = @EndTime,
	Extra  = @Extra

Where  UserScheduleID = @UserScheduleID 

END

GO
/****** Object:  StoredProcedure [dbo].[usp_Validate_User]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================        
-- Author:  Taqdir Ali        
-- Create date: 02 November, 2014        
-- Description: validate User by user Email Address and Password
-- =============================================        
CREATE PROCEDURE [dbo].[usp_Validate_User]        
 @EmailAddress  varchar(100),
  @Password varchar(50)        

AS        

BEGIN        

 Select     
  UserID,    
 FirstName,    
 LastName,    
 MiddleName,    
 tblUsers.GenderID,    
 DateOfBirth,    
 ContactNumber,    
 EmailAddress,    
 [Password],  
 tblUsers.MaritalStatusID,    
 tblUsers.ActivityLevelID, 
 AC.ActivityLevelDescription,   
 tblUsers.OccupationID,
 tblUsers.UserTypeID,
 UserTypeDescription,
 GenderDescription,
 MaritalStatusDescription,
 OccupationDescription
   
 from tblUsers 
 left outer join lkptActivityLevel AC on tblUsers.ActivityLevelID = AC.ActivityLevelID
 left outer join lkptUserType on tblUsers.UserTypeID = lkptUserType.UserTypeID
 left outer join lkptMaritalStatus on tblUsers.MaritalStatusID = lkptMaritalStatus.MaritalStatusID
 left outer join lkptGender on tblUsers.GenderID = lkptGender.GenderID
 left outer join lkptOccupation on tblUsers.OccupationID = lkptOccupation.OccupationID  

 Where EmailAddress = @EmailAddress and [Password] = @Password

END

GO
/****** Object:  Table [dbo].[lkptActivities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptActivities](
	[ActivityID] [int] NOT NULL,
	[ActivityDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptActivities] PRIMARY KEY CLUSTERED 
(
	[ActivityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptActivityLevel]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptActivityLevel](
	[ActivityLevelID] [int] NOT NULL,
	[ActivityLevelDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptActivityLevel] PRIMARY KEY CLUSTERED 
(
	[ActivityLevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptAddressType]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptAddressType](
	[AddressTypeID] [int] NOT NULL,
	[AddressTypeDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptAddressType] PRIMARY KEY CLUSTERED 
(
	[AddressTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptCity]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptCity](
	[CityID] [int] NOT NULL,
	[CityDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptCity] PRIMARY KEY CLUSTERED 
(
	[CityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptCountry]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptCountry](
	[CountryID] [int] NOT NULL,
	[CountryDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptCountry] PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptDeviceType]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptDeviceType](
	[DeviceTypeID] [int] NOT NULL,
	[DeviceTypeDescription] [varchar](100) NULL,
 CONSTRAINT [PK_lkptDeviceType] PRIMARY KEY CLUSTERED 
(
	[DeviceTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptDisability]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptDisability](
	[DisabilityID] [int] NOT NULL,
	[DisabilityDescription] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptFacitlity]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptFacitlity](
	[FacitlityID] [int] NOT NULL,
	[FacitlityDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptFacitlity] PRIMARY KEY CLUSTERED 
(
	[FacitlityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptFactCategory]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptFactCategory](
	[FactCategoryID] [int] NULL,
	[FactCategoryDescription] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptFoodNutrient]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptFoodNutrient](
	[FoodID] [numeric](18, 0) NOT NULL,
	[FoodName] [varchar](50) NULL,
	[Fat] [float] NULL,
	[FoodCategory] [varchar](50) NULL,
	[Serving] [float] NULL,
	[Carbohydrate] [float] NULL,
	[Protein] [float] NULL,
	[NutritionCategory] [varchar](50) NULL,
 CONSTRAINT [PK_lkptFoodNutrient] PRIMARY KEY CLUSTERED 
(
	[FoodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptFoodNutritionCategory]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptFoodNutritionCategory](
	[FoodNutritionCategoryID] [numeric](18, 0) NOT NULL,
	[FoodCategory] [varchar](50) NULL,
	[NutritionCategory] [varchar](50) NULL,
 CONSTRAINT [PK_lkptFoodNutritionCategory] PRIMARY KEY CLUSTERED 
(
	[FoodNutritionCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptGender]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptGender](
	[GenderID] [int] NOT NULL,
	[GenderDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptGender] PRIMARY KEY CLUSTERED 
(
	[GenderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptMaritalStatus]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptMaritalStatus](
	[MaritalStatusID] [int] NOT NULL,
	[MaritalStatusDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptMaritalStatus] PRIMARY KEY CLUSTERED 
(
	[MaritalStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptOccupation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptOccupation](
	[OccupationID] [int] NOT NULL,
	[OccupationDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptOccupation] PRIMARY KEY CLUSTERED 
(
	[OccupationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptPreferenceLevel]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptPreferenceLevel](
	[PreferenceLevelID] [int] NOT NULL,
	[PreferenceLevelDescription] [varchar](100) NULL,
 CONSTRAINT [PK_lkptPreferenceLevel] PRIMARY KEY CLUSTERED 
(
	[PreferenceLevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptRecommendationLevel]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptRecommendationLevel](
	[RecommendationLevelID] [int] NULL,
	[RecommendationLevelDescription] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptRecommendationStatus]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptRecommendationStatus](
	[RecommendationStatusID] [int] NULL,
	[RecommendationStatusDescription] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptRecommendationType]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptRecommendationType](
	[RecommendationTypeID] [int] NOT NULL,
	[RecommendationTypeDescription] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptRewardType]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptRewardType](
	[RewardTypeID] [int] NOT NULL,
	[RewardTypeDescription] [varchar](50) NULL,
	[DurationFlag] [int] NULL,
 CONSTRAINT [PK_lkptRewardType] PRIMARY KEY CLUSTERED 
(
	[RewardTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptRiskFactor]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptRiskFactor](
	[RiskFactorID] [int] NOT NULL,
	[RiskFactorDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptRiskFactor] PRIMARY KEY CLUSTERED 
(
	[RiskFactorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptSituationCategory]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptSituationCategory](
	[SituationCategoryID] [int] NULL,
	[SituationCategoryDescription] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptStatus]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptStatus](
	[StatusID] [int] NOT NULL,
	[StatusDescription] [varchar](50) NULL,
 CONSTRAINT [PK_lkptStatus] PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptUserType]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptUserType](
	[UserTypeID] [int] NOT NULL,
	[UserTypeDescription] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lkptWeightStatus]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[lkptWeightStatus](
	[WeightStatusID] [int] NOT NULL,
	[WeightStatusDescription] [varchar](100) NULL,
 CONSTRAINT [PK_lkptWeightStatus] PRIMARY KEY CLUSTERED 
(
	[WeightStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblAchievements]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblAchievements](
	[AchievementID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NULL,
	[AchievementValue] [varchar](50) NULL,
	[AchievementDescription] [varchar](500) NULL,
	[AchievementDate] [datetime] NULL,
	[SupportingLink] [varchar](50) NULL,
	[AchievementStatusID] [int] NULL,
 CONSTRAINT [PK_tblAchievements] PRIMARY KEY CLUSTERED 
(
	[AchievementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblActiveSession]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblActiveSession](
	[ActiveSessionID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[HashCode] [varchar](50) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_tblActiveSession] PRIMARY KEY CLUSTERED 
(
	[ActiveSessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblActivityFeedback]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblActivityFeedback](
	[ActivityFeedbackID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[RecognizedActivityID] [numeric](18, 0) NULL,
	[UserID] [numeric](18, 0) NULL,
	[Rate] [int] NULL,
	[Reason] [varchar](1000) NULL,
	[FeedbackDate] [datetime] NULL,
 CONSTRAINT [PK_tblActivityFeedback] PRIMARY KEY CLUSTERED 
(
	[ActivityFeedbackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblActivityPlan]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblActivityPlan](
	[ActivityPlanID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserGoalID] [numeric](18, 0) NOT NULL,
	[PlanDescription] [varchar](200) NULL,
	[Explanation] [varchar](1000) NULL,
 CONSTRAINT [PK_tblActivityPlan] PRIMARY KEY CLUSTERED 
(
	[ActivityPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblActivityRecommendation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblActivityRecommendation](
	[ActivityRecommendationID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[ActivityPlanID] [numeric](18, 0) NOT NULL,
	[Description] [varchar](500) NULL,
	[Timestamp] [datetime] NULL,
 CONSTRAINT [PK_tblActivityRecommendation] PRIMARY KEY CLUSTERED 
(
	[ActivityRecommendationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblActivityRecommendationLog]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblActivityRecommendationLog](
	[ActivityRecommendationLogID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[ActivityPlanID] [numeric](18, 0) NULL,
	[Description] [varchar](500) NULL,
	[Timestamp] [datetime] NULL,
 CONSTRAINT [PK_tblActivityRecommendationLog] PRIMARY KEY CLUSTERED 
(
	[ActivityRecommendationLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblCurrentLifeLog]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCurrentLifeLog](
	[UserId] [int] NOT NULL,
	[ActivityID] [int] NOT NULL,
	[StartTime] [datetime] NULL,
	[ActivityTargetDuration] [int] NULL,
	[ActivyStatus] [nvarchar](50) NULL,
	[mapperid] [int] NULL,
 CONSTRAINT [pk_UserId_ActivityID] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[ActivityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDevice]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblDevice](
	[DeviceID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[DeviceName] [varchar](50) NULL,
	[DeviceTypeID] [int] NULL,
	[DeviceModel] [varchar](50) NULL,
	[RegistrationDate] [datetime] NULL,
 CONSTRAINT [PK_tblDevice] PRIMARY KEY CLUSTERED 
(
	[DeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblExpertReview]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblExpertReview](
	[ExpertReviewID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NULL,
	[UserExpertID] [numeric](18, 0) NULL,
	[ReviewDescription] [varchar](1000) NULL,
	[ReviewDate] [datetime] NULL,
	[ReviewStatusID] [int] NULL,
 CONSTRAINT [PK_tblExpertReview] PRIMARY KEY CLUSTERED 
(
	[ExpertReviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblFacts]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblFacts](
	[FactID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[SituationID] [numeric](18, 0) NULL,
	[FactDescription] [varchar](500) NULL,
	[SupportingLinks] [varchar](500) NULL,
	[FactDate] [datetime] NULL,
	[FactStatusID] [int] NULL,
 CONSTRAINT [PK_tblFacts] PRIMARY KEY CLUSTERED 
(
	[FactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblFactsFeedback]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblFactsFeedback](
	[FactsFeedbackID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[FactID] [numeric](18, 0) NULL,
	[UserID] [numeric](18, 0) NULL,
	[Rate] [int] NULL,
	[Reason] [varchar](1000) NULL,
	[FeedbackDate] [datetime] NULL,
 CONSTRAINT [PK_tblFactsFeedback] PRIMARY KEY CLUSTERED 
(
	[FactsFeedbackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblFoodLog]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblFoodLog](
	[FoodLogID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NULL,
	[FoodName] [varchar](50) NULL,
	[EatingTime] [datetime] NULL,
	[FoodImage] [varbinary](max) NULL,
 CONSTRAINT [PK_tblFoodLog] PRIMARY KEY CLUSTERED 
(
	[FoodLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbllog_CurrentLifeLog]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbllog_CurrentLifeLog](
	[UserId] [int] NOT NULL,
	[ActivityID] [int] NOT NULL,
	[StartTime] [datetime] NULL,
	[ActivityTargetDuration] [int] NULL,
	[ActivityStatus] [nvarchar](50) NULL,
	[Mapperid] [int] NULL,
	[RecordedTime] [datetime] NULL,
	[Log_Id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblMonitoringEvents]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMonitoringEvents](
	[mapperid] [numeric](18, 0) NOT NULL,
	[Activity] [nvarchar](50) NOT NULL,
	[ActivityOperator] [nchar](10) NOT NULL,
	[ActivityValue] [nvarchar](50) NOT NULL,
	[ActivityDataType] [nvarchar](50) NOT NULL,
	[MeasuringMetric] [nvarchar](50) NOT NULL,
	[MeasuringOperator] [nchar](10) NOT NULL,
	[MeasuringTargetValue] [nvarchar](50) NOT NULL,
	[MeasuringDataType] [nvarchar](50) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblPhysiologicalFactors]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPhysiologicalFactors](
	[PhysiologicalFactorID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[Weight] [float] NULL,
	[height] [float] NULL,
	[Date] [datetime] NULL,
	[IdealWeight] [float] NULL,
	[TargetWeight] [float] NULL,
 CONSTRAINT [PK_tblPhysiologicalFactors] PRIMARY KEY CLUSTERED 
(
	[PhysiologicalFactorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblRecommendation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRecommendation](
	[RecommendationID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[RecommendationIdentifier] [varchar](50) NULL,
	[SituationID] [numeric](18, 0) NULL,
	[RecommendationDescription] [varchar](1000) NULL,
	[RecommendationTypeID] [int] NULL,
	[ConditionValue] [varchar](1000) NULL,
	[RecommendationLevelID] [int] NULL,
	[RecommendationStatusID] [int] NULL,
	[RecommendationDate] [datetime] NULL,
 CONSTRAINT [PK_tblRecommendation] PRIMARY KEY CLUSTERED 
(
	[RecommendationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRecommendationException]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRecommendationException](
	[RecommendationExceptionID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[RecommendationID] [numeric](18, 0) NULL,
	[Exception] [varchar](1000) NULL,
	[CustomRule] [varchar](500) NULL,
	[ExceptionReason] [varchar](1000) NULL,
 CONSTRAINT [PK_tblRecommendationException] PRIMARY KEY CLUSTERED 
(
	[RecommendationExceptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRecommendationExplanation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRecommendationExplanation](
	[RecommendationExplanationID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[RecommendationID] [numeric](18, 0) NULL,
	[FactExplanation] [varchar](1000) NULL,
	[FactCategoryID] [int] NULL,
 CONSTRAINT [PK_tblRecommendationExplanation] PRIMARY KEY CLUSTERED 
(
	[RecommendationExplanationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRecommendationFeedback]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRecommendationFeedback](
	[RecommendationFeedbackID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[RecommendationID] [numeric](18, 0) NULL,
	[UserID] [numeric](18, 0) NULL,
	[Rate] [int] NULL,
	[Reason] [varchar](1000) NULL,
	[FeedbackDate] [datetime] NULL,
 CONSTRAINT [PK_tblRecommendationFeedback] PRIMARY KEY CLUSTERED 
(
	[RecommendationFeedbackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblSituation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblSituation](
	[SituationID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NULL,
	[SituationCategoryID] [int] NULL,
	[SituationDescription] [varchar](1000) NULL,
	[SituationDate] [datetime] NULL,
 CONSTRAINT [PK_tblSituation] PRIMARY KEY CLUSTERED 
(
	[SituationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblSituationConstraints]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSituationConstraints](
	[c_id] [numeric](18, 0) NOT NULL,
	[ConstraintKey] [nvarchar](50) NOT NULL,
	[ConstraintOperator] [nvarchar](50) NOT NULL,
	[ConstraintValue] [nvarchar](50) NOT NULL,
	[ConstraintDataType] [nvarchar](50) NOT NULL,
	[mapperid] [numeric](18, 0) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserAcceleromaterData]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserAcceleromaterData](
	[UserAccelerometerDataID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserDeviceID] [numeric](18, 0) NOT NULL,
	[XCoordinate] [float] NULL,
	[YCoordinate] [float] NULL,
	[ZCoordinate] [float] NULL,
	[Timestamp] [datetime] NULL,
 CONSTRAINT [PK_tblUserAcceleromaterData] PRIMARY KEY CLUSTERED 
(
	[UserAccelerometerDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserAddress]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserAddress](
	[UserAddressID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[AddressTypeID] [int] NULL,
	[HouseNumber] [varchar](50) NULL,
	[StreetNo] [varchar](50) NULL,
	[CityID] [int] NULL,
	[CountryID] [int] NULL,
 CONSTRAINT [PK_tblUserAddress] PRIMARY KEY CLUSTERED 
(
	[UserAddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserDetectedLocation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserDetectedLocation](
	[UserDetectedLocationID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[LocationLabel] [varchar](100) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Duration] [int] NULL,
 CONSTRAINT [PK_tblUserDetectedLocation] PRIMARY KEY CLUSTERED 
(
	[UserDetectedLocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserDevice]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserDevice](
	[UserDeviceID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[DeviceID] [numeric](18, 0) NULL,
	[SubscriptionStatusID] [nchar](10) NULL,
	[RegisterDate] [datetime] NULL,
	[RequiredTimeInterval] [int] NULL,
 CONSTRAINT [PK_tblUserDevice] PRIMARY KEY CLUSTERED 
(
	[UserDeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserDeviceSubscription]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserDeviceSubscription](
	[UserDeviceSubscriptionID] [numeric](18, 0) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[DeviceID] [nchar](10) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserDisabilities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserDisabilities](
	[UserDisabilityID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NULL,
	[DisabilityID] [int] NULL,
	[StatusID] [int] NULL,
 CONSTRAINT [PK_tblUserDisabilities] PRIMARY KEY CLUSTERED 
(
	[UserDisabilityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserFacilities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserFacilities](
	[UserFacilityID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[FacitlityID] [int] NOT NULL,
 CONSTRAINT [PK_tblUserFacilities] PRIMARY KEY CLUSTERED 
(
	[UserFacilityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserGoal]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserGoal](
	[UserGoalID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[WeightStatusID] [int] NULL,
	[DailyCaloriesIntake] [int] NULL,
	[IdealWeight] [float] NULL,
	[GoalDescription] [varchar](200) NULL,
	[TotalCaloriesToBurn] [int] NULL,
	[BurnedCalories] [int] NULL,
	[Date] [datetime] NULL,
	[DailyBurnedCal] [int] NULL,
	[WeeklyBurnedCal] [int] NULL,
	[MonthlyBurnedCal] [int] NULL,
	[QuarterlyBurnedCal] [int] NULL,
	[BMI] [float] NULL,
 CONSTRAINT [PK_tblUserGoal] PRIMARY KEY CLUSTERED 
(
	[UserGoalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserGPSData]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserGPSData](
	[UserGPSDataID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserDeviceID] [numeric](18, 0) NOT NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[Speed] [float] NULL,
	[timestamp] [datetime] NULL,
 CONSTRAINT [PK_tblUserGPSData] PRIMARY KEY CLUSTERED 
(
	[UserGPSDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserPreferredActivities]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserPreferredActivities](
	[UserPreferredActivityID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[ActivityID] [int] NOT NULL,
	[PreferenceLevelID] [int] NULL,
 CONSTRAINT [PK_tblUserPreferredActivities] PRIMARY KEY CLUSTERED 
(
	[UserPreferredActivityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserPreferredLocation]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserPreferredLocation](
	[UserPreferredLocationID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[LocationLabel] [varchar](500) NULL,
	[LocationDescription] [varchar](500) NULL,
 CONSTRAINT [PK_tblUserPreferredLocation] PRIMARY KEY CLUSTERED 
(
	[UserPreferredLocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserRecognizedActivity]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserRecognizedActivity](
	[UserRecognizedActivityID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[ActivityID] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Duration] [int] NULL,
 CONSTRAINT [PK_tblUserRecognizedActivity] PRIMARY KEY CLUSTERED 
(
	[UserRecognizedActivityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserRecognizedActivityAccumulate]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserRecognizedActivityAccumulate](
	[UserRecognizedActivityAccumulateID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[ActivityID] [int] NULL,
	[ActivityDate] [datetime] NULL,
	[Duration] [int] NULL,
 CONSTRAINT [PK_tblUserRecognizedActivityAccumulate] PRIMARY KEY CLUSTERED 
(
	[UserRecognizedActivityAccumulateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserRecognizedActivityLog]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserRecognizedActivityLog](
	[UserRecognizedActivityLogID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[ActivityID] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Duration] [int] NULL,
 CONSTRAINT [PK_tblUserRecognizedActivityLog] PRIMARY KEY CLUSTERED 
(
	[UserRecognizedActivityLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUserRecognizedEmotion]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserRecognizedEmotion](
	[UserRecognizedEmotionID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[EmotionLabel] [varchar](100) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Duration] [int] NULL,
 CONSTRAINT [PK_tblUserRecognizedEmotion] PRIMARY KEY CLUSTERED 
(
	[UserRecognizedEmotionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserRecognizedHLC]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserRecognizedHLC](
	[UserRecognizedHLCID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[HLCLabel] [varchar](100) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Duration] [int] NULL,
 CONSTRAINT [PK_tblUserRecognizedHLC] PRIMARY KEY CLUSTERED 
(
	[UserRecognizedHLCID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserRewards]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserRewards](
	[UserRewardID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NOT NULL,
	[RewardPoints] [int] NULL,
	[RewardDescription] [varchar](100) NULL,
	[RewardDate] [datetime] NULL,
	[RewardTypeID] [int] NULL,
 CONSTRAINT [PK_tblUserRewards] PRIMARY KEY CLUSTERED 
(
	[UserRewardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserRiskFactors]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserRiskFactors](
	[UserRiskFactorID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NULL,
	[RiskFactorID] [int] NULL,
	[StatusID] [int] NULL,
 CONSTRAINT [PK_tblUserFactors] PRIMARY KEY CLUSTERED 
(
	[UserRiskFactorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUsers]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUsers](
	[UserID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](200) NULL,
	[LastName] [varchar](200) NULL,
	[MiddleName] [varchar](200) NULL,
	[GenderID] [int] NULL,
	[DateOfBirth] [datetime] NULL,
	[ContactNumber] [varchar](50) NULL,
	[EmailAddress] [varchar](100) NULL,
	[Password] [varchar](50) NULL,
	[MaritalStatusID] [int] NULL,
	[ActivityLevelID] [int] NULL,
	[OccupationID] [int] NULL,
	[UserTypeID] [int] NULL,
 CONSTRAINT [PK_tblUsers] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUserSchedule]    Script Date: 12/18/2016 12:04:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUserSchedule](
	[UserScheduleID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[UserID] [numeric](18, 0) NULL,
	[ScheduledTask] [varchar](500) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Extra] [varchar](500) NULL,
 CONSTRAINT [PK_tblUserSchedule] PRIMARY KEY CLUSTERED 
(
	[UserScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[tblActivityPlan]  WITH CHECK ADD  CONSTRAINT [FK_tblActivityPlan_tblUserGoal] FOREIGN KEY([UserGoalID])
REFERENCES [dbo].[tblUserGoal] ([UserGoalID])
GO
ALTER TABLE [dbo].[tblActivityPlan] CHECK CONSTRAINT [FK_tblActivityPlan_tblUserGoal]
GO
ALTER TABLE [dbo].[tblActivityRecommendation]  WITH CHECK ADD  CONSTRAINT [FK_tblActivityRecommendation_tblActivityPlan] FOREIGN KEY([ActivityPlanID])
REFERENCES [dbo].[tblActivityPlan] ([ActivityPlanID])
GO
ALTER TABLE [dbo].[tblActivityRecommendation] CHECK CONSTRAINT [FK_tblActivityRecommendation_tblActivityPlan]
GO
ALTER TABLE [dbo].[tblDevice]  WITH CHECK ADD  CONSTRAINT [FK_tblDevice_lkptDeviceType] FOREIGN KEY([DeviceTypeID])
REFERENCES [dbo].[lkptDeviceType] ([DeviceTypeID])
GO
ALTER TABLE [dbo].[tblDevice] CHECK CONSTRAINT [FK_tblDevice_lkptDeviceType]
GO
ALTER TABLE [dbo].[tblPhysiologicalFactors]  WITH CHECK ADD  CONSTRAINT [FK_tblPhysiologicalFactors_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblPhysiologicalFactors] CHECK CONSTRAINT [FK_tblPhysiologicalFactors_tblUsers]
GO
ALTER TABLE [dbo].[tblUserAcceleromaterData]  WITH CHECK ADD  CONSTRAINT [FK_tblUserAcceleromaterData_tblUserDevice] FOREIGN KEY([UserDeviceID])
REFERENCES [dbo].[tblUserDevice] ([UserDeviceID])
GO
ALTER TABLE [dbo].[tblUserAcceleromaterData] CHECK CONSTRAINT [FK_tblUserAcceleromaterData_tblUserDevice]
GO
ALTER TABLE [dbo].[tblUserAddress]  WITH CHECK ADD  CONSTRAINT [FK_tblUserAddress_lkptAddressType] FOREIGN KEY([AddressTypeID])
REFERENCES [dbo].[lkptAddressType] ([AddressTypeID])
GO
ALTER TABLE [dbo].[tblUserAddress] CHECK CONSTRAINT [FK_tblUserAddress_lkptAddressType]
GO
ALTER TABLE [dbo].[tblUserAddress]  WITH CHECK ADD  CONSTRAINT [FK_tblUserAddress_lkptCity] FOREIGN KEY([CityID])
REFERENCES [dbo].[lkptCity] ([CityID])
GO
ALTER TABLE [dbo].[tblUserAddress] CHECK CONSTRAINT [FK_tblUserAddress_lkptCity]
GO
ALTER TABLE [dbo].[tblUserAddress]  WITH CHECK ADD  CONSTRAINT [FK_tblUserAddress_lkptCountry] FOREIGN KEY([CountryID])
REFERENCES [dbo].[lkptCountry] ([CountryID])
GO
ALTER TABLE [dbo].[tblUserAddress] CHECK CONSTRAINT [FK_tblUserAddress_lkptCountry]
GO
ALTER TABLE [dbo].[tblUserAddress]  WITH CHECK ADD  CONSTRAINT [FK_tblUserAddress_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUserAddress] CHECK CONSTRAINT [FK_tblUserAddress_tblUsers]
GO
ALTER TABLE [dbo].[tblUserDetectedLocation]  WITH CHECK ADD  CONSTRAINT [FK_tblUserDetectedLocation_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUserDetectedLocation] CHECK CONSTRAINT [FK_tblUserDetectedLocation_tblUsers]
GO
ALTER TABLE [dbo].[tblUserDevice]  WITH CHECK ADD  CONSTRAINT [FK_tblUserDevice_tblDevice] FOREIGN KEY([DeviceID])
REFERENCES [dbo].[tblDevice] ([DeviceID])
GO
ALTER TABLE [dbo].[tblUserDevice] CHECK CONSTRAINT [FK_tblUserDevice_tblDevice]
GO
ALTER TABLE [dbo].[tblUserDevice]  WITH CHECK ADD  CONSTRAINT [FK_tblUserDevice_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUserDevice] CHECK CONSTRAINT [FK_tblUserDevice_tblUsers]
GO
ALTER TABLE [dbo].[tblUserFacilities]  WITH CHECK ADD  CONSTRAINT [FK_tblUserFacilities_lkptFacitlity] FOREIGN KEY([FacitlityID])
REFERENCES [dbo].[lkptFacitlity] ([FacitlityID])
GO
ALTER TABLE [dbo].[tblUserFacilities] CHECK CONSTRAINT [FK_tblUserFacilities_lkptFacitlity]
GO
ALTER TABLE [dbo].[tblUserFacilities]  WITH CHECK ADD  CONSTRAINT [FK_tblUserFacilities_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUserFacilities] CHECK CONSTRAINT [FK_tblUserFacilities_tblUsers]
GO
ALTER TABLE [dbo].[tblUserGoal]  WITH CHECK ADD  CONSTRAINT [FK_tblUserGoal_lkptWeightStatus] FOREIGN KEY([WeightStatusID])
REFERENCES [dbo].[lkptWeightStatus] ([WeightStatusID])
GO
ALTER TABLE [dbo].[tblUserGoal] CHECK CONSTRAINT [FK_tblUserGoal_lkptWeightStatus]
GO
ALTER TABLE [dbo].[tblUserGoal]  WITH CHECK ADD  CONSTRAINT [FK_tblUserGoal_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUserGoal] CHECK CONSTRAINT [FK_tblUserGoal_tblUsers]
GO
ALTER TABLE [dbo].[tblUserGPSData]  WITH CHECK ADD  CONSTRAINT [FK_tblUserGPSData_tblUserDevice] FOREIGN KEY([UserDeviceID])
REFERENCES [dbo].[tblUserDevice] ([UserDeviceID])
GO
ALTER TABLE [dbo].[tblUserGPSData] CHECK CONSTRAINT [FK_tblUserGPSData_tblUserDevice]
GO
ALTER TABLE [dbo].[tblUserPreferredActivities]  WITH CHECK ADD  CONSTRAINT [FK_tblUserPreferredActivities_lkptActivities] FOREIGN KEY([ActivityID])
REFERENCES [dbo].[lkptActivities] ([ActivityID])
GO
ALTER TABLE [dbo].[tblUserPreferredActivities] CHECK CONSTRAINT [FK_tblUserPreferredActivities_lkptActivities]
GO
ALTER TABLE [dbo].[tblUserPreferredActivities]  WITH CHECK ADD  CONSTRAINT [FK_tblUserPreferredActivities_lkptPreferenceLevel] FOREIGN KEY([PreferenceLevelID])
REFERENCES [dbo].[lkptPreferenceLevel] ([PreferenceLevelID])
GO
ALTER TABLE [dbo].[tblUserPreferredActivities] CHECK CONSTRAINT [FK_tblUserPreferredActivities_lkptPreferenceLevel]
GO
ALTER TABLE [dbo].[tblUserPreferredActivities]  WITH CHECK ADD  CONSTRAINT [FK_tblUserPreferredActivities_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUserPreferredActivities] CHECK CONSTRAINT [FK_tblUserPreferredActivities_tblUsers]
GO
ALTER TABLE [dbo].[tblUserRecognizedActivity]  WITH CHECK ADD  CONSTRAINT [FK_tblUserRecognizedActivity_lkptActivities] FOREIGN KEY([ActivityID])
REFERENCES [dbo].[lkptActivities] ([ActivityID])
GO
ALTER TABLE [dbo].[tblUserRecognizedActivity] CHECK CONSTRAINT [FK_tblUserRecognizedActivity_lkptActivities]
GO
ALTER TABLE [dbo].[tblUserRecognizedActivity]  WITH CHECK ADD  CONSTRAINT [FK_tblUserRecognizedActivity_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUserRecognizedActivity] CHECK CONSTRAINT [FK_tblUserRecognizedActivity_tblUsers]
GO
ALTER TABLE [dbo].[tblUserRewards]  WITH CHECK ADD  CONSTRAINT [FK_tblUserRewards_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUserRewards] CHECK CONSTRAINT [FK_tblUserRewards_tblUsers]
GO
ALTER TABLE [dbo].[tblUserRiskFactors]  WITH CHECK ADD  CONSTRAINT [FK_tblUserRiskFactors_lkptRiskFactor] FOREIGN KEY([RiskFactorID])
REFERENCES [dbo].[lkptRiskFactor] ([RiskFactorID])
GO
ALTER TABLE [dbo].[tblUserRiskFactors] CHECK CONSTRAINT [FK_tblUserRiskFactors_lkptRiskFactor]
GO
ALTER TABLE [dbo].[tblUserRiskFactors]  WITH CHECK ADD  CONSTRAINT [FK_tblUserRiskFactors_lkptStatus] FOREIGN KEY([StatusID])
REFERENCES [dbo].[lkptStatus] ([StatusID])
GO
ALTER TABLE [dbo].[tblUserRiskFactors] CHECK CONSTRAINT [FK_tblUserRiskFactors_lkptStatus]
GO
ALTER TABLE [dbo].[tblUserRiskFactors]  WITH CHECK ADD  CONSTRAINT [FK_tblUserRiskFactors_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUserRiskFactors] CHECK CONSTRAINT [FK_tblUserRiskFactors_tblUsers]
GO
ALTER TABLE [dbo].[tblUsers]  WITH CHECK ADD  CONSTRAINT [FK_tblUsers_lkptActivityLevel] FOREIGN KEY([ActivityLevelID])
REFERENCES [dbo].[lkptActivityLevel] ([ActivityLevelID])
GO
ALTER TABLE [dbo].[tblUsers] CHECK CONSTRAINT [FK_tblUsers_lkptActivityLevel]
GO
ALTER TABLE [dbo].[tblUsers]  WITH CHECK ADD  CONSTRAINT [FK_tblUsers_lkptGender] FOREIGN KEY([GenderID])
REFERENCES [dbo].[lkptGender] ([GenderID])
GO
ALTER TABLE [dbo].[tblUsers] CHECK CONSTRAINT [FK_tblUsers_lkptGender]
GO
ALTER TABLE [dbo].[tblUsers]  WITH CHECK ADD  CONSTRAINT [FK_tblUsers_lkptMaritalStatus] FOREIGN KEY([MaritalStatusID])
REFERENCES [dbo].[lkptMaritalStatus] ([MaritalStatusID])
GO
ALTER TABLE [dbo].[tblUsers] CHECK CONSTRAINT [FK_tblUsers_lkptMaritalStatus]
GO
ALTER TABLE [dbo].[tblUsers]  WITH CHECK ADD  CONSTRAINT [FK_tblUsers_lkptOccupation] FOREIGN KEY([OccupationID])
REFERENCES [dbo].[lkptOccupation] ([OccupationID])
GO
ALTER TABLE [dbo].[tblUsers] CHECK CONSTRAINT [FK_tblUsers_lkptOccupation]
GO
