-- ============================================================
-- Watch me Cleaning Data in minutes with SQL: subscriptions
-- BigQuery. Upload subscriptions_raw.csv as a table, then replace
-- analytics-automation-academy.sql_practice with your own project.dataset.
-- Framework: the 6 Cs of data cleaning
--   1 Completeness  2 Consistency  3 Correctness
--   4 Conformity    5 Coherence    6 Contextual relevance
-- ============================================================


-- ── Q0. The naive answer (before any cleaning) ──────────────
SELECT
  COUNT(*) AS active_subscriptions,
  ROUND(SUM(monthly_price), 2) AS mrr
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
WHERE status = 'active';


-- ── C1. COMPLETENESS: are all the necessary values there? ───  [beginner]

-- Q1a. Count what is missing
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(customer_email IS NULL) AS missing_email,
  COUNTIF(start_date IS NULL) AS missing_start_date,
  COUNTIF(end_date IS NULL) AS missing_end_date,
  COUNTIF(payment_method IS NULL) AS missing_payment_method
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`;

-- Q1b. Look for nulls in disguise
SELECT
  payment_method,
  COUNT(*) AS row_count
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
GROUP BY payment_method
ORDER BY row_count DESC;

-- Q1c. One label for every kind of missing
SELECT
  subscription_id,
  payment_method,
  CASE
    WHEN payment_method IS NULL OR payment_method IN ('NULL', 'N/A') THEN 'unknown'
    ELSE payment_method
  END AS payment_method_clean
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`;


-- ── C2. CONSISTENCY: is the same thing always written the same way? ───  [beginner]

-- Q2a. See the mess (repeat with status and country)
SELECT
  plan,
  COUNT(*) AS row_count
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
GROUP BY plan
ORDER BY row_count DESC;

-- Q2b. Standardise text, country names and dates
SELECT
  subscription_id,
  INITCAP(TRIM(plan)) AS plan,
  REPLACE(LOWER(TRIM(status)), 'canceled', 'cancelled') AS status,
  LOWER(TRIM(customer_email)) AS customer_email,
  CASE
    WHEN UPPER(TRIM(country)) IN ('UK', 'U.K.', 'UNITED KINGDOM') THEN 'United Kingdom'
    WHEN UPPER(TRIM(country)) IN ('IE', 'IRELAND') THEN 'Ireland'
    WHEN UPPER(TRIM(country)) IN ('DE', 'GERMANY') THEN 'Germany'
    WHEN UPPER(TRIM(country)) IN ('IT', 'ITALY') THEN 'Italy'
    ELSE INITCAP(TRIM(country))
  END AS country,
  COALESCE(
    SAFE.PARSE_DATE('%Y-%m-%d', start_date),
    SAFE.PARSE_DATE('%d/%m/%Y', start_date)
  ) AS start_date
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`;


-- ── C3. CORRECTNESS: are the values possible? ───────────────  [beginner to intermediate]

-- Q3a. Look at the price list the data actually contains
SELECT
  monthly_price,
  COUNT(*) AS row_count
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
GROUP BY monthly_price
ORDER BY monthly_price;

-- Q3b. Fix the prices you can explain
SELECT
  subscription_id,
  plan,
  monthly_price,
  CASE
    WHEN monthly_price < 0 THEN ABS(monthly_price)        -- sign typed by mistake
    WHEN monthly_price > 100 THEN monthly_price / 100     -- decimal point missing
    ELSE monthly_price
  END AS monthly_price_clean
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
WHERE monthly_price < 0
   OR monthly_price > 100;

-- Q3c. Find the values you cannot fix: emails with no @, start dates in the future
SELECT
  subscription_id,
  customer_email,
  start_date
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
WHERE customer_email NOT LIKE '%@%'
   OR COALESCE(
        SAFE.PARSE_DATE('%Y-%m-%d', start_date),
        SAFE.PARSE_DATE('%d/%m/%Y', start_date)
      ) > CURRENT_DATE();


-- ── C4. CONFORMITY: does the data follow the business rules? ───  [intermediate]
-- Rule: one row per subscription.

-- Q4a. Which subscriptions break the rule?
SELECT
  subscription_id,
  COUNT(*) AS row_count
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
GROUP BY subscription_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

-- Q4b. Keep the latest version of each subscription
WITH ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY subscription_id
      ORDER BY updated_at DESC
    ) AS row_num
  FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
)
SELECT * EXCEPT (row_num)
FROM ranked
WHERE row_num = 1;


-- ── C5. COHERENCE: do related columns make sense together? ───  [intermediate]
SELECT
  subscription_id, plan, monthly_price, status, end_date,
  CASE
    WHEN LOWER(status) LIKE '%active%' AND end_date IS NOT NULL THEN 'active with an end date'
    WHEN LOWER(status) LIKE '%cancel%' AND end_date IS NULL THEN 'cancelled without an end date'
    WHEN LOWER(plan) NOT LIKE '%free%' AND monthly_price = 0 THEN 'paid plan at zero price'
    ELSE 'ok'
  END AS quality_flag
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
ORDER BY quality_flag;


-- ── C6. CONTEXTUAL RELEVANCE: does this row belong in my analysis? ───  [intermediate]
-- Goal of the analysis: monthly recurring revenue from real customers.

-- Q6a. The trap: NOT LIKE silently drops the rows where email is NULL
SELECT COUNT(*) AS rows_kept
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
WHERE customer_email NOT LIKE 'test%';

-- Q6b. The fix
SELECT * EXCEPT (internal_notes)
FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
WHERE COALESCE(customer_email, '') NOT LIKE 'test%';


-- ── PIPELINE: the 6 Cs as one query, one CTE per C ──────────
CREATE OR REPLACE TABLE `analytics-automation-academy.sql_practice.subscriptions_clean` AS

WITH completeness AS (
  SELECT
    * EXCEPT (payment_method),
    CASE
      WHEN payment_method IS NULL OR payment_method IN ('NULL', 'N/A') THEN 'unknown'
      ELSE payment_method
    END AS payment_method
  FROM `analytics-automation-academy.sql_practice.subscriptions_raw`
),

consistency AS (
  SELECT
    subscription_id,
    customer_id,
    LOWER(TRIM(customer_email)) AS customer_email,
    CASE
      WHEN UPPER(TRIM(country)) IN ('UK', 'U.K.', 'UNITED KINGDOM') THEN 'United Kingdom'
      WHEN UPPER(TRIM(country)) IN ('IE', 'IRELAND') THEN 'Ireland'
      WHEN UPPER(TRIM(country)) IN ('DE', 'GERMANY') THEN 'Germany'
      WHEN UPPER(TRIM(country)) IN ('IT', 'ITALY') THEN 'Italy'
      ELSE INITCAP(TRIM(country))
    END AS country,
    INITCAP(TRIM(plan)) AS plan,
    monthly_price,
    REPLACE(LOWER(TRIM(status)), 'canceled', 'cancelled') AS status,
    COALESCE(
      SAFE.PARSE_DATE('%Y-%m-%d', start_date),
      SAFE.PARSE_DATE('%d/%m/%Y', start_date)
    ) AS start_date,
    end_date,
    payment_method,
    updated_at,
    internal_notes
  FROM completeness
),

correctness AS (
  SELECT
    * EXCEPT (customer_email, monthly_price, start_date),
    CASE WHEN customer_email LIKE '%@%' THEN customer_email END AS customer_email,
    CASE
      WHEN monthly_price < 0 THEN ABS(monthly_price)
      WHEN monthly_price > 100 THEN monthly_price / 100
      ELSE monthly_price
    END AS monthly_price,
    CASE WHEN start_date <= CURRENT_DATE() THEN start_date END AS start_date
  FROM consistency
),

ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY subscription_id
      ORDER BY updated_at DESC
    ) AS row_num
  FROM correctness
),

conformity AS (
  SELECT * EXCEPT (row_num)
  FROM ranked
  WHERE row_num = 1
),

coherence AS (
  SELECT
    *,
    CASE
      WHEN end_date < start_date THEN 'ended before it started'
      WHEN status = 'active' AND end_date IS NOT NULL THEN 'active with an end date'
      WHEN status = 'cancelled' AND end_date IS NULL THEN 'cancelled without an end date'
      WHEN plan != 'Free' AND monthly_price = 0 THEN 'paid plan at zero price'
      ELSE 'ok'
    END AS quality_flag
  FROM conformity
)

-- contextual relevance
SELECT * EXCEPT (internal_notes)
FROM coherence
WHERE COALESCE(customer_email, '') NOT LIKE 'test%';


-- ── PAYOFF. Same question as Q0, asked to the clean table ───
SELECT
  COUNT(*) AS active_subscriptions,
  ROUND(SUM(monthly_price), 2) AS mrr
FROM `analytics-automation-academy.sql_practice.subscriptions_clean`
WHERE status = 'active'
  AND quality_flag = 'ok';

-- The list you send to the billing team
SELECT
  quality_flag,
  COUNT(*) AS row_count
FROM `analytics-automation-academy.sql_practice.subscriptions_clean`
WHERE quality_flag != 'ok'
GROUP BY quality_flag
ORDER BY row_count DESC;
