select a.areaname, t.teamname, t.Teamid,
avg(t.TeamID) over (partition by AreaName) AverageVal

From dl.DimTeam T join dl.DimArea A on A.AreaID = T.AreaID

Where t.teamEndDate is null