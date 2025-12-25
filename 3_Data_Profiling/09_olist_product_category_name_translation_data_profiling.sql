/* 
    PRODUCT CATEGORY NAME TRANSLATION – DATA PROFILING SCRIPT
    Dataset: product_category_name_translation.csv
    Table: product_category_name_translation
    Purpose: Validate mapping quality between Portuguese -> English category names.
*/

-- 1. TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows
FROM product_category_name_translation;


-- 2. NULL VALUE CHECKS
SELECT
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS portuguese_name_nulls,
    SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END) AS english_name_nulls
FROM product_category_name_translation;



-- 3. DUPLICATE CHECKS
-- Portuguese category names must be UNIQUE
SELECT product_category_name, COUNT(*) AS occurrences
FROM product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

/* 
 Interpretation:
   - Duplicates mean multiple English translations -> should not exist.
*/


-- 4. CHECK FOR INVALID CHARACTERS (numbers, symbols)
SELECT *
FROM product_category_name_translation
WHERE product_category_name ~ '[0-9]';

SELECT *
FROM product_category_name_translation
WHERE product_category_name_english ~ '[0-9]';

/*
 Interpretation:
   - Category names should be text-only, rarely include numbers.
*/


-- 5. CHECK FOR LEADING / TRAILING SPACES
SELECT *
FROM product_category_name_translation
WHERE product_category_name LIKE ' %'
   OR product_category_name LIKE '% '
   OR product_category_name_english LIKE ' %'
   OR product_category_name_english LIKE '% ';


-- Optional FIX
UPDATE product_category_name_translation
SET product_category_name = TRIM(product_category_name),
    product_category_name_english = TRIM(product_category_name_english);


-- 6. CHECK CATEGORY NAMES NOT PRESENT IN PRODUCTS TABLE
-- (important for validating joins)
SELECT pct.product_category_name
FROM product_category_name_translation pct
LEFT JOIN olist_products p
  ON pct.product_category_name = p.product_category_name
WHERE p.product_id IS NULL;


-- 7. CHECK FOR MISSING TRANSLATION FOR CATEGORIES IN PRODUCTS TABLE
SELECT DISTINCT p.product_category_name
FROM olist_products p
LEFT JOIN product_category_name_translation pct
  ON p.product_category_name = pct.product_category_name
WHERE pct.product_category_name IS NULL;

/*
 Interpretation:
   - These are categories that appear in the products dataset but do NOT exist in the translation table.
*/


/* 8. SUMMARY
   - No duplicates found in translation table.
   - Some categories in the products table do not exist here (normal).
   - No action should be taken unless building a strict dictionary.
*/
