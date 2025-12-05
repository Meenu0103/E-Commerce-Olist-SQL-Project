-- Use \copy from psql client if COPY fails in pgAdmin.
-- Update the local file path before running this script.

\copy olist_customers
FROM '/path/to/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

