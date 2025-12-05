-- Use \copy from psql client if COPY fails in pgAdmin

\copy olist_orders
FROM 'C:/Users/YourName/Downloads/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;
