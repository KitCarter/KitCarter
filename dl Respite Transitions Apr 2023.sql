
--Temp1 = All Respite Referrals in the date range
select tf.teamFunctionCode 'Respite', r.personID, p.PersonReferenceNumber NHI, r.referralID, a.AreaName, t.teamName, r.ReferralReceivedDate RecDate,r.referralEndDate EndDate

into #Temp1

from  DL.FactReferral R 
Join dataset.person P on P.PersonID = R.PersonID
Join Dl.DimTeam T on T.TeamID = R.TeamID
JOin DL.DimArea A on T.AreaID = A.AreaID
Join dl.DimTeamFunction TF on TF.TeamFunctionID = T.TeamFunctionID

where /*A.areaname in ('Auckland') and */ tf.TeamFunctionCode in ('RS') and
 R.ReferralReferralType = 'InboundReferral' and ((R.ReferralReceivedDate between '2022-01-01 00:00:00' and '2022-12-31 23:59:59'))


 -- Temp2 = All Mobile Activities in the 1 year +/- 7 days
select tf.teamFunctionCode 'Mobile', r.personID, fa.activityID,r.referralID, A.AreaName, t.teamName, r.ReferralReceivedDate RecDate,r.referralEndDate EndDate,
--AT.ActivityTypeName ActivityType, AC.ActivityClassificationName Class, ABT.activitybreakdowntypename BreakName,
ABT.activityBreakdowntypecode BreakType,
FA.activityStartDate ActStart,FA.ActivityEndDate ActEnd,UP.Clinical,activitybreakdownDuration Mins,case when ActivityWhanauInvolvement = 1 then 'Y' else 'N' end Whanau,
year(activityStartDate) [Year],month(activityStartDate) [Month],datepart(weekday,activityStartDate) [Weekday], day(activityStartDate) [Day], datepart(hour,activityStartDate) [Hour]

Into #Temp2
from dl.FactactivityBreakdown AB
Join dl.FactActivity FA on FA.ActivityID = AB.ActivityID
Join dl.DimUser U on U.UserID = FA.ActivityCreatedUserID
Join dl.DimActivityBreakdownType ABT on ABT.ActivityBreakdownTypeID = AB.ActivityBreakdownTypeID -- and ABT.ActivityBreakdownTypeCode in ('FTF','GFTF')
Join dl.FactActivityParticipant AP on AP.ActivityID = AB.ActivityID and ActivityParticipantEntityType = 'Person' 
Join Dl.DimTeam T on T.TeamID = FA.TeamID
JOin DL.DimArea A on T.AreaID = A.AreaID
Join dl.DimTeamFunction TF on TF.TeamFunctionID = T.TeamFunctionID
Join Dataset.Person P on P.PersonID = AP.EntityID
Join DL.FactReferral R on R.PersonID = P.PersonID and R.ReferralReferralType = 'InboundReferral' and ((R.ReferralEndDate is Null or R.ReferralEndDate between '2022-01-01 00:00:00' and '2022-12-31 23:59:59') )and AP.ReferralID = R.ReferralID
Join pvt.FactUserCustomfieldDataPivot UP on UP.UserID = FA.ActivityCreatedUserID
Join dl.DimActivityType AT on AT.ActivityTypeID = FA.ActivityTypeID
Join dl.DimActivityClassification AC on AC.ActivityClassificationID = FA.ActivityClassificationID

where (ActivityStartDate >= '2021-12-24 00:00:00' and activityStartDate < '2023-01-08 00:00:00') and Tf.TeamFunctionCode = 'MO'

--#Temp3  aggregates and segments Mobile activities by date slice

 Select Respite,T1.ReferralID,T1.PersonID,T1.NHI,T1.AreaName RespArea, T1.TeamName RespTeam,T1.RecDate,T1.EndDate, T2.MObile, T2.ActivityID,T2.TeamNAme MobTeam,T2.RecDate MobRec, T2.EndDate MobEnd,T2.BreakType,T2.ActStart,T2.ActEnd
 Into #Temp3 
  from #Temp1 T1 Left Join #Temp2 T2 on T2.PersonID = T1.PersonID

 Select Respite, PersonID, ReferralID, NHI,RespArea, RespTeam,MobTeam,RecDate,EndDate, MobRec,MobEnd,BreakType,ActStart,ActEnd,
 Case when Actstart is null then 1 else NULL end NoMobile,
 Case when ActStart between RecDate and EndDate then 1 else NULL end Overlap,
  Case when ActStart between DATEADD(week,-1,RecDate) and RecDate then 1 else Null end WeekPrior,
 Case when ActStart between DATEADD(week,-2,RecDate) and DATEADD(week,-1,RecDate) then 1 else NULL end FortPrior,
 Case when ActStart between EndDate and DATEADD(week,1,EndDate) then 1  else NULL end WeekAfter,
 Case when ActStart between DATEADD(week,1,EndDate) and DATEADD(week,2,DATEADD(week,1,EndDate)) then 1  else NULL end FortAfter

 Into #Temp4

 From #Temp3

--@Temp4 summarises at Respite level the activites - counts
 Select ReferralID, max(PersonID) PersonID, Max(NHI) NHI,max(RespArea) Area, max(RespTeam) Team,max(RecDate) RecDate, Max(EndDate) EndDate,Sum(NoMobile) NoMob, Sum(FortPrior) FortPrior,Sum(WeekPrior) WeekPrior,sum(Overlap) Overlap,
Sum(WeekAfter) WeekAfter,Sum(FortAfter) FortAfter

 from #Temp4

 Group by ReferralID


 Drop Table #Temp1
 Drop Table #Temp2
 Drop Table #Temp3
 Drop Table #Temp4
