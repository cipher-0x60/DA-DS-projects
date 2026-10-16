--=========================================================
--                     DATA CLEANING 
--=========================================================

--First fix the unknown and error values
-- item
SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE item IN ('ERROR', 'UNKNOWN');

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE item IN ('ERROR');

DELETE FROM project_2
WHERE item = 'ERROR';

--location

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE location IN ('ERROR', 'UNKNOWN');

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE location IN ('ERROR');

DELETE FROM project_2
WHERE location = 'ERROR';

--price_per_unit

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE price_per_unit IN ('ERROR', 'UNKNOWN');

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE price_per_unit IN ('ERROR');

DELETE FROM project_2
WHERE price_per_unit = 'ERROR';



--quantity

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE quantity IN ('ERROR', 'UNKNOWN');

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE quantity IN ('ERROR');

DELETE FROM project_2
WHERE quantity = 'ERROR';


--total_spent

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE total_spent IN ('ERROR', 'UNKNOWN');

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE total_spent IN ('ERROR');

DELETE FROM project_2
WHERE total_spent = 'ERROR'



--transaction_date

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE transaction_date IN ('ERROR', 'UNKNOWN');

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE transaction_date IN ('ERROR');

DELETE FROM project_2
WHERE transaction_date = 'ERROR'


--payment_method

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE payment_method IN ('ERROR', 'UNKNOWN');

SELECT 
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM project_2) AS perc_of
FROM project_2
WHERE payment_method IN ('ERROR');

DELETE FROM project_2
WHERE payment_method = 'ERROR'



SELECT * 
FROM project_2
WHERE item = 'UNKNOWN' 
    or quantity = 'UNKNOWN'
    or price_per_unit = 'UNKNOWN'
    or total_spent = 'UNKNOWN'
    or payment_method = 'UNKNOWN'
    or location = 'UNKNOWN'
    or transaction_date = 'UNKNOWN';

-- fixing the unknown values of each column basis on the refrence of the the other column

WITH parsed AS (
    SELECT
        transaction_id,
        item,
        quantity,
        price_per_unit,
        total_spent,

        CASE
            WHEN pg_input_is_valid(
                TRIM(quantity), 'numeric'
            )
            THEN TRIM(quantity)::numeric
        END AS qty,

        CASE
            WHEN pg_input_is_valid(
                TRIM(price_per_unit), 'numeric'
            )
            THEN TRIM(price_per_unit)::numeric
        END AS unit_price,

        CASE
            WHEN pg_input_is_valid(
                TRIM(total_spent), 'numeric'
            )
            THEN TRIM(total_spent)::numeric
        END AS total_amount

    FROM project_2
)
SELECT
    *,
    qty * unit_price AS calculated_total,
    total_amount - (qty * unit_price) AS difference
FROM parsed
WHERE qty IS NOT NULL
    AND unit_price IS NOT NULL
    AND total_amount IS NOT NULL
    AND qty * unit_price <> total_amount
ORDER BY transaction_id;


-----------------------------------------------------------------------------------
-- checking the distinct price_per_unit for each of the items. 
SELECT
    price_per_unit,
    COUNT(DISTINCT item) FILTER (
        WHERE item IS NOT NULL
            AND TRIM(item) <> ''
            AND UPPER(TRIM(item))
                NOT IN ('UNKNOWN', 'NULL', 'ERROR')
    ) AS distinct_items,
    STRING_AGG(
        DISTINCT item, ', '
    ) AS items_at_price
FROM project_2
GROUP BY price_per_unit
ORDER BY distinct_items DESC;
--Result some price_per_unit contains 2 or more then 2 items which means we can not fill this.


-----------------------------------------------------------------------------------

SELECT
    item,
    quantity,
    price_per_unit,
    total_spent,
    COUNT(*) AS total_rows
FROM project_2
WHERE UPPER(TRIM(item))
    IN ('UNKNOWN', 'NULL', 'ERROR')
    OR TRIM(item) = ''
GROUP BY
    item,
    quantity,
    price_per_unit,
    total_spent
ORDER BY total_rows DESC;



-----------------------------------------------------------------------------------

WITH parsed AS (
    SELECT
        transaction_id,
        item,
        quantity,
        price_per_unit,
        total_spent,

        CASE
            WHEN pg_input_is_valid(
                NULLIF(TRIM(quantity), ''), 'numeric'
            )
            THEN NULLIF(TRIM(quantity), '')::numeric
        END AS qty,

        CASE
            WHEN pg_input_is_valid(
                NULLIF(TRIM(price_per_unit), ''), 'numeric'
            )
            THEN NULLIF(TRIM(price_per_unit), '')::numeric
        END AS unit_price,

        CASE
            WHEN pg_input_is_valid(
                NULLIF(TRIM(total_spent), ''), 'numeric'
            )
            THEN NULLIF(TRIM(total_spent), '')::numeric
        END AS total_amount

    FROM project_2
)
SELECT
    *,
    CASE
        WHEN qty IS NULL
            AND unit_price > 0
            AND total_amount > 0
            AND MOD(total_amount, unit_price) = 0
        THEN total_amount / unit_price
    END AS candidate_quantity,

    CASE
        WHEN unit_price IS NULL
            AND qty > 0
            AND total_amount > 0
        THEN total_amount / qty
    END AS candidate_unit_price,

    CASE
        WHEN total_amount IS NULL
            AND qty > 0
            AND unit_price > 0
        THEN qty * unit_price
    END AS candidate_total,

    CASE
        WHEN qty > 0
            AND unit_price > 0
            AND total_amount > 0
         AND qty * unit_price <> total_amount
        THEN 'CONTRADICTION'

        WHEN qty IS NULL
            AND unit_price > 0
            AND total_amount > 0
            AND MOD(total_amount, unit_price) = 0
        THEN 'QUANTITY CANDIDATE'

        WHEN unit_price IS NULL
            AND qty > 0
            AND total_amount > 0
        THEN 'PRICE CANDIDATE'

        WHEN total_amount IS NULL
            AND qty > 0
            AND unit_price > 0
        THEN 'TOTAL CANDIDATE'

        ELSE 'REVIEW / INSUFFICIENT EVIDENCE'
    END AS recovery_status

FROM parsed;

--Result- The profiling and reconciliation analysis indicates that the unknown values in the Item column cannot be reliably recovered from the available data alone. Correcting these values requires stakeholder clarification or a trusted reference, such as the sales head's product-price catalogue.

--Conclusion: Since this is a practice project, I may exclude records containing unresolved UNKNOWN values to demonstrate the cleaning process, provided I document the number and percentage of records removed and assess the impact on the analysis. However, indiscriminately deleting these records is not recommended for industry-grade data cleaning because it can cause data loss and introduce analytical bias. 

------------------------------------------------------------
-- Deleting / Droping the UNKNOWN values.

DELETE FROM project_2
WHERE item = 'UNKNOWN' 
    OR quantity = 'UNKNOWN' 
    OR price_per_unit = 'UNKNOWN' 
    OR total_spent = 'UNKNOWN' 
    OR transaction_date = 'UNKNOWN';

SELECT COUNT(*) 
FROM project_2
WHERE item = 'UNKNOWN' 
    OR quantity = 'UNKNOWN' 
    OR price_per_unit = 'UNKNOWN' 
    OR total_spent = 'UNKNOWN' 
    OR transaction_date = 'UNKNOWN';

-- handling the null values 
-- From Data_Profiling we got that item, quantity, price_per_unit, payment_method, location, transaction_date has postgresql NULL values.

-- item column's NULL values filling with Unknown


UPDATE project_2
set item = 'Unknown'
WHERE item is null;

SELECT * FROM project_2
WHERE item is null;

-- quantity column's NULL values filling 

SELECT * FROM project_2;


SELECT *,
    CASE 
        WHEN item = 'Juice' AND price_per_unit ='3.0' AND total_spent = '6.0' Then '2'
        ELSE quantity
    END AS quantity_check
FROM project_2;