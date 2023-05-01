
DECLARE @MHCondition varchar(200) 
SELECT @MHCondition = COALESCE(@MHCondition + ', ', '') + CAST(MentalHealthConditionID AS varchar(5))
FROM FactPersonMentalHealthCondition
WHERE PersonID = 123263

SELECT @MHCondition MHCondition


select * from DimClient where Lastname like '%Name%' 123263
Select * from FactPersonMentalHealthCondition where PersonID = 123263