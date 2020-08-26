
 /*
 List all providers who are nurses showing the provider's name.
 Tables needed: providers
 Your result set should have two rows.
*/

select p.provider_nm
from edw_emr_ods.providers p
where p.title = 'RN'


/*
List all departments in the system sorted alphabetically by the department's name.
Table needed: departments.
Your result set should have five rows.
*/

SELECT department_nm
FROM [edw_emr_ods].[departments]
ORDER BY [department_nm] 
/*
List the two oldest patients showing a patient's name and date of birth.
Table needed: patients.
Your result set should have two rows.
*/
SELECT TOP 2 [patient_nm],[dob]
FROM [edw_emr_ods].[patients]
ORDER BY [dob] DESC
 
/*
List all encounters that are scheduled to take place in the future showing the encounter ID and its date.
Table needed: encounters
Your result set should return zero rows.
*/
SELECT [encounter_id],[start_dts]
FROM [edw_emr_ods].[encounters]
WHERE [start_dts] > GETDATE() 

/*
List all patients showing the patient's name, his/her gender (e.g. Male/Female), and a gender abbreviation (e.g. M for Male).
Tables needed: patients, gender_codes.
Your result set should have four rows.
*/
SELECT p.patient_nm, g.gender_title, 
CASE WHEN g.gender_title = 'Male' THEN 'M' WHEN g.gender_title = 'FEMALE' THEN 'F' ELSE ' ' END as gender_abb
FROM [edw_emr_ods].[patients] p
LEFT JOIN [edw_emr_ods].[gender_codes] g
ON p.[gender_cd] = g.gender_code_id

/*
For the patient Cosmo Kramer, list all his diagnoses showing the diagnosis code, title, and date of diagnosis.
The most recent diagnosis should be listed first.
Tables needed: diagnoses, patients, encounters, encounter_diagnoses.
Your result set should have eight rows.
*/
SELECT p.patient_nm, d.code, d.title, enc.start_dts 
FROM [edw_emr_ods].[patients] p
JOIN [edw_emr_ods].[encounters] enc
ON p.patient_id = enc.patient_id
JOIN [edw_emr_ods].[encounter_diagnoses] enc_d
ON enc.encounter_id = enc_d.encounter_id
JOIN [edw_emr_ods].[diagnoses] d
ON enc_d.diagnosis_id = d.diagnosis_id
WHERE p.patient_nm = 'Cosmo Kramer'
ORDER BY enc.start_dts DESC

/*
List patients seen by Dr. Julia Hibbert showing the patient's name, number of times seen, date of the last visit, and how many days have passed since the last visit.
Tables needed: patients, providers, encounters.
Your result set should have two rows.
*/
SELECT x.patient_nm, x.numb_seen as num_seen, x.last_visit, DATEDIFF(DAY, x.last_visit, GETDATE()) AS days_since_last_visit ,
DENSE_RANK () OVER (PARTITION BY x.patient_nm ORDER BY x.last_visit DESC) AS rnk
FROM (
SELECT p.patient_nm, COUNT(e.patient_id) AS numb_seen, e.start_dts AS last_visit
FROM patients p
JOIN encounters e 
ON p.patient_id = e.patient_id
JOIN providers pr
ON e.provider_id = pr.provider_id
WHERE pr.provider_nm ='Julia Hibbert'
GROUP BY p.patient_nm,e.start_dts) x 


/*
List the first diagnosis for each patient showing the patient's name, diagnosis code and diagnosis date.
If the patient has two or more diagnoses on the earliest date, it's okay to just show one of those diagnoses.
Tables needed: encounters, patients, encounter_diagnoses, diagnoses.
Your result set should have four rows.
*/

SELECT *
FROM(
SELECT p.patient_nm, d.code, enc.start_dts, 
ROW_NUMBER() OVER (PARTITION BY p.patient_nm ORDER BY enc.start_dts) AS rnk
FROM [edw_emr_ods].[patients] p
JOIN [edw_emr_ods].[encounters] enc
ON p.patient_id = enc.patient_id
JOIN [edw_emr_ods].[encounter_diagnoses] enc_d
ON enc.encounter_id = enc_d.encounter_id
JOIN [edw_emr_ods].[diagnoses] d
ON enc_d.diagnosis_id = d.diagnosis_id) x
WHERE rnk = 1

