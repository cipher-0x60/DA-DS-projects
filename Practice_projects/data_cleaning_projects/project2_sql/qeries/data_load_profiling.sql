--- ======================================================
---                     CREATE DATABASE
--- ======================================================

CREATE DATABASE data_cleaning_project;
CREATE TABLE project_2(
    Transaction_ID VARCHAR(50) NOT NULL,
    Item VARCHAR(50),
    Quantity VARCHAR(50),
    Price_Per_Unit VARCHAR(50),
    Total_Spent VARCHAR(50),
    Payment_Method VARCHAR(50),
    Location VARCHAR(50),
    Transaction_Date VARCHAR(50)
);

--- ======================================================
---               LOAD CSV IN DATABSE/ TABLE
--- ======================================================

-- load the csv file in to the table using this command in postgresql terminal 

--- \copy project_2 FROM '//Users/kuldeep/DataAnalyst/Projects/Practice_projects/data_cleaning_projects/project2_sql/dataset/staging_dirty_cafe_sales.csv' DELIMITER ',' CSV HEADER;
---

--- ======================================================
---                   DATA PROFILING
--- ======================================================

-- check the table 
SELECT * from project_2;

-- 1. Data Profiling
-- 6C FrameWork 


-- Completeness
CREATE VIEW null_check AS
SELECT COUNT(*) as total_rows,
    COUNT (*) FILTER (
        WHERE transaction_id is null
            or trim(transaction_id) = ''
    ) AS missing_transaction_id,
    COUNT (*) FILTER (
        WHERE item is null
            or trim(item) = ''
    ) AS missing_item,
    COUNT (*) FILTER (
        WHERE quantity is null
            or trim(quantity) = ''
    ) AS missing_quantity,
    COUNT (*) FILTER (
        WHERE price_per_unit is null
            or trim(price_per_unit) = ''
    ) AS missing_price_per_unit,
    COUNT (*) FILTER (
        WHERE total_spent is null
            or trim(total_spent) = ''
    ) AS missing_total_spent,
    COUNT (*) FILTER (
        WHERE payment_method is null
            or trim(payment_method) = ''
    ) AS missing_payment_method,
    COUNT (*) FILTER (
        WHERE location is null
            or trim(location) = ''
    ) AS missing_location,
    COUNT (*) FILTER (
        WHERE transaction_date is null
            or trim(transaction_date) = ''
    ) AS missing_transaction_date
FROM project_2;

-- Consistency of Data (e.g. improper naming convention)

-- transaction_id -- checking uniqueness and duplicate tracnsaction_id's
CREATE VIEW transaction_id_improper_naming_convention AS
SELECT transaction_id,
    COUNT(*) as total_rows
FROM project_2
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY total_rows DESC;
-- result in transaction column does not have any transaction_id which is repetited or other than that.



-- item -- checking the total_rows in each item
-- this will tell the all the item names presented in data (eg. null,NULL, cookie, Cookie types)
CREATE VIEW item_improper_naming_convention AS
SELECT item,
    COUNT(*) as total_rows
FROM project_2
GROUP BY 1
ORDER BY total_rows DESC;
-- result in item column have UNKNOWN, NULL, ERROR



-- quantity -- checking the total_rows in each quantity
-- this will tell the all the quantity presented in data (eg. 0,1,-1,unknown,null,Null types)
CREATE VIEW quantity_improper_naming_convention AS
SELECT quantity,
    COUNT(*) as total_rows
FROM project_2
GROUP BY 1
ORDER BY total_rows DESC;
-- result in quanitity column have UNKNOWN,ERROR,NULL PRESENTED



-- price_per_unit -- checking the total_rows in each price_per_unit
-- this will tell the all the price_per_unit presented in data (eg. 0,1,-1,unknown,null,Null types)
CREATE VIEW price_per_unit_improper_naming_convention AS
SELECT price_per_unit,
    COUNT(*) as total_rows
FROM project_2
GROUP BY 1
ORDER BY total_rows DESC;
-- result in price_per_unit column have UNKNOWN,ERROR,NULL PRESENTED



-- total_spent -- checking the total_rows in each total_spent
-- this will tell the all the total_spent presented in data (eg. 0,1,-1,unknown,null,Null types)
CREATE VIEW total_spent_improper_naming_convention AS
SELECT total_spent,
    COUNT(*) as total_rows
FROM project_2
GROUP BY 1
ORDER BY total_rows DESC;
-- result in total_spent column have UNKNOWN,ERROR,NULL PRESENTED



-- payment_method-- checking the total_rows in each payment_method
-- this will tell the all the payment_method presented in data (eg. 0,1,-1,unknown,null,Null types)
CREATE VIEW payment_method_improper_naming_convention AS
SELECT payment_method,
    COUNT(*) as total_rows
FROM project_2
GROUP BY 1
ORDER BY total_rows DESC;
-- result in payment_method column have UNKNOWN,ERROR,NULL PRESENTED




-- location-- checking the total_rows in each location
-- this will tell the all the location presented in data (eg. 0,1,-1,unknown,null,Null types)
CREATE VIEW location_method_improper_naming_convention AS
SELECT location,
    COUNT(*) as total_rows
FROM project_2
GROUP BY 1
ORDER BY total_rows DESC;
-- result in location column have UNKNOWN,ERROR,NULL PRESENTED



-- transaction_date-- checking the total_rows in each transaction_date
-- this will tell the all the transaction_date presented in data (eg. 0,1,-1,unknown,null,Null types)
CREATE VIEW transaction_date_improper_naming_convention AS
SELECT transaction_date,
    COUNT(*) AS total_rows
FROM project_2
WHERE transaction_date IS NULL
    OR TRIM(transaction_date) !~ '^\d{4}-\d{2}-\d{2}$'
GROUP BY transaction_date
ORDER BY total_rows DESC;


-- result in transaction_date column have UNKNOWN,ERROR,NULL PRESENTED

--FINAL_OUTCOME=> ALL COLUMNS CONTAINS THE NULL, INCONSISTEN NAMING CONVENTION AND ERROR VALUES FILLES (UNKNOWN, ERROR, NULL)EXCLUDEING THE transaction_id COLUMN

SELECT COUNT(*) AS total_rows,
    -- 1. Actual SQL NULL values
    COUNT(*) FILTER (
        WHERE transaction_date IS NULL
    ) AS sql_nulls,
    -- 2. Empty or whitespace-only strings
    COUNT(*) FILTER (
        WHERE transaction_date IS NOT NULL
            AND TRIM(transaction_date) = ''
    ) AS blank_values,
    -- 3. Placeholder and error strings
    COUNT(*) FILTER (
        WHERE UPPER(TRIM(transaction_date)) IN ('NULL', 'UNKNOWN', 'ERROR')
    ) AS placeholder_or_error_values,
    -- 4. Values that do not match YYYY-MM-DD
    COUNT(*) FILTER (
        WHERE transaction_date IS NOT NULL
            AND TRIM(transaction_date) <> ''
            AND UPPER(TRIM(transaction_date)) NOT IN ('NULL', 'UNKNOWN', 'ERROR')
            AND TRIM(transaction_date) !~ '^\d{4}-\d{2}-\d{2}$'
    ) AS improper_date_format,
    -- 5. Correct format but invalid calendar date
    COUNT(*) FILTER (
        WHERE TRIM(transaction_date) ~ '^\d{4}-\d{2}-\d{2}$'
            AND NOT pg_input_is_valid(
                TRIM(transaction_date),
                'date'
            )
    ) AS invalid_calendar_dates,
    -- 6. Valid dates in the expected format
    COUNT(*) FILTER (
        WHERE TRIM(transaction_date) ~ '^\d{4}-\d{2}-\d{2}$'
            AND pg_input_is_valid(
                TRIM(transaction_date),
                'date'
            )
    ) AS valid_dates
FROM project_2;


-- duplicates
SELECT *,
    row_number() over(partition by transaction_id ORDER BY transaction_id) as row_num
FROM project_2;

WITH numberd_rows 
    AS (
        SELECT *,
            ROW_NUMBER() 
                OVER(
                    PARTITION BY transaction_id
                    ORDER BY transaction_id)
                    AS row_num
        FROM project_2
        )
SELECT * 
FROM numberd_rows
WHERE row_num>1;