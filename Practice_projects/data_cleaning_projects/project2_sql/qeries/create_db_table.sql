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

-- load the csv file in to the table using this command in postgresql terminal `\copy project_2 FROM '//Users/kuldeep/DataAnalyst/Projects/Practice_projects/data_cleaning_projects/project2_sql/dataset/staging_dirty_cafe_sales.csv' DELIMITER ',' CSV HEADER;`

-- check the table 
SELECT * from project_2;

-- 1. Data Profiling
-- 6C FrameWork 

-- Completeness
CREATE VIEW null_check AS
SELECT
    COUNT(*) as total_rows,
    COUNT (*) FILTER (WHERE transaction_id is null) AS missing_transaction_id,
    COUNT (*) FILTER (WHERE item is null) AS missing_item,
    COUNT (*) FILTER (WHERE quantity is null) AS missing_quantity,
    COUNT (*) FILTER (WHERE price_per_unit is null) AS missing_price_per_unit,
    COUNT (*) FILTER (WHERE total_spent is null) AS missing_total_spent,
    COUNT (*) FILTER (WHERE payment_method is null) AS missing_payment_method,
    COUNT (*) FILTER (WHERE location is null) AS missing_location,
    COUNT (*) FILTER (WHERE transaction_date is null) AS missing_transaction_date
FROM project_2;

-- Consistency of Data (e.g. improper naming convention)

-- transaction_id -- checking uniqueness and duplicate tracnsaction_id's
CREATE VIEW transaction_id_improper_naming_convention AS
SELECT
    transaction_id, COUNT(*) as total_rows
FROM project_2
GROUP BY 1
HAVING COUNT(*) >1 
ORDER BY total_rows DESC;
-- result in transaction column does not have any transaction_id which is repetited or other than that.



-- item -- checking the total_rows in each item
-- this will tell the all the item names presented in data (eg. null,NULL, cookie, Cookie types)
CREATE VIEW item_improper_naming_convention AS
SELECT
    item, COUNT(*) as total_rows
FROM project_2
GROUP BY 1
ORDER BY total_rows DESC;
-- result in item column have UNKNOWN, NULL, ERROR



-- quantity -- checking the total_rows in each quantity
-- this will tell the all the quantity presented in data (eg. 0,1,-1,unknown,null,Null types)
CREATE VIEW quantity_improper_naming_convention AS
SELECT
    quantity, COUNT(*) as total_rows
FROM project_2
GROUP BY 1
ORDER BY total_rows DESC;
-- result in quanitity column have UNKNOWN,ERROR,NULL PRESENTED



-- quantity -- checking the total_rows in each quantity
-- this will tell the all the quantity presented in data (eg. 0,1,-1,unknown,null,Null types)
CREATE VIEW quantity_improper_naming_convention AS
SELECT
    quantity, COUNT(*) as total_rows
FROM project_2
GROUP BY 1
ORDER BY total_rows DESC;
-- result in quanitity column have UNKNOWN,ERROR,NULL PRESENTED

