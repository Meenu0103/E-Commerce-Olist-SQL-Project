-- Use \copy from psql client if COPY fails in pgAdmin

\copy olist_geolocation
FROM 'C:/Users/YourName/Downloads/olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;
