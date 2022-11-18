-- I cleaned some of the data via Excel prior to importing to SQL Server. Actions taken include rounding down any animal's age to the year vs the year and month & removing rows with incomplete data

SELECT * from AnimalAdoptions..Adoptions
WHERE animal_type like 'cat' 
OR animal_type like 'dog'

--Viewing adoption counts based on the color of the cat or dog

SELECT animal_type, primary_color, count(primary_color) as Number_of_adoptions from AnimalAdoptions..Adoptions
WHERE animal_type like 'cat' 
OR animal_type like 'dog'
GROUP BY primary_color, animal_type
ORDER BY Number_of_adoptions desc

--Viewing adoption counts based on animal age
SELECT animal_type, animal_age, count(animal_age) as Number_of_adoptions from AnimalAdoptions..Adoptions
WHERE animal_type like 'cat' 
OR animal_type like 'dog'
GROUP BY animal_age, animal_type
ORDER BY animal_age desc

--Viewing adoption counts based on animal size
SELECT animal_type, animal_size, count(animal_size) as Number_of_adoptions from AnimalAdoptions..Adoptions
WHERE animal_type like 'cat' 
OR animal_type like 'dog'
AND animal_size is not NULL
GROUP BY animal_size, animal_type
ORDER BY Number_of_adoptions desc


--Showing adoptions of animals with their age set to weeks

SELECT * from AnimalAdoptions..Adoptions
WHERE  animal_type like 'cat' 
AND animal_age LIKE '%weeks'
OR animal_type like 'dog'
AND animal_age LIKE '%weeks'


--Converting animal_age from weeks/months/years to just years for easier visualization
SELECT animal_type, animal_age,
CASE
	WHEN animal_age LIKE '%year%' THEN CAST(LEFT(animal_age, 2) as int)
	WHEN animal_age LIKE '%month%' THEN ROUND((CAST(LEFT(animal_age, 2) as float)/12),2)
	WHEN animal_age LIKE '%weeks%' THEN ROUND((CAST(LEFT(animal_age, 2) as float)/52),2)
	ELSE NULL
END as years_old
from AnimalAdoptions..Adoptions
WHERE animal_type like 'cat' 
OR animal_type like 'dog';

--Adding new column to document years old calcuation
ALTER TABLE AnimalAdoptions..Adoptions
ADD years_old FLOAT;

UPDATE AnimalAdoptions..Adoptions
SET years_old = CASE
	WHEN animal_age LIKE '%year%' THEN CAST(LEFT(animal_age, 2) as int)
	WHEN animal_age LIKE '%month%' THEN ROUND((CAST(LEFT(animal_age, 2) as float)/12),2)
	WHEN animal_age LIKE '%weeks%' THEN ROUND((CAST(LEFT(animal_age, 2) as float)/52),2)
	ELSE NULL
END;


SELECT animal_type, years_old, count(years_old) as count
FROM AnimalAdoptions..Adoptions
GROUP by years_old, animal_type
ORDER BY count desc

--Grouping ages for animals less than 1 year old 

UPDATE AnimalAdoptions..Adoptions
SET years_old = CASE
	WHEN years_old > .75 AND years_old < 1 THEN 1
	WHEN years_old < .75 AND years_old > .5 THEN .75
	WHEN years_old < .5 AND years_old > .25 THEN .5
	WHEN years_old < .25  THEN .25
	ELSE years_old
END;


Select animal_type, count(animal_type) as count
from AnimalAdoptions..Adoptions
group by animal_type


--Viewing adoptions based on breed of cat

SELECT Primary_breed, animal_type, count(Primary_breed) as count
from AnimalAdoptions..Adoptions
WHERE animal_type LIKE 'CAT'
GROUP BY primary_breed, animal_type

-- Viewing adoptions based on breed of dog
SELECT Primary_breed, animal_type, count(Primary_breed) as count
from AnimalAdoptions..Adoptions
WHERE animal_type LIKE 'DOG'
GROUP BY primary_breed, animal_type