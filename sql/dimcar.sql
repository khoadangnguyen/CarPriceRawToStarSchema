/*
    Create dimension table dimcar, cleanse, and populate data from car_price_raw table
*/

-- Check for abnormal values of column vin
SELECT DISTINCT vin FROM car_price_raw ORDER BY vin DESC

-- Check for abnormal values of column make
SELECT DISTINCT make FROM car_price_raw ORDER BY make DESC

-- Check for abnormal values of column model
SELECT DISTINCT model FROM car_price_raw ORDER BY model DESC

-- Check for abnormal values of column year
SELECT DISTINCT year FROM car_price_raw ORDER BY year

-- Check for abnormal values of column trim
SELECT DISTINCT trim FROM car_price_raw ORDER BY trim DESC

-- Check for abnormal values of column body
SELECT DISTINCT body FROM car_price_raw ORDER BY body

-- Check for abnormal values of column transmission
SELECT DISTINCT transmission FROM car_price_raw ORDER BY transmission

-- Check for abnormal values of column color
SELECT DISTINCT color FROM car_price_raw ORDER BY color

-- Check for abnormal values of column interior
SELECT DISTINCT interior FROM car_price_raw ORDER BY interior

-- Detect duplicated vin number
SELECT
	*
FROM car_price_raw
WHERE vin IN (
	SELECT
	  vin
	FROM car_price_raw
	GROUP BY vin
	HAVING COUNT(*) > 1)
ORDER BY vin

-- Select distinct vin number randomly
	SELECT DISTINCT ON (vin) *
	FROM car_price_raw
	ORDER BY vin, random()



-- Create dimcar table
CREATE TABLE DimCar (
	id SERIAL PRIMARY KEY,
	vin VARCHAR(17) UNIQUE,
	make VARCHAR(50),
	model VARCHAR(75),
	year INTEGER,
	trim VARCHAR(100),
	body VARCHAR(50),
	transmission VARCHAR(25),
	color VARCHAR(25),
	interior VARCHAR(25)
)

-- Populate dimcar table
INSERT INTO DimCar(vin, make, model, year, trim, body, transmission, color, interior)
SELECT
	DISTINCT vin, make, model, year, trim, body, transmission, color, interior
FROM (
	SELECT DISTINCT ON (vin) *
	FROM car_price_raw
	ORDER BY vin, random()
) distinct_vin
WHERE make IS NOT NULL
	AND model IS NOT NULL
	AND trim IS NOT NULL
	AND vin IS NOT NULL
	AND color !~ '^[0-9]+$'
ORDER BY vin




