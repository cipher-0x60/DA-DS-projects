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
--Result some price_per_unit contains 2 or more then 2 items which means we can not fill these.


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
-- From Data_Profiling we got that location, payment_method, quantity, item,  price_per_unit, transaction_date has postgresql NULL values.

-- item column's NULL values filling with Unknown
UPDATE project_2
set item = 'Unknown'
WHERE item is null;

SELECT * FROM project_2
WHERE item is null;

-- location column's NULL values
UPDATE project_2
SET location = 'Unknown'
WHERE location IS NULL;

-- payment_method
UPDATE project_2
SET payment_method = 'Unknown'
WHERE payment_method IS NULL;


-- quantity column's NULL values filling 
-- to check the distict items where the quantity is NULL
-- result = Cake, Salad, Tea,Coffee, Juice,Smoothie, Sandwich,Cookie
SELECT  DISTINCT(item) FROM project_2
WHERE quantity is null;

-- to check the distinct price per unit for each item
SELECT DISTINCT item, price_per_unit 
FROM project_2
WHERE price_per_unit is not null
ORDER BY item;


SELECT price_per_unit, item 
FROM project_2
GROUP BY price_per_unit, item;


SELECT item, price_per_unit, total_spent, quantity FROM project_2
WHERE item = 'Juice' AND quantity is null;

SELECT item, price_per_unit, total_spent, quantity FROM project_2
WHERE item = 'Tea' AND quantity is null;

SELECT item, price_per_unit, total_spent, quantity FROM project_2
WHERE item = 'Smoothie' AND quantity is null;

SELECT item, price_per_unit, total_spent, quantity FROM project_2
WHERE item = 'Cookie' AND quantity is null;

SELECT item, price_per_unit, total_spent, quantity FROM project_2
WHERE item = 'Sandwich' AND quantity is null;

SELECT item, price_per_unit, total_spent, quantity FROM project_2
WHERE item = 'Salad' AND quantity is null;

SELECT item, price_per_unit, total_spent, quantity FROM project_2
WHERE item = 'Cake' AND quantity is null;

SELECT item, price_per_unit, total_spent, quantity FROM project_2
WHERE item = 'Coffee' AND quantity is null;

UPDATE project_2
SET quantity = CASE 
    -- JUICE NESTED BLOCK
    WHEN item = 'Juice' AND price_per_unit = '3.0' THEN
        CASE 
            WHEN total_spent = '3.0'  THEN '1'
            WHEN total_spent = '6.0'  THEN '2'
            WHEN total_spent = '9.0'  THEN '3'
            WHEN total_spent = '12.0' THEN '4'
            WHEN total_spent = '15.0' THEN '5'
            ELSE quantity
        END
    
    -- TEA NESTED BLOCK
    WHEN item = 'Tea' AND price_per_unit = '1.5' THEN
        CASE 
            WHEN total_spent = '1.5' THEN '1'
            WHEN total_spent = '3.0' THEN '2'
            WHEN total_spent = '4.5' THEN '3'
            ELSE quantity
        END

    -- SMOOTHIE NESTED BLOCK
    WHEN item = 'Smoothie' AND price_per_unit = '4.0' THEN
        CASE 
            WHEN total_spent = '4.0'  THEN '1'
            WHEN total_spent = '12.0' THEN '3'
            ELSE quantity
        END

    -- COOKIE NESTED BLOCK
    WHEN item = 'Cookie' AND price_per_unit = '1.0' THEN
        CASE 
            WHEN total_spent = '1.0' THEN '1'
            WHEN total_spent = '2.0' THEN '2'
            WHEN total_spent = '3.0' THEN '3'
            WHEN total_spent = '4.0' THEN '4'
            WHEN total_spent = '5.0' THEN '5'
            ELSE quantity
        END

    -- SANDWICH NESTED BLOCK
    WHEN item = 'Sandwich' AND price_per_unit = '4.0' THEN
        CASE 
            WHEN total_spent = '4.0'  THEN '1'
            WHEN total_spent = '8.0'  THEN '2'
            WHEN total_spent = '12.0' THEN '3'
            WHEN total_spent = '20.0' THEN '5'
            ELSE quantity
        END

    -- SALAD NESTED BLOCK
    WHEN item = 'Salad' AND price_per_unit = '5.0' THEN
        CASE 
            WHEN total_spent = '5.0'  THEN '1'
            WHEN total_spent = '10.0' THEN '2'
            WHEN total_spent = '15.0' THEN '3'
            WHEN total_spent = '20.0' THEN '4'
            WHEN total_spent = '25.0' THEN '5'
            ELSE quantity
        END

    -- CAKE NESTED BLOCK
    WHEN item = 'Cake' AND price_per_unit = '3.0' THEN
        CASE 
            WHEN total_spent = '3.0'  THEN '1'
            WHEN total_spent = '6.0'  THEN '2'
            WHEN total_spent = '9.0'  THEN '3'
            WHEN total_spent = '12.0' THEN '4'
            WHEN total_spent = '15.0' THEN '5'
            ELSE quantity
        END

    -- COFFEE NESTED BLOCK
    WHEN item = 'Coffee' AND price_per_unit = '2.0' THEN
        CASE 
            WHEN total_spent = '2.0'  THEN '1'
            WHEN total_spent = '4.0'  THEN '2'
            WHEN total_spent = '6.0'  THEN '3'
            WHEN total_spent = '8.0'  THEN '4'
            WHEN total_spent = '10.0' THEN '5'
            ELSE quantity
        END
    
    ELSE quantity
END
WHERE quantity IS NULL;


-- item, price_per_unit

SELECT distinct(item), quantity, price_per_unit, total_spent 
FROM project_2;

SELECT price_per_unit, item, total_spent, quantity
FROM project_2
GROUP BY price_per_unit, item, total_spent, quantity;

-- cookie price is distinct 1.0, salad price is distinct 5.0, Tea = 1.5, coffee  = 2.0 


WITH corrected AS (
    SELECT
        ctid,
        CASE
            WHEN UPPER(TRIM(item)) = 'UNKNOWN'
                AND price_per_unit::NUMERIC = 1.0
                THEN 'Cookie'
            WHEN UPPER(TRIM(item)) = 'UNKNOWN'
                AND price_per_unit::NUMERIC = 5.0
                THEN 'Salad'
            WHEN UPPER(TRIM(item)) = 'UNKNOWN'
                AND price_per_unit::NUMERIC = 1.5
                THEN 'Tea'
            WHEN UPPER(TRIM(item)) = 'UNKNOWN'
                AND price_per_unit::NUMERIC = 2.0
                THEN 'Coffee'
            ELSE item
        END AS corrected_item,

        COALESCE(
            price_per_unit::NUMERIC,
            CASE
                WHEN item = 'Cookie'   THEN 1.0
                WHEN item = 'Salad'    THEN 5.0
                WHEN item = 'Tea'      THEN 1.5
                WHEN item = 'Coffee'   THEN 2.0
                WHEN item IN ('Smoothie', 'Sandwich') THEN 4.0
                WHEN item IN ('Juice', 'Cake')        THEN 3.0
            END
        ) AS corrected_price,

        quantity::NUMERIC AS corrected_quantity,
        total_spent::NUMERIC AS original_total
    FROM project_2
),
final_values AS (
    SELECT
        ctid,
        corrected_item,
        corrected_price,
        CASE
            WHEN original_total IS NULL
                AND corrected_price IS NOT NULL
                AND corrected_quantity IS NOT NULL
            THEN corrected_quantity * corrected_price
            ELSE original_total
        END AS corrected_total
    FROM corrected
)
UPDATE project_2 AS p
SET
    item = f.corrected_item,
    price_per_unit = f.corrected_price,
    total_spent = f.corrected_total
FROM final_values AS f
WHERE p.ctid = f.ctid
    AND (
        UPPER(TRIM(p.item)) = 'UNKNOWN'
        OR p.price_per_unit IS NULL
        OR p.total_spent IS NULL
    );


-- Check unresolved unknown items
SELECT COUNT(*) AS unknown_items_remaining
FROM project_2
WHERE UPPER(TRIM(item)) = 'UNKNOWN';

-- Check remaining missing values
SELECT
    COUNT(*) FILTER (WHERE item IS NULL) AS missing_items,
    COUNT(*) FILTER (WHERE price_per_unit IS NULL) AS missing_prices,
    COUNT(*) FILTER (WHERE total_spent IS NULL) AS missing_totals
FROM project_2;

-- Check whether totals match quantity × unit price
SELECT *
FROM project_2
WHERE quantity IS NOT NULL
    AND price_per_unit IS NOT NULL
    AND total_spent IS NOT NULL
    AND ABS(
        total_spent::NUMERIC
      - quantity::NUMERIC * price_per_unit::NUMERIC
    ) > 0.01;












-- , transaction_date