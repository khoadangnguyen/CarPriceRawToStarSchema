# CarPriceRawToStarSchema
Provided raw car selling price data is cleansed, transformed to a star schema, and stored in a PostgreSQL 
database hosted in a Docker container.

### Description
The goalds of this project are to
- Set up a PostgreSQL database within a Docker container, managed via a docker-compose file
- Design and implement a star schema from raw data, creating optimized data tables
- Cleanse and populate tables with transformed raw data

### Setup
bitnami/postgresql Docker image is used to run PostgreSQL container.
Project's folders are mapped to PostgreSQL data directory, logs directory, and WAL logs directory.

### Raw Data
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

### Star Schema Design


### Data Cleansing and Transforming 