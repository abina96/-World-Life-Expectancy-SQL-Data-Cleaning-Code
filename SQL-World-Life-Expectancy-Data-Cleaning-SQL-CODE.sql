#World Life Expectancy Project (Data Cleaning)
#On this project we are doing the data cleaning portion. 

SELECT * 
FROM world_life_expectancy
;

#On the first step we are determining if there is any duplicate records. We can concatanate country and year column to create a new unique column. By creating a new unique column we can identify the duplicate records and delete if any exists.

#The following query will show any 'CountryYear' combination that have more than 1 count i.e Duplicate records. Here we are using the aggregate function and applying filter on the aggregate function with having clause.

SELECT Country,Year, CONCAT(Country,Year), COUNT(CONCAT(Country,Year))
FROM world_life_expectancy
GROUP BY Country,Year, CONCAT(Country,Year)
HAVING COUNT(CONCAT(Country,Year)) > 1
;

#Now that we have identified duplicate records we need to remove the duplicate records. This data set have a ROW_ID column which are unique, we need to identify the duplicates in the ROW_ID then we can remove them. Here were are using the window function'row_number' and 'partition by'. We already have a ROW_ID, we can use the row_number based of off the 'CONCAT(Country,Year)'. The following window function will assign row_number and partition the result by CONCAT(Country,Year). The row number will give each of the duplicates count of 2 which then we can delete them. On the last step we are using filter with the use of subquery on the From Statement.


SELECT *
FROM(
SELECT ROW_ID,
CONCAT(Country,Year),
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country,Year)) as Row_Num
FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1
;

# Finally we are using the following query to delete the duplicates.

DELETE FROM world_life_expectancy
WHERE
	ROW_ID IN (
    SELECT ROW_ID
FROM(
SELECT ROW_ID,
CONCAT(Country,Year),
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country,Year) ORDER BY CONCAT(Country,Year)) as Row_Num
FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1
)
;

# On this step we will identify the blank columns and determine if we can populate records on those fields. The table shows there are missing data in Status column. We can identify the countries that already shows the Status, we can use field from the year column and the country column that has the status and plug the status to the blank ones. 

#This query will display Status column where the value is blank.
SELECT *
FROM world_life_expectancy
WHERE Status = ''
;

#This query will display distinct status where it is not blank.
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE status <> ''
;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status ='Developing';


#We will use the following self join query to update the blank fields for all countries.

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country= t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status ='Developing'
;
    
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country= t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status ='Developed'
;

#On this step we are looking at the Life expectancy column that has blank fields. Since we have data of the previous year and next year we can take the average of previous year and this year and update the result on the blank column. Here we are using the self join and update query.

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy`+ t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
    WHERE t1.`life expectancy` = ''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1 
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy`+ t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;

SELECT *
FROM 
world_life_expectancy;

