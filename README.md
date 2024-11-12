# CarPriceRawToStarSchema
Provided raw car selling price data is cleansed, transformed to a star schema, and stored in a PostgreSQL 
database hosted in a Docker container.

## Table of Contents
1. [Description](#1-description)
2. [Setup](#2-setup)
3. [Raw Data](#3-raw-data)
4. [Star Schema Design](#4-star-schema-design)
5. [Data Cleansing and Transforming](#5-data-cleansing-and-transforming)
6. [Problem and Solution](#6-problem-and-solution)
7. [Extension and Open Questions](#7-extension-and-open-questions)


## 1. Description
The goals of this project are to
- Set up a PostgreSQL database within a Docker container, managed via a docker-compose file
- Design and implement a star schema from raw data, creating optimized data tables
- Cleanse and populate tables with transformed raw data

## 2. Setup
bitnami/postgresql Docker image is used to run PostgreSQL container.
Project's folders are mapped to PostgreSQL data directory for persisting data to disk.

## 3. Raw Data
Same [data source](https://github.com/khoadangnguyen/CarSaleTransactionAnalysis/blob/main/data/carprices.zip) is utilized for this project.
Below is an example of the data format:
```yaml
year,make,model,trim,body,transmission,vin,state,condition,odometer,color,interior,seller,mmr,sellingprice,saledate
2015,Kia,Sorento,LX,SUV,automatic,5xyktca69fg566472,ca,5,16639,white,black,kia motors america  inc,20500,21500,Tue Dec 16 2014 12:30:00 GMT-0800 (PST)
2015,Kia,Sorento,LX,SUV,automatic,5xyktca69fg561319,ca,5,9393,white,beige,kia motors america  inc,20800,21500,Tue Dec 16 2014 12:30:00 GMT-0800 (PST)
2014,BMW,3 Series,328i SULEV,Sedan,automatic,wba3c1c51ek116351,ca,45,1331,gray,black,financial services remarketing (lease),31900,30000,Thu Jan 15 2015 04:30:00 GMT-0800 (PST)
...
```
This raw data set includes 500,000 car sale transactions, covering 96 car makes, 972 models, and 1,963 trims spanning
the years from 1982 to 2015.

## 4. Star Schema Design
Based on the raw data format, data is organized into one fact table, **FactSellingPrice**, and three dimension tables:
**DimCar**, **DimSeller**, and **DimDate**.

Design for **DimDate** table:

| Column Name | Data Type                       | Constraint  | 
| ----------- |---------------------------------| ----------- |
| `id`        | SERIAL                          | PRIMARY KEY |
 | `datetime` | TIMESTAMP WITH TIME ZONE UNIQUE |
 | `year` | SMALLINT                        | |
 | `quarter` | SMALLINT                        | |
 | `quartername` | VARCHAR(2)                      | |
 | `month` | SMALLINT                        | |
 | `monthname` | VARCHAR(9)                      | |
 | `week` | SMALLINT                        | |
 | `day` | SMALLINT                        | |
 | `dayofweek` | SMALLINT                        | |
 | `dayname` | VARCHAR(9)                      | |
 | `date` | DATE                            | |
 | `time` | TIME                            | |
 | `hour` | SMALLINT                        | |
 | `minute` | SMALLINT | |
 | `second` | SMALLINT | |



Design for **DimSeller** table:

| Column Name | Data Type                       | Constraint  | Description                              |
| ----------- |---------------------------------|-------------|------------------------------------------|
 | `id` | SERIAL | PRIMARY KEY |                                          |
 | `sellername` | TEXT | UNIQUE      |                                          |
 | `stateshort` | VARCHAR(2) | UNIQUE      |                                          |
 | `statefull` | VARCHAR(50) |             |                                          |
 | `area` | VARCHAR(25) |             | 'state' for US and 'province' for Canada |
 | `country` | VARCHAR(50) | UNIQUE |                                          |



Design for **DimCar** table:

| Column Name                 | Data Type     | Constraint  |
|-----------------------------|---------------| ----------- |
| `id`                        | SERIAL        | PRIMARY KEY |
| `vin` | VARCHAR(17)   | UNIQUE    |
| `make` | VARCHAR(50)   |             |
| `model` | VARCHAR(75)   | |
| `year` | INTEGER       | |
| `trim` | VARCHAR(100)  | |
| `body` | VARCHAR(50) | |
| `transmission` | VARCHAR(25) | |
| `color` | VARCHAR(25) | |
| `interior` | VARCHAR(25) | |


Design for **FactSellingPrice** table:

| Column Name                 | Data Type     | Constraint  | Reference    |
|-----------------------------|---------------|-------------|--------------|
| `carid` | INTEGER | Foreign Key | DimCar(id)   |
| `sellerid` | INTEGER | Foreign Key | DimSeller(id) |
| `dateid` | INTEGER | Foreign Key | DimDate(id)  |
| `condition` | INTEGER |             |              |
| `odometer` | INTEGER |             |              |
| `mmr` | INTEGER |             |              |
| `sellingprice` | INTEGER |             |              |
> Note: FactSellingPrice can also have primary key id column, but for the scope of this project it is not needed

## 5. Data Cleansing and Transforming 
[to be delivered]

## 6. Problem and Solution
### Performance issue with data inserting
The **FactSellingPrice** table initially faced performance issues during data insertion when the table was pre-created 
with FOREIGN KEY constraints, and data was populated via INSERT statements. With over 500k rows to insert, this approach 
consistently failed to complete within 30 minutes.
##### Solution attempts:
1. Remove Foreign Key Constraints: The first attempt involved removing FOREIGN KEY constraints in the table creation. 
This change provided minimal improvement, reducing the insertion time slightly, but it still could not complete in under 20 minutes.
2. Batch Insertions: The next approach was to break the 500k rows into smaller batches of 100k and insert each batch separately. 
This resulted in better performance, reducing insertion time to around 15 minutes on average per batch, with a total time just under 20 minutes
3. Create Table from data: The third and most successful solution was to create the table directly from the data without
predefined schema and constraints. After data insertion, the table was then modified to align with the desired schema. 
This approach significantly improved performance, completing the insertion of over 500k rows in under 3 seconds.

## 7. Extension and Open Questions
[to be delivered]
