-- Use \copy from psql client if COPY fails in pgAdmin

\copy product_category_name_translation
FROM 'C:/Users/YourName/Downloads/product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;
