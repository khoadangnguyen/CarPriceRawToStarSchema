/*
    Load data from csv to intermediate table
*/

-- Create table to store data from csv file
CREATE TABLE car_price_raw (
    year INT,
    make TEXT,
    model TEXT,
    trim TEXT,
    body TEXT,
    transmission TEXT,
    vin TEXT,
    state TEXT,
    condition INT,
    odometer INT,
    color TEXT,
    interior TEXT,
    seller TEXT,
    mmr INT,
    sellingprice INT,
    saledate TEXT);

-- Load data from csv to car_price_raw
\copy car_price_raw FROM './data/car_prices.csv' DELIMITER ',' CSV HEADER;
