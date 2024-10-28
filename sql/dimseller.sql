/*
    Create dimension table dimseller, cleanse, and populate data from car_price_raw table
*/

-- Check for abnormal values of column state
SELECT DISTINCT state FROM car_price_raw ORDER BY state;

-- Check for abnormal values of column seller
SELECT  DISTINCT seller FROM car_price_raw ORDER BY seller DESC

-- Create temp table having short and full state/province name of US/Canana
CREATE TABLE temp_state_province (
    state_short CHAR(2) PRIMARY KEY,
    state_full VARCHAR(50),
	area VARCHAR(25),
	country VARCHAR(50)
);

INSERT INTO temp_state_province (state_short, state_full, area, country)
VALUES
('AL', 'Alabama', 'state', 'United States'),
('AK', 'Alaska', 'state', 'United States'),
('AZ', 'Arizona', 'state', 'United States'),
('AR', 'Arkansas', 'state', 'United States'),
('CA', 'California', 'state', 'United States'),
('CO', 'Colorado', 'state', 'United States'),
('CT', 'Connecticut', 'state', 'United States'),
('DE', 'Delaware', 'state', 'United States'),
('FL', 'Florida', 'state', 'United States'),
('GA', 'Georgia', 'state', 'United States'),
('HI', 'Hawaii', 'state', 'United States'),
('ID', 'Idaho', 'state', 'United States'),
('IL', 'Illinois', 'state', 'United States'),
('IN', 'Indiana', 'state', 'United States'),
('IA', 'Iowa', 'state', 'United States'),
('KS', 'Kansas', 'state', 'United States'),
('KY', 'Kentucky', 'state', 'United States'),
('LA', 'Louisiana', 'state', 'United States'),
('ME', 'Maine', 'state', 'United States'),
('MD', 'Maryland', 'state', 'United States'),
('MA', 'Massachusetts', 'state', 'United States'),
('MI', 'Michigan', 'state', 'United States'),
('MN', 'Minnesota', 'state', 'United States'),
('MS', 'Mississippi', 'state', 'United States'),
('MO', 'Missouri', 'state', 'United States'),
('MT', 'Montana', 'state', 'United States'),
('NE', 'Nebraska', 'state', 'United States'),
('NV', 'Nevada', 'state', 'United States'),
('NH', 'New Hampshire', 'state', 'United States'),
('NJ', 'New Jersey', 'state', 'United States'),
('NM', 'New Mexico', 'state', 'United States'),
('NY', 'New York', 'state', 'United States'),
('NC', 'North Carolina', 'state', 'United States'),
('ND', 'North Dakota', 'state', 'United States'),
('OH', 'Ohio', 'state', 'United States'),
('OK', 'Oklahoma', 'state', 'United States'),
('OR', 'Oregon', 'state', 'United States'),
('PA', 'Pennsylvania', 'state', 'United States'),
('RI', 'Rhode Island', 'state', 'United States'),
('SC', 'South Carolina', 'state', 'United States'),
('SD', 'South Dakota', 'state', 'United States'),
('TN', 'Tennessee', 'state', 'United States'),
('TX', 'Texas', 'state', 'United States'),
('UT', 'Utah', 'state', 'United States'),
('VT', 'Vermont', 'state', 'United States'),
('VA', 'Virginia', 'state', 'United States'),
('WA', 'Washington', 'state', 'United States'),
('WV', 'West Virginia', 'state', 'United States'),
('WI', 'Wisconsin', 'state', 'United States'),
('WY', 'Wyoming', 'state', 'United States'),
('PR', 'Prince Edward Island', 'province', 'Canada'),
('ON', 'Ontario', 'province', 'Canada'),
('QC', 'Quebec', 'province', 'Canada'),
('NS', 'Nova Scotia', 'province', 'Canada'),
('AB', 'Alberta', 'province', 'Canada');


-- Create dimseller table
CREATE TABLE DimSeller (
	id SERIAL PRIMARY KEY,
	sellername TEXT,
    stateshort CHAR(2),
    statefull VARCHAR(50),
	area VARCHAR(25),
	country VARCHAR(50),
	UNIQUE (sellername, stateshort, country))

-- Populate dimseller table
WITH
	distinct_seller_state AS (
		SELECT
			DISTINCT seller, state
		FROM car_price_raw)

INSERT INTO DimSeller
	(sellername, stateshort, statefull, area, country)
SELECT
	d.seller,
	d.state,
	t.state_full,
	t.area,
	t.country
FROM distinct_seller_state d
	LEFT JOIN temp_state_province t ON d.state = LOWER(t.state_short)
WHERE t.state_full IS NOT NULL
ORDER BY d.seller, d.state;