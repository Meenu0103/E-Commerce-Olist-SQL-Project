-- Use \copy from psql client if COPY fails in pgAdmin

\copy olist_products
FROM 'C:/Users/YourName/Downloads/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;
