
---------------------DATA CLEANING AND EXPLORATION THROUGH VARIOUS SQL QUERIES---------------------------------

CREATE TABLE year
(ride_id nvarchar(255), 
rideable_type nvarchar(255), 
started_at datetime, 
ended_at datetime,
start_station_name nvarchar(255), 
start_station_id nvarchar(255), 
end_station_name nvarchar(255), 
end_station_id nvarchar(255), 
start_lat float,
start_lng float, 
end_lat float, 
end_lng float, 
member_casual nvarchar(255)
)

-- Importing the data from all table into one big data called year

INSERT INTO cyclist..year
(
ride_id, 
rideable_type, 
started_at, 
ended_at,
start_station_name, 
start_station_id, 
end_station_name, 
end_station_id, 
start_lat,
start_lng, 
end_lat, 
end_lng, 
member_casual
)
SELECT *
FROM cyclist..Oct_2020
UNION ALL
SELECT *
FROM cyclist..Nov_2020
UNION ALL
SELECT *
FROM cyclist..Dec_2020
UNION ALL
SELECT *
FROM cyclist..Jan_2021
UNION ALL
SELECT *
FROM cyclist..Feb_2021
UNION ALL
SELECT *
FROM cyclist..Mar_2021
UNION ALL
SELECT *
FROM cyclist..Apr_2021
UNION ALL
SELECT *
FROM cyclist..May_2021
UNION ALL
SELECT *
FROM cyclist..June_2021
UNION ALL
SELECT *
FROM cyclist..July_2021
UNION ALL
SELECT *
FROM cyclist..Aug_2021
UNION ALL
SELECT *
FROM cyclist..Sept_2021

select
* from cyclist..year

-- Checking for duplicate ride_id as there isn't supposed to be one

SELECT ride_id
FROM cyclist..year
GROUP BY ride_id
having count(ride_id) > 1

-- Deleting the duplicated ride_id found

WITH temp AS 
(
SELECT 
ride_id, ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY ride_id) num 
FROM 
cyclist..year
)
DELETE FROM temp
WHERE num > 1;

-- This was done to import some columns from the previous table to new table -> new_year

SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, 
end_station_name, start_station_id, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
INTO new_year
FROM cyclist..year;

-- Created an index to make the queries faster when loaded

CREATE INDEX table_index 
ON new_year 
(
ride_id, rideable_type, member_casual, start_station_id, 
start_station_name, end_station_id, end_station_name, 
started_at, start_lat, start_lng, end_lat, end_lng, ended_at
);

-- Creating new columns

ALTER TABLE new_year
ADD duration INT,
[year] INT,
[date] DATE,
day_of_the_week NCHAR(10),
[month] NCHAR(10)

select * from new_year

-- Filling in the values into the new columns

UPDATE new_year
SET duration = DATEDIFF(minute, started_at, ended_at),
[year] = DATEPART(year, started_at),
[date] =  CAST(started_at AS date),
day_of_the_week =  DATENAME(WEEKDAY, started_at),
[month] =  DATENAME(MONTH, started_at)

-- The query to check for wrong input in the member_casual column

SELECT DISTINCT member_casual
FROM new_year

-- Checking for null values in the duration column

SELECT *
FROM new_year
WHERE duration IS NULL OR duration <= 0

-- Deleting the row that contains null or negative values in the duration column

DELETE 
FROM new_year
WHERE duration IS NULL OR duration <= 0

-- selecting rows where the start_station_name and end_station_name are empty

select *
FROM new_year
WHERE start_station_name IS NULL AND start_station_id IS NULL

-- Deleting rows where the start_station_name and start_station_id are empty

DELETE *
FROM new_year
WHERE start_station_name IS NULL AND start_station_id IS NULL

-- selecting rows where the end_station_name and end_station_id are empty

select *
FROM new_year
WHERE end_station_id IS NULL AND end_station_name IS NULL

-- DELETING rows where the end_station_name and end_station_id are empty

DELETE
FROM new_year
WHERE end_station_id IS NULL AND end_station_name IS NULL



-- Checking for null values in each of the station_name or station_id 

SELECT *
FROM new_year
WHERE start_station_name IS NULL OR end_station_name IS NULL OR 
(start_station_id IS NULL OR end_station_id IS NULL)


-- Checking for null values in the start_station_name and start_station_id

SELECT start_station_name, start_station_id
FROM new_year
WHERE start_station_name IS NULL OR (start_station_id IS NULL OR start_station_id IS NOT NULL)
GROUP BY start_station_name, start_station_id
ORDER BY start_station_name


-- Checking for null values in the end_station_name and end_station_id

SELECT end_station_name, end_station_id
FROM new_year
WHERE end_station_name IS NULL OR (end_station_id IS NULL OR end_station_id IS NOT NULL)
GROUP BY end_station_name, end_station_id
ORDER BY end_station_name

-- Selecting just the start station name

SELECT start_station_name
from new_year
GROUP BY start_station_name

-- Checking for duplicate station name

SELECT DISTINCT start_station_name
FROM new_year

-- Selecting just the end station name

SELECT end_station_name
from new_year
GROUP BY end_station_name

-- Checking for duplicate station name 

SELECT DISTINCT end_station_name
FROM new_year


-------------DESCRIPTIVE ANALYSIS FROM CLEANED DATA EXPLORED THROUGH ABOVE QUERIES------------------------

-- getting the max, min and avg duration

SELECT max(duration) AS max_duration, 
min(duration) AS min_duration, 
avg(duration) AS average_duration
FROM new_year

-- Getting number of rows where duration is more than 24hours

SELECT COUNT(*) AS 'DURATION > 24 HOURS'
FROM new_year
WHERE duration > 1440

-- Checking for the months where the bikes are ridden most

SELECT TOP 5 [month] AS month
FROM new_year
GROUP BY [month]
ORDER BY COUNT(*) DESC

-- Checking for the months IN descending order where the bikes are ridden most to least

SELECT [month] AS month
FROM new_year
GROUP BY [month]
ORDER BY COUNT(*) DESC

-- Checking for the most common day the bikes are ridden

SELECT top 3 day_of_the_week AS week
FROM new_year
GROUP BY day_of_the_week
ORDER BY COUNT(*) DESC

-- getting the average ride duration for each month of the year

SELECT  avg(duration) AS avg_duration, member_casual, [month]
FROM  new_year
GROUP BY member_casual, [month]
ORDER BY avg_duration DESC

-- getting the average ride duration for each day of the week

SELECT avg(duration) AS avg_duration, member_casual, day_of_the_week
FROM  new_year
GROUP BY member_casual, day_of_the_week
ORDER BY avg_duration DESC, member_casual

-- getting the months of the year with the biggest number of users with the average duration

SELECT  avg(duration) AS avg_duration, COUNT(DISTINCT ride_id) AS num_of_rides, member_casual, [month]
FROM  new_year
GROUP BY member_casual,[month]
ORDER BY avg_duration DESC,num_of_rides DESC

-- getting the day of the week with the biggest number of users with the average duration

SELECT  avg(duration) AS avg_duration, COUNT(DISTINCT ride_id) AS num_of_rides, member_casual, [day_of_the_week]
FROM  new_year
GROUP BY member_casual,[day_of_the_week]
ORDER BY avg_duration DESC,num_of_rides DESC

-- How the different bike types are being used between members and causal riders

SELECT  avg(duration) AS avg_duration, COUNT(DISTINCT ride_id) AS num_of_rides,rideable_type, member_casual
FROM  new_year
GROUP BY member_casual,[rideable_type]
ORDER BY avg_duration DESC,num_of_rides DESC

-- Checking for the most common start stations by member type

SELECT COUNT(ride_id) AS number_of_rides, start_station_id, start_station_name, member_casual
FROM new_year
GROUP BY start_station_id, start_station_name, member_casual
ORDER BY number_of_rides DESC;

-- Checking for the most common end stations by member type

SELECT COUNT(ride_id) AS number_of_rides, end_station_id, end_station_name, member_casual
FROM new_year
GROUP BY end_station_id, end_station_name, member_casual
ORDER BY number_of_rides DESC;

--NUMBER OF RIDERS BASED ON MEMBER CASUAL AND AVERAGE DURATION

SELECT	member_casual, count(ride_id) as number_of_rides, avg(duration) as Avg_Duration
from New_year
group by member_casual
order by number_of_rides DESC;

--DATA USED FOR VISUALIZATION

SELECT ride_id AS id, start_station_name AS station_name, start_lat AS lat, start_lng AS lng, member_casual AS subscription_type
FROM new_year
UNION ALL 
SELECT ride_id, end_station_name, end_lat, end_lng, member_casual
FROM new_year

SELECT * FROM NEW_YEAR

--AVERAGE DURATION BY DAY OF THE WEEK

SELECT AVG(duration) as avg_duration, day_of_the_week, member_casual
from New_year
group by day_of_the_week, member_casual
order by day_of_the_week;

--AVERAGE DURATION BY MONTH

SELECT AVG(duration) as avg_duration, month, member_casual
from New_year
group by month, member_casual
order by month;

--NUMBER OF RIDERS EACH MONTH BASED ON TYPES OF MEMBERS

SELECT count(ride_id) as Number_of_riders, month, member_casual
from New_year
group by month, member_casual
order by month;

--NUMBER OF RIDERS EACH DAY BASED ON TYPES OF MEMBERS

SELECT count(ride_id) as Number_of_riders, day_of_the_week, member_casual
from New_year
group by day_of_the_week, member_casual
order by day_of_the_week;

--most used bikes

SELECT rideable_type, member_casual, count(ride_id) As Number_of_riders
from New_year
group by rideable_type, member_casual
order by rideable_type DESC;
