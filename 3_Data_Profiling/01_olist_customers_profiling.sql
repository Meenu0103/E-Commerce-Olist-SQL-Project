/* 
   OLIST CUSTOMERS – DATA PROFILING SCRIPT
   Dataset: olist_customers_dataset.csv
   Table: olist_customers
   Purpose: Basic quality checks before analysis
*/

--  TOTAL ROW COUNT 
SELECT COUNT(*) AS total_rows
FROM olist_customers;


-- NULL VALUE CHECKS 
SELECT 
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS customer_unique_id_nulls,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS zip_code_nulls,
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS state_nulls
FROM olist_customers;


/* DUPLICATE CHECK USING CUSTOMER_ID 
(Customer can have multiple orders, so duplicates ARE expected.We DO NOT delete them.) */
SELECT customer_id, COUNT(*) AS occurrences
FROM olist_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


--  UNIQUE CITY & STATE COUNT 
SELECT 
    COUNT(DISTINCT customer_city) AS unique_cities,
    COUNT(DISTINCT customer_state) AS unique_states
FROM olist_customers;


-- CHECK FOR INVALID STATE CODES (must be 2 letters)
SELECT customer_state
FROM olist_customers
WHERE LENGTH(customer_state) > 2;


-- CHECK FOR CITY NAMES STARTING WITH NUMBERS 
SELECT customer_city
FROM olist_customers
WHERE customer_city IS NULL
   OR customer_city = ''
   OR customer_city ~ '^[0-9]'                 -- starts with digit
   OR customer_city ~ '[0-9]$'                 -- ends with digit
   OR customer_city ~ '[[:alpha:]]+[0-9]+'     -- letters followed by digits
   OR customer_city ~ '[0-9]+[[:alpha:]]+'     -- digits followed by letters
   OR customer_city ~ '[^[:alpha:]À-ÿ 0-9\-'']' -- invalid characters
   OR customer_city ~ '^\s'                    -- leading whitespace
   OR customer_city ~ '\s$';                   -- trailing whitespace
