-- Step 1: Create the tables
CREATE TABLE Students (
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    gender VARCHAR(10),
    part_time_job BOOLEAN,
    absence_days INT,
    extracurricular_activities BOOLEAN,
    weekly_self_study_hours INT,
    career_aspiration VARCHAR(50),
    math_score INT,
    history_score INT,
    physics_score INT,
    chemistry_score INT,
    biology_score INT,
    english_score INT,
    geography_score INT
);

-- Step 2: Import data using COPY
COPY Students(id, first_name, last_name, email, gender, part_time_job, absence_days, 
	extracurricular_activities, weekly_self_study_hours, career_aspiration, math_score, history_score,
	physics_score, chemistry_score, biology_score, english_score, geography_score) 
FROM '/Applications/PostgreSQL 16/SQL Resources/Data/student-scores.csv' 
DELIMITER ',' CSV HEADER;

-- Step 3: Analyse data
'''
1)Calculate the average math_score for each career_aspiration. Order the results by the average score 
	in descending order.
'''
SELECT 
	career_aspiration,
	AVG(math_score) AS Avg_Math_Score
FROM 
	students
GROUP BY 
	career_aspiration
ORDER BY 
		Avg_Math_Score DESC;

'''
2)Find the career_aspirations that have an average english_score greater than 75. Display the career 
	aspiration and the average score.
'''
SELECT 
	career_aspiration,
	AVG(english_score) AS Avg_Eng_Score
FROM 
	students
GROUP BY 
	career_aspiration
HAVING AVG(english_score) > 75;

'''
3)Identify students who have a math_score higher than the schools average math score. 
	List their first_name, last_name, and math_score.
'''
SELECT 
	first_name,
	last_name,
	math_score
FROM 
	students
WHERE 
	math_score>(SELECT AVG(math_score) FROM students);

'''
4)Rank students within each career_aspiration category by their physics_score in descending order. 
	Display the first_name, last_name, career_aspiration, physics_score, and the rank.
'''
SELECT 
	first_name,
	last_name,
	career_aspiration,
	physics_score, 
	DENSE_RANK() OVER (PARTITION BY career_aspiration ORDER BY physics_score DESC) AS rank
FROM 
	students;

'''
5) For each student, create a new column full_name by concatenating first_name and last_name with a 
space in between. Show the full_name and email columns where the email contains the string "academy".
'''	
SELECT
	first_name || ' ' || last_name AS full_name,
	email
FROM 
	students
WHERE 
	email ILIKE '%academy%';
	
'''
6)Calculate the lowest (FLOOR), highest (CEIL), and average (ROUND to two decimal places) 
chemistry_score for each career aspirant. Display the career aspirants, lowest score, highest score,
and average score.
'''
SELECT 
	career_aspiration, 
    FLOOR(MIN(chemistry_score)) AS min_chemistry_score, 
    CEIL(MAX(chemistry_score)) AS max_chemistry_score, 
    ROUND(AVG(chemistry_score), 2) AS avg_chemistry_score
FROM 
	students
GROUP BY 
	career_aspiration;

'''
7)Find career aspirations where the average history_score is above 85 and at least 5 students aspire 
to that career. List the career_aspiration and the average score.
'''
SELECT 
	career_aspiration, 
	AVG(history_score) AS avg_history_score
FROM 
	students
GROUP BY 
	career_aspiration
HAVING AVG(history_score) > 85 AND COUNT(*) >= 5;

'''
8)Identify students who score above average in both biology and chemistry, compared to the schools 
average for those subjects. Display their id, first_name, last_name, biology_score, and 
chemistry_score.
'''
SELECT
	id,
	first_name,
	last_name,
	biology_score,
	chemistry_score
FROM 
	students
WHERE	
	biology_score>(SELECT AVG(biology_score) FROM students) 
	AND chemistry_score>(SELECT AVG(chemistry_score) FROM students);

'''
9)Calculate the percentage of absence days for each student relative to the total absence days 
recorded for all students. Display the id, first_name, last_name, and the calculated percentage, 
rounded to two decimal places. Order the results by the percentage in descending order
'''
WITH TotalAbsence AS (
    SELECT SUM(absence_days) AS total_absence
    FROM Students
)
SELECT 
	id, 
	first_name, 
	last_name, 
    ROUND((CAST(absence_days AS DECIMAL) / (SELECT total_absence FROM TotalAbsence))*100, 2) AS absence_percentage
FROM Students
ORDER BY absence_percentage DESC;

'''
10)Identify students who have scores above 80 in at least three out of the six subjects: math, history
, physics, chemistry, biology, and English. Display their id, first_name, last_name, and the count of 
subjects where they scored above 80.	
'''
WITH SubjectCounts AS (
    SELECT id, first_name, last_name, 
           (CASE WHEN math_score > 80 THEN 1 ELSE 0 END +
            CASE WHEN history_score > 80 THEN 1 ELSE 0 END +
            CASE WHEN physics_score > 80 THEN 1 ELSE 0 END +
            CASE WHEN chemistry_score > 80 THEN 1 ELSE 0 END +
            CASE WHEN biology_score > 80 THEN 1 ELSE 0 END +
            CASE WHEN english_score > 80 THEN 1 ELSE 0 END) AS subjects_above_80
    FROM Students
)
SELECT id, first_name, last_name, subjects_above_80
FROM SubjectCounts
WHERE subjects_above_80 >= 3;