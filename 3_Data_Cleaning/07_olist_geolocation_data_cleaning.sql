/* 
    OLIST GEOLOCATION – DATA CLEANING SCRIPT
    Dataset: olist_geolocation_dataset.csv
    Table: olist_geolocation
    Purpose: Validate geographic consistency (city/state), 
             coordinate ranges and ZIP code quality.
*/


-- 1. TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows
FROM olist_geolocation;


-- 2. NULL VALUE CHECKS
SELECT
    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS zip_nulls,
    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS lat_nulls,
    SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS lng_nulls,
    SUM(CASE WHEN geolocation_city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS state_nulls
FROM olist_geolocation;

/*
 Interpretation:
 - Nulls in coordinates → unusable for mapping.
 - Null city/state → poor geographic classification.
 - But no nulls found for this dataset
*/


-- 3. CHECK FOR CITY NAMES STARTING WITH NUMBERS (invalid)
SELECT *
FROM olist_geolocation
WHERE geolocation_city ~ '^[0-9]';


-- 4. FIX CITY NAMES THAT ARE ONLY NUMBERS
-- (Optional cleaning step — run only if you want to remove them)

UPDATE olist_geolocation
SET geolocation_city = NULL
WHERE geolocation_city ~ '^[0-9]+$';


-- 5. LATITUDE / LONGITUDE RANGE VALIDATION
-- Brazil latitude range approx:  -34 to +5
-- Brazil longitude range approx: -74 to -34

SELECT *
FROM olist_geolocation
WHERE geolocation_lat NOT BETWEEN -34 AND 5
   OR geolocation_lng NOT BETWEEN -74 AND -34;

/*
 Interpretation:
 - Any results here are invalid coordinates (outside Brazil).
*/


-- 6. ZIP CODE QUALITY CHECK
-- ZIP should be 5 digits (Brazilian CEP prefix)
SELECT *
FROM olist_geolocation
WHERE geolocation_zip_code_prefix::text !~ '^[0-9]{5}$';


/*
 Interpretation:
 - Values like "1037", "1046", "1012" appear because some ZIP prefixes have only 4 digits.
 - This is expected in Olist dataset — not a mistake.
 - We DO NOT fix them, but we FLAG them for awareness.
*/


-- 7. CHECK FOR DUPLICATE ZIP–CITY–STATE–COORDINATE ROWS
SELECT geolocation_zip_code_prefix, geolocation_city, geolocation_state, COUNT(*) AS occurrences
FROM olist_geolocation
GROUP BY 1,2,3
HAVING COUNT(*) > 1;

/*
 Interpretation:
 - Duplicates exist because Olist dataset stores multiple coordinate points per ZIP prefix.
 - These are NOT errors — they represent many samples per region.
*/



-- 8. STATE CODE VALIDATION
SELECT *
FROM olist_geolocation
WHERE LENGTH(geolocation_state) != 2;

/*
 Interpretation:
 - State codes should always be 2 letters (SP, RJ, MG, …).
*/

