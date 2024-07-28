--Snowflake user creation
--Copy these SQL statements into a Snowflake Worksheet, select all and execute them (i.e. pressing the play button).

--USE AN ADMIN ROLE
USE ROLE ACCOUNTADMIN

--CREATE THE 'TRANSFORM' ROLE
CREATE OR REPLACE ROLE TRANSFORM;

--GRANT ACCE TO TRANSFORM
GRANT ROLE TRANSFORM TO ROLE ACCOUNTADMIN

-- CREATE THE DEFAULT WAREHOUSE IF NECESSARY
CREATE OR REPLACE WAREHOUSE  COMPUTE_WH;
GRANT OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;

-- create the 'dbt' user and assign to role
CREATE OR REPLACE USER dbt
    PASSWORD = 'd@123'
    LOGIN_NAME = 'dbt'
    MUST_CHANGE_PASSWORD = FALSE
    DEFAULT_WAREHOUSE = 'COMPUTE_WH'
    DEFAULT_ROLE = 'transform'
    DEFAULT_NAMESPACE = 'AIRBNB.RAW'
    COMMENT = 'DBT USER USED FOR DATA TRANSFORMATION';

GRANT ROLE TRANSFORM TO USER DBT;

-- CREATE OUR DATABASE AND SCHEMAS
CREATE OR REPLACE DATABASE AIRBNB;
CREATE OR REPLACE SCHEMA AIRBNB.RAW
CREATE OR REPLACE SCHEMA AIRBNB.DEV

-- Set up permissions to role `transform`
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;
GRANT ALL ON DATABASE AIRBNB TO ROLE TRANSFORM;
GRANT ALL ON ALL SCHEMAS IN DATABASE AIRBNB TO ROLE TRANSFORM;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE AIRBNB TO ROLE TRANSFORM;
GRANT ALL ON ALL TABLES IN SCHEMA AIRBNB.RAW TO ROLE TRANSFORM;

-- snowflake data import
-- Set up the defaults

USE WAREHOUSE COMPUTE_WH;
USE DATABASE airbnb;
USE SCHEMA RAW;

-- Create our three tables and import the data from S3
CREATE OR REPLACE TABLE RAW_LISTINGS
        (ID INTEGER,
        LISTING_URL STRING,
        NAME STRING,
        ROOM_TYPE STRING,
        MINIMUM_NIGHTS INTEGER,
        HOST_ID INTEGER,
        PRICE STRING,
        CREATE_AT DATETIME,
        UPDATE_AT DATETIME);

-- copy into command
COPY INTO RAW_LISTINGS
            FROM 's3://dbtlearn/listings.csv'
            FILE_FORMAT = (TYPE = 'CSV' 
            SKIP_HEADER =1
            FIELD_OPTIONALLY_ENCLOSED_BY = '"');

SELECT * FROM RAW_LISTINGS

-- create or replace raw_reviews table
CREATE OR REPLACE TABLE RAW_REVIEWS
        (LISTING_ID INTEGER,
        DATE DATETIME,
        REVIEWER_NAME STRING,
        COMMENTS STRING,
        SENTIMENT STRING);

-- COPY INTO DATA RAW_REVIEWS TABLE
COPY INTO RAW_REVIEWS
        FROM 's3://dbtlearn/reviews.csv'
        FILE_FORMAT = (TYPE = 'CSV' 
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"');

SELECT count(*) FROM RAW_REVIEWS


CREATE OR REPLACE TABLE raw_hosts
                    (id integer,
                     name string,
                     is_superhost string,
                     created_at datetime,
                     updated_at datetime
                     );
COPY INTO raw_hosts (id, name, is_superhost, created_at, updated_at)
                   from 's3://dbtlearn/hosts.csv'
                    FILE_FORMAT = (type = 'CSV' skip_header = 1
                    FIELD_OPTIONALLY_ENCLOSED_BY = '"');


-- Visual All table analys to clean a data
SELECT * FROM AIRBNB.RAW.RAW_HOSTS;
SELECT * FROM AIRBNB.RAW.RAW_LISTINGS;
SELECT * FROM AIRBNB.RAW.RAW_REVIEWS;

