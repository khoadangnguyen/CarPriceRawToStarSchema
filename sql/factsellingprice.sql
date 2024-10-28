/*
    Create fact table factsellingprice, cleanse, and populate data from car_price_raw table
*/

-- First approach was to create tables (with/without primary key and foreign keys)
-- then populate data with insert

-- Create FactSellingPrice table
CREATE TABLE FactSellingPrice (
	--id SERIAL PRIMARY KEY,
	-- It was a design choice to choose between having id and without having id
	-- As there is currently no further usecase to jon this table
	-- primary key id column is not needed

	-- In case id column is needed, data can be first created without pre creating the table
	-- and below commands can be used to add primary key
    --CREATE SEQUENCE factsellingprice_id_seq;
    --UPDATE FactSellingPrice SET id = nextval('factsellingprice_id_seq');
    --ALTER TABLE FactSellingPrice ADD CONSTRAINT factsellingprice_pkey PRIMARY KEY (id);

	carid INTEGER,
	sellerid INTEGER,
	dateid INTEGER,
	condition INTEGER,
	odometer INTEGER,
	mmr INTEGER,
	sellingprice INTEGER,
	FOREIGN KEY (carid) REFERENCES DimCar(id) ON DELETE SET NULL,
	FOREIGN KEY (sellerid) REFERENCES DimSeller(id) ON DELETE SET NULL,
	FOREIGN KEY (dateid) REFERENCES DimDate(id) ON DELETE SET NULL
)

-- Populate data with insert
SET TIMEZONE = 'UTC';

WITH
	cleansed_car_price_raw AS (
		SELECT *
		FROM car_price_raw
		WHERE make IS NOT NULL
				AND model IS NOT NULL
				AND trim IS NOT NULL
				AND vin IS NOT NULL
				AND color !~ '^[0-9]+$'
				AND saledate ~ '^([A-Za-z]{3} [A-Za-z]{3} [0-9]{1,2} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2} GMT[+-][0-9]{4} \([A-Z]{3}\))$'
	),

	fact AS (
		SELECT
			c.id AS carid,
			r.vin, r.make, r.model, r.year, r.trim, r.body, r.transmission, r.color, r.interior,
			s.id AS sellerid,
			r.seller, r.state,
			d.id AS dateid,
			r.saledate,
			to_timestamp(REGEXP_REPLACE(r.saledate, ' GMT-[0-9]{4}', ''), 'Dy Mon DD YYYY HH24:MI:SS TZ') AS tssaledate,
			r.condition, r.odometer, r.mmr, r.sellingprice
		FROM cleansed_car_price_raw r
			JOIN DimCar c
				ON r.vin = c.vin AND r.make = c.make AND r.model = c.model AND r.year = c.year AND r.trim = c.trim
					AND (r.body = c.body OR (r.body IS NULL AND c.body IS NULL))
					AND (r.transmission = c.transmission OR (r.transmission IS NULL AND c.transmission IS NULL))
					AND (r.color = c.color OR (r.color IS NULL AND c.color IS NULL))
					AND (r.interior = c.interior OR (r.interior IS NULL AND c.interior IS NULL))
			JOIN DimSeller s ON r.seller = s.sellername AND r.state = s.stateshort
			JOIN DimDate d ON d.datetime = to_timestamp(REGEXP_REPLACE(r.saledate, ' GMT-[0-9]{4}', ''), 'Dy Mon DD YYYY HH24:MI:SS TZ')
	)

INSERT INTO FactSellingPrice(carid, sellerid, dateid, condition, odometer, mmr, sellingprice)
SELECT
	carid, sellerid, dateid, condition, odometer, mmr, sellingprice
FROM fact
-- However, with this approach, it takes really long time even to insert more than 500k rows at the same time
-- Even with removing primary key and foreign keys to insert data and breaking up data 100k batch of row,
-- it was still really slow to finish inserting data (average execution time was more than 15 minutes/100k rows)


-- Second approach is to create table with data as below
-- Create table with data

SET TIMEZONE = 'UTC';

CREATE TABLE FactSellingPrice AS
WITH
	cleansed_car_price_raw AS (
		SELECT *
		FROM car_price_raw
		WHERE make IS NOT NULL
				AND model IS NOT NULL
				AND trim IS NOT NULL
				AND vin IS NOT NULL
				AND color !~ '^[0-9]+$'
				AND saledate ~ '^([A-Za-z]{3} [A-Za-z]{3} [0-9]{1,2} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2} GMT[+-][0-9]{4} \([A-Z]{3}\))$'
	),

	fact AS (
		SELECT
			c.id AS carid,
			r.vin, r.make, r.model, r.year, r.trim, r.body, r.transmission, r.color, r.interior,
			s.id AS sellerid,
			r.seller, r.state,
			d.id AS dateid,
			r.saledate,
			to_timestamp(REGEXP_REPLACE(r.saledate, ' GMT-[0-9]{4}', ''), 'Dy Mon DD YYYY HH24:MI:SS TZ') AS tssaledate,
			r.condition, r.odometer, r.mmr, r.sellingprice
		FROM cleansed_car_price_raw r
			JOIN DimCar c
				ON r.vin = c.vin AND r.make = c.make AND r.model = c.model AND r.year = c.year AND r.trim = c.trim
					AND (r.body = c.body OR (r.body IS NULL AND c.body IS NULL))
					AND (r.transmission = c.transmission OR (r.transmission IS NULL AND c.transmission IS NULL))
					AND (r.color = c.color OR (r.color IS NULL AND c.color IS NULL))
					AND (r.interior = c.interior OR (r.interior IS NULL AND c.interior IS NULL))
			JOIN DimSeller s ON r.seller = s.sellername AND r.state = s.stateshort
			JOIN DimDate d ON d.datetime = to_timestamp(REGEXP_REPLACE(r.saledate, ' GMT-[0-9]{4}', ''), 'Dy Mon DD YYYY HH24:MI:SS TZ')
	)

SELECT
	carid, sellerid, dateid, condition, odometer, mmr, sellingprice
FROM fact
-- result
--
--SELECT 543085
--
--Query returned successfully in 2 secs 646 msec.

-- The performance was extremely fast. It was only ~3 seconds to create table with data (bulk operation)

-- Add foreign keys
ALTER TABLE FactSellingPrice
ADD CONSTRAINT fk_carid FOREIGN KEY (carid) REFERENCES DimCar(id) ON DELETE SET NULL;

ALTER TABLE FactSellingPrice
ADD CONSTRAINT fk_sellerid FOREIGN KEY (sellerid) REFERENCES DimSeller(id) ON DELETE SET NULL;

ALTER TABLE FactSellingPrice
ADD CONSTRAINT fk_dateid FOREIGN KEY (dateid) REFERENCES DimDate(id) ON DELETE SET NULL;
