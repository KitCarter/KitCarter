select a.areaname, t.teamname, count(*)  NoTeams from 
dl.dimTeam t Join dl.DimArea A on A.AreaID = T.AreaID
Where t.TeamEndDate is null

Group by cube(A.AreaName, T.TeamName)
