/*
    Create dimension table dimdate, cleanse, and populate data from car_price_raw table
*/

-- Check for null value of column saledate
SELECT saledate FROM car_price_raw WHERE saledate IS NULL


-- Majority values of saledate column are as Tue Dec 16 2014 12:30:00 GMT-0800 (PST)
-- Check for values of saledate that are not in the above format
SELECT saledate FROM car_price_raw
WHERE saledate !~ '^([A-Za-z]{3} [A-Za-z]{3} [0-9]{1,2} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2} GMT[+-][0-9]{4} \([A-Z]{3}\))$'


-- Create DimDate table
CREATE TABLE DimDate (
	id SERIAL PRIMARY KEY,
	-- when parsing text type datetime from input, for example
	-- Tue Dec 16 2014 12:30:00 GMT-0800 (PST) or Tue Dec 16 2014 12:30:00 GMT-0800 (PDT)
	-- using to_timestamp with TZ template pattern, PostgreSQL will parse time with timezone
	datetime TIMESTAMP WITH TIME ZONE UNIQUE,
	year SMALLINT,
	quarter SMALLINT,
	quartername VARCHAR(2),
	month SMALLINT,
	monthname VARCHAR(9),
	week SMALLINT,
	day SMALLINT,
	dayofweek SMALLINT,
	dayname VARCHAR(9),
	date DATE,
	time TIME,
	hour SMALLINT,
	minute SMALLINT,
	second SMALLINT
);


-- When setting TIMEZONE to UTC, the session timezone is set to UTC,
-- and the related column data will also be parsed to UTC timezone
SET TIMEZONE = 'UTC';

WITH
distinct_saledate AS (
	SELECT
		DISTINCT saledate AS saledate
	FROM car_price_raw
	WHERE saledate ~ '^([A-Za-z]{3} [A-Za-z]{3} [0-9]{1,2} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2} GMT[+-][0-9]{4} \([A-Z]{3}\))$'),

timestamp_saledate AS (
	SELECT
		REGEXP_REPLACE(saledate, ' GMT-[0-9]{4}', '') AS cleansed_saledate,
		to_timestamp(REGEXP_REPLACE(saledate, ' GMT-[0-9]{4}', ''), 'Dy Mon DD YYYY HH24:MI:SS TZ') AS timestamp_saledate
	FROM distinct_saledate)

INSERT INTO DimDate
	(datetime, year, quarter, quartername, month, monthname, week, day, dayofweek, dayname, date, time, hour, minute, second)
    SELECT
        timestamp_saledate,
        EXTRACT(YEAR FROM timestamp_saledate) AS year,
        EXTRACT(QUARTER FROM timestamp_saledate) AS quarter,
        CASE
            WHEN EXTRACT(QUARTER FROM timestamp_saledate) = 1 THEN 'Q1'
            WHEN EXTRACT(QUARTER FROM timestamp_saledate) = 2 THEN 'Q2'
            WHEN EXTRACT(QUARTER FROM timestamp_saledate) = 3 THEN 'Q3'
            WHEN EXTRACT(QUARTER FROM timestamp_saledate) = 4 THEN 'Q4'
        END AS quartername,
        EXTRACT(MONTH FROM timestamp_saledate) AS month,
        TO_CHAR(timestamp_saledate, 'Month') AS monthname,
        EXTRACT(WEEK FROM timestamp_saledate) AS week,
        EXTRACT(DAY FROM timestamp_saledate) AS day,
        EXTRACT(DOW FROM timestamp_saledate) AS dayofweek, -- 0 is Sunday, 1 is Monday, etc.
        TO_CHAR(timestamp_saledate, 'Day') AS dayname,     -- Full name of the day
        DATE(timestamp_saledate) AS date,              -- Extracts just the date
        CAST(timestamp_saledate AS time) AS time,	-- Extracts just the time
        EXTRACT(HOUR FROM timestamp_saledate) AS hour, -- Extracts the hour
        EXTRACT(MINUTE FROM timestamp_saledate) AS minute, -- Extracts the minute
        EXTRACT(SECOND FROM timestamp_saledate)::INTEGER AS second  -- Extracts the second
    FROM timestamp_saledate
    ORDER BY timestamp_saledate;