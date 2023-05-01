
--the team against which the client has the most activities recorded is the team to pick

select P.ID, P.ReferenceNumber, DF.QId, DF.QText, D.FormID, D.response,
D.value, D.valueText, D.Text, D.CalculationName, D.CalulatedValue, C.Team, C.Area

From FactDynamicFormDefinition DF
Inner join	FactDynamicFormData D on D.TemplateID = DF.FormID and D.QID = DF.QId and DF.Title like '%APQ%'
Inner join	DimClient P on P.ID = D.EntityID
Inner Join
              (select * from (
                                  select team.name as 'Team', area.Name as 'Area', company.CompanyName as 'Company', client.*, row_number() over (partition by client.ID order by activities.ActivityCount desc) [ActivityRank]
                                  from dimclient client
                                  join FactReferral referral on client.ID = referral.PersonID
                                  join ( select r.ID [ReferralID], count(*) [ActivityCount]
                                         from FactActivityClient ac
                                         join FactReferral r on ac.ReferralID = r.ID
                                         join FactActivityUser au on au.ActivityID = ac.ActivityID
                                         group by r.ID
                                         ) activities on referral.ID = activities.ReferralID
                                  join stage_team team on team.ID = referral.TeamID
                                  join DimArea area on area.ID = team.AreaID
                                  join dimCompany company on company.ID = team.CompanyID
                                  ) base 
              where ActivityRank = 1 ) c
on P.Id=c.Id
