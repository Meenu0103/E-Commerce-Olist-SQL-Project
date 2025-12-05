-- Use \copy from psql client if COPY fails in pgAdmin

\copy olist_sellers
FROM 'C:/Users/YourName/Downloads/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;
