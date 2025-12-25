/* 
    OLIST GEOLOCATION – DATA PROFILING SCRIPT
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
 - Nulls in coordinates -> unusable for mapping.
 - Null city/state -> poor geographic classification.
 - But no nulls found for this dataset
*/


-- 3. CHECK FOR CITY NAMES WITH ONLY NUMBERS (invalid)
SELECT *
FROM olist_geolocation
WHERE geolocation_city ~ '^[0-9]+$';


-- 4. LATITUDE / LONGITUDE RANGE VALIDATION
-- Brazil latitude range approx:  -34 to +5
-- Brazil longitude range approx: -74 to -34

select * from olist_geolocation
where geolocation_lat NOT BETWEEN -34 AND 5
   OR geolocation_lng NOT BETWEEN -74 AND -34;


CREATE TABLE geography_cleaned as (
SELECT *,
CASE 
  WHEN
   geolocation_lat NOT BETWEEN -34 AND 5
   OR geolocation_lng NOT BETWEEN -74 AND -34
  THEN 'Invalid Geography'
  ELSE 'Brazil'
END AS geography_flag
FROM olist_geolocation
)

SELECT * from geography_cleaned
where geography_flag != 'Brazil';


/*
 Interpretation:
 - Any results here are invalid coordinates (outside Brazil), so it was flagged.
*/


-- 5. CHECK FOR MULIPLE ZIP–CITY–STATE–COORDINATE ROWS
SELECT geolocation_zip_code_prefix, geolocation_city, geolocation_state, COUNT(*) AS occurrences
FROM olist_geolocation
GROUP BY 1,2,3
HAVING COUNT(*) > 1;

/*
 Interpretation:
 - These are not duplicates because Olist dataset stores multiple coordinate points per ZIP prefix.
 - These are NOT errors - they represent many samples per region.
*/



-- 6. STATE CODE VALIDATION
SELECT *
FROM olist_geolocation
WHERE LENGTH(geolocation_state) != 2;

/*
 Interpretation:
 - State codes should always be 2 letters (SP, RJ, MG, …).
*/
