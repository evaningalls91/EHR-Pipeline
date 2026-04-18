-- Total Number of Patients --
SELECT COUNT(*)
FROM patients;

-- Gender Breakdown --
SELECT gender, COUNT(*) AS total
FROM patients
GROUP BY gender;

-- Top 10 Most Common Encounter Types --
SELECT description, COUNT(*) AS total
FROM encounters
GROUP BY description
ORDER BY total DESC
LIMIT 10;

-- Total Encounters by Patient --
SELECT p.id, p.gender, p.birthdate,
COUNT(e.id) AS total_encounters
FROM patients p
LEFT JOIN encounters e ON p.id = e.patient
GROUP BY p.id, p.gender, p.birthdate
ORDER BY total_encounters DESC;

-- Most Common Conditions by Gender --
SELECT p.gender, c.description, COUNT(*) AS total
FROM conditions c
JOIN patients p ON c.patient = p.id
GROUP BY p.gender, c.description
ORDER BY total DESC
LIMIT 20;

-- Rank Patient by Encounters
SELECT 
	patient, 
	COUNT(*) AS encounters_total,
	RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
FROM encounters
GROUP BY patient;

-- Patient's Most Recent Encounter
SELECT DISTINCT ON (patient)
	patient,
	start,
	description
FROM encounters
ORDER BY patient, start DESC;

-- Create Analytics View

-- displays patient: 
	-- id, gender, race, 
	-- city, state, age, 
	-- total_encounters, last encounter
	-- unique conditions, 

CREATE VIEW patient_summary AS
SELECT
    p.id,
    p.gender,
    p.race,
    p.city,
    p.state,
    DATE_PART('year', AGE(CURRENT_DATE, p.birthdate)) AS age,
    COUNT(DISTINCT e.id) AS total_encounters,
    COUNT(DISTINCT c.code) AS unique_conditions,
    MAX(e.start) AS last_encounter_date
FROM patients p
LEFT JOIN encounters e ON p.id = e.patient
LEFT JOIN conditions c ON p.id = c.patient
GROUP BY p.id, p.gender, p.race, p.city, p.state, p.birthdate;

-- Select View
SELECT * FROM patient_summary;