-- Use \copy from psql client if COPY fails in pgAdmin

\copy olist_order_items
FROM 'C:/Users/YourName/Downloads/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

