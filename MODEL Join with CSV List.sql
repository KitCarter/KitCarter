
--This is Elite version
select T1.PersonID,
    stuff((select ',' + CAST(t3.Text as varchar(50))
     from FactPersonMentalHealthCondition t2 JOIN
     DIMMentalHealthConditionTYpe T3 on T2.MentalHealthConditionID = T3.ID
      where t1.Personid = t2.Personid 
     for xml path('')),1,1,'') MHCondition
from FactpersonMentalHealthCondition t1
group by T1.PersonID

--This is Live version
select MH1.PersonID,
    stuff((select ',' + CAST(MH3.Text as varchar(50))
     from PersonMentalHealthCondition MH2 JOIN
     [Lookup] MH3 on MH2.MentalHealthConditionID = MH3.ID and MH3.DeletedDate is NUll
      where MH1.Personid = MH2.Personid 
     for xml path('')),1,1,'') MHCondition
from PersonMentalHealthCondition MH1
group by MH1.PersonID
