-- Use \copy from psql client if COPY fails in pgAdmin

\copy olist_order_payments
FROM 'C:/Users/YourName/Downloads/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;
