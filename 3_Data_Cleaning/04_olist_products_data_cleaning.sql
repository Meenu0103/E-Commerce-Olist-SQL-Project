/*
    OLIST PRODUCTS – DATA CLEANING SCRIPT
    Dataset: olist_products_dataset.csv
    Table: olist_products
    Purpose: Validate product metadata (dimensions, weight, category, and missing values)
*/


-- TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows
FROM olist_products;


-- NULL VALUE CHECKS
SELECT
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS category_nulls,
    SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS name_length_nulls,
    SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS description_length_nulls,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS photos_nulls,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS weight_nulls,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS length_nulls,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS height_nulls,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS width_nulls
FROM olist_products;


/*
 Interpretation:
 - Many products in the original Olist dataset are missing dimensions.
 - product_category_name is often NULL → will later be joined with translation table.
*/


-- CHECK FOR DUPLICATE product_id (Should NEVER happen)
SELECT product_id, COUNT(*) AS occurrences
FROM olist_products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- VALIDATE DIMENSIONS (must be > 0)

-- Weight issues
SELECT *
FROM olist_products
WHERE product_weight_g <= 0;

-- Dimensions too small or zero
SELECT *
FROM olist_products
WHERE product_length_cm <= 0
   OR product_height_cm <= 0
   OR product_width_cm <= 0;



-- CHECK FOR EXTREME OUTLIERS

-- Very heavy items (possible data errors)
SELECT *
FROM olist_products
WHERE product_weight_g > 30000;  -- weight > 30kg unusual for Olist items


-- Very large boxes (flag for review)
SELECT *
FROM olist_products
WHERE product_length_cm > 200
   OR product_height_cm > 200
   OR product_width_cm > 200;



-- PRODUCT CATEGORY INTEGRITY

-- Unknown categories
SELECT *
FROM olist_products
WHERE product_category_name IS NULL;

-- Products with extremely short names
SELECT *
FROM olist_products
WHERE product_name_lenght < 10;

-- Products with no photos
SELECT *
FROM olist_products
WHERE product_photos_qty = 0;



/* COMMON NOTES:
   - Do NOT delete rows even if dimensions are missing → analysis requires them.
   - Instead, we will document missing values and handle during analysis.
*/
