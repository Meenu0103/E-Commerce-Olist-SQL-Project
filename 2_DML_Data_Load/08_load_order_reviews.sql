-- Use \copy from psql client if COPY fails in pgAdmin

\copy olist_order_reviews
FROM 'C:/Users/YourName/Downloads/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;
