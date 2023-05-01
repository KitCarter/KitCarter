Declare @StartDate DateTime
Declare @EndDate DateTime
Set @StartDate = '2013-01-01'
Set @EndDate = getdate()

select LR.[Type],LR.StartDate,LR.EndDate,LR.TotalHours, LR.StatusCode, E.FirstName, E.Lastname, LR.EmployeeCode, E.Region

Into #Temp1

from LeaveRequest LR JOIN 
Employee E on E.code = LR.EmployeeCode

where LR.StartDate BETWEEN @StartDate and @EndDate
AND LR.StatusCode = 'Approved'

select EmployeeCode, Max(Occupation) Occupation
Into #Temp2
 from (
    Select
        EmployeeCode, Occupation, StartDate,
        Rank() over (partition by EmployeeCode order by StartDate Desc) RankOrder
    From Position where CompanyCode = 7693
) T
where RankOrder = 1 

Group by EmployeeCode

Select Type, StartDate,EndDate,TotalHours, StatusCode, FirstName, Lastname, Region, Occupation From #Temp1 T1 join #Temp2 T2 on T2.EmployeeCode = T1.EmployeeCode

Drop Table #Temp1
Drop Table #Temp2


