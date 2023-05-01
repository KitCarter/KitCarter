SELECT DISTINCT
        C.FullName PersonName,
        C.ReferenceNumber ,
        G.Text Gender,
        E1.Text Ethnicity1,
        E2.Text Ethnicity2,
		E3.Text Ethnicity3,
		C.DateOfBirth ,
        A.*,
        T.Name DestinationTeam,
        R.TeamID       
 FROM   DimClient C
 		INNER JOIN FactReferral R ON C.ID = R.PersonID
                                        AND R.IsInbound = 1
		LEFT JOIN DimTeam T ON T.ID = R.TeamID
		LEFT JOIN DimEthnicity E1 on E1.ID = c.Ethnicity1
		LEFT JOIN DimEthnicity E2 on E2.ID = c.Ethnicity2
		LEFT JOIN DimEthnicity E3 on E3.ID = c.Ethnicity3
        LEFT JOIN DimGender G on G.ID = C.GenderID
        INNER JOIN ( SELECT SD.TemplateID, SD.FormID, SD.EntityID [PersonID], CONVERT(datetime, AssessmentDate.Text, 103) [AssessmentDate],Assessor.Text [Assessor], [CollectionOccassion] , [Q1] , [Q2] , [Q3] , [Q4] , [Q5] , [Q6] , [Q7] , [Q8] , [Q9] , [Q10] , [Q11] , [Q12] , QComments.Text [QComments], 
 Prosocial.CalulatedValue Prosocial, Emotional.CalulatedValue Emotional, TotalScore.CalulatedValue TotalScore
FROM (
SELECT FormID, EntityID, TemplateID, CollectionOccassion , [Q1] , [Q2] , [Q3] , [Q4] , [Q5] , [Q6] , [Q7] , [Q8] , [Q9] , [Q10] , [Q11] , [Q12]
FROM
(
SELECT FormID, EntityID, TemplateID, QId, value
FROM FactDynamicFormData WHERE EntityID > 0) AS S
PIVOT
(
 MIN(value)
 FOR QId IN (CollectionOccassion , [Q1] , [Q2] , [Q3] , [Q4] , [Q5] , [Q6] , [Q7] , [Q8] , [Q9] , [Q10] , [Q11] , [Q12])
) as P) AS SD
LEFT OUTER JOIN FactDynamicFormData AssessmentDate ON AssessmentDate.FormID = SD.FormID AND AssessmentDate.QId = 'AssessmentDate'
LEFT OUTER JOIN FactDynamicFormData Assessor ON Assessor.FormID = SD.FormID AND Assessor.QId = 'Assessor'
LEFT OUTER JOIN FactDynamicFormData Prosocial ON Prosocial.FormID = SD.FormID AND Prosocial.QId = 'Prosocial'
LEFT OUTER JOIN FactDynamicFormData Emotional ON Emotional.FormID = SD.FormID AND Emotional.QId = 'Emotional'
LEFT OUTER JOIN FactDynamicFormData TotalScore ON TotalScore.FormID = SD.FormID AND TotalScore.QId = 'TotalScore'
LEFT OUTER JOIN FactDynamicFormData QComments ON QComments.FormID = SD.FormID AND QComments.QId = 'Comments'
WHERE SD.TemplateID IN
 (SELECT FormID FROM FactDynamicFormDefinition WHERE Title like 'Social Competence Scale Parent (P-COMP)%')) A ON C.ID = A.PersonID
 WHERE R.EndDate is null AND A.AssessmentDate > 2018-01-01