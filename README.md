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

### Star Schema Design

### Data Cleansing and Transforming 