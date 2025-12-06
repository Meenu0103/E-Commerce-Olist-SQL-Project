/* 
    OLIST SELLERS – DATA CLEANING SCRIPT
    Dataset: olist_sellers_dataset.csv
    Table: olist_sellers
    Purpose: Validate seller attributes & geographical consistency
*/

--  TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows
FROM olist_sellers;

--  NULL VALUE CHECKS
SELECT
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS zip_code_nulls,
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS state_nulls
FROM olist_sellers;

/*
 Interpretation:
 - seller_id should NEVER be null.
 - Missing state or city would make location-based analysis inaccurate.
*/

--  CHECK FOR DUPLICATE SELLER IDs
SELECT seller_id, COUNT(*) AS occurrences
FROM olist_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

--  UNIQUE CITY & STATE COUNT
SELECT
    COUNT(DISTINCT seller_city) AS unique_cities,
    COUNT(DISTINCT seller_state) AS unique_states
FROM olist_sellers;

--  INVALID STATE CODES (must be 2-letter codes)
SELECT seller_state
FROM olist_sellers
WHERE LENGTH(seller_state) > 2;

--  CHECK FOR CITY NAMES WITH NUMBERS
SELECT seller_city
FROM olist_sellers
WHERE seller_city ~ '^[0-9]';

-- FIX: Replace numeric-only city names with NULL
UPDATE olist_sellers
SET seller_city = NULL
WHERE seller_city ~ '^[0-9]+$';
