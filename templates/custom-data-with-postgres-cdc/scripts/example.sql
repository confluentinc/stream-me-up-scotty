-- # Things like 'pg_cron' can be configured/added. An example of this
-- # can be seen in 'example.sh' included
-- ALTER SYSTEM SET shared_preload_libraries = 'pg_cron';

CREATE SCHEMA products;
SET search_path TO products;

CREATE EXTENSION postgis;
-- # Add other extensions like pg_cron
-- CREATE EXTENSION pg_cron;

-- # Create a table that matches the schema of your CSV
-- # or data file. 
CREATE TABLE products (
	product_id VARCHAR(255) PRIMARY KEY,
    size VARCHAR(255),
    product VARCHAR(255),
    department VARCHAR(255),
    price VARCHAR(255)
);

-- # Copy the data from the CSV into the table
COPY products(product_id, size, product, department, price)
FROM '/data/products.csv'
DELIMITER ','
CSV HEADER;

-- # Add anything else your heart desires, such as the following,
-- # which can be used to create randomized change events, but is more complicated
-- CREATE OR REPLACE PROCEDURE change_prices() AS $$
-- BEGIN
--     WHILE 1 = 1 LOOP
--         DECLARE 
--             id VARCHAR;
--             old_price DOUBLE PRECISION;
--             price_delta DOUBLE PRECISION;
--             new_price DOUBLE PRECISION;
--         BEGIN
--             SELECT product_id INTO id FROM products.products ORDER BY random() LIMIT 1;
--             SELECT CAST(TRIM(leading '$' FROM price) AS DOUBLE PRECISION) INTO old_price FROM products.products WHERE product_id = id;

--             SELECT random()*(5) INTO price_delta; 
--             IF random() >= 0.5 THEN
--                 price_delta := price_delta * -1;
--             END IF;

--             IF old_price <= 10.0 THEN
--                 new_price := old_price + random()*(5);
--             ELSE
--                 new_price := old_price + price_delta;
--             END IF;

--             UPDATE products.products SET price = CONCAT('$', CAST(new_price AS VARCHAR)) WHERE product_id = id;
--             COMMIT;
--             PERFORM pg_sleep(150);
--         END;
--     END LOOP;
-- END;
-- $$ LANGUAGE plpgsql;