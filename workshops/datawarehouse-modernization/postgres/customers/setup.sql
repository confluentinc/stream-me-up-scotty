-- # This is so high to accomodate workshops, where many attendees might create their own replication slots
ALTER SYSTEM SET max_wal_senders = '250';
ALTER SYSTEM SET wal_sender_timeout = '60s';
ALTER SYSTEM SET max_replication_slots = '250';
ALTER SYSTEM SET wal_level = 'logical';

CREATE SCHEMA customers;
SET search_path TO customers;

CREATE EXTENSION postgis;

-- # Create and populate the customer data table
CREATE TABLE customers (
    id VARCHAR(255) PRIMARY KEY, 
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(255)
);

COPY customers(id, first_name, last_name, email, phone)
FROM '/data/customers.csv'
DELIMITER ','
CSV HEADER;

-- # Create and populate the demographic data table
CREATE TABLE demographics (
    id VARCHAR(255) PRIMARY KEY,
    street_address VARCHAR(255),
    state VARCHAR(255),
    zip_code VARCHAR(255),
    country VARCHAR(255),
    country_code VARCHAR(255)
);

COPY demographics(id, street_address, state, zip_code, country, country_code)
FROM '/data/demographics.csv'
DELIMITER ','
CSV HEADER;

CREATE OR REPLACE PROCEDURE shuffle_customers() AS $$
BEGIN
    WHILE 1 = 1 LOOP
        DECLARE
            customer_id VARCHAR;
            new_phone VARCHAR;
        BEGIN
            SELECT id INTO customer_id FROM customers.customers ORDER BY random() LIMIT 1;
            SELECT CONCAT(CAST(FLOOR(RANDOM()*899+100) AS VARCHAR), '-', CAST(FLOOR(RANDOM()*899+100) AS VARCHAR), '-', CAST(FLOOR(RANDOM()*8999+1000) AS VARCHAR)) INTO new_phone;
            UPDATE customers.customers SET phone = new_phone WHERE id = customer_id;
            COMMIT;
            PERFORM pg_sleep(150);
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE shuffle_demographics() AS $$
BEGIN 
    WHILE 1 = 1 LOOP
        DECLARE
            customer_id VARCHAR;
            address_number VARCHAR;
            address_type VARCHAR;
            address_name VARCHAR;
            new_address VARCHAR;
        BEGIN
            SELECT id INTO customer_id FROM customers.demographics ORDER BY random() LIMIT 1;
            SELECT SPLIT_PART(street_address, ' ', 1) INTO address_number FROM customers.demographics ORDER BY RANDOM() LIMIT 1;
            SELECT SPLIT_PART(street_address, ' ', -1) INTO address_number FROM customers.demographics ORDER BY RANDOM() LIMIT 1;
            SELECT SUBSTRING(street_address FROM (CHAR_LENGTH(SPLIT_PART(street_address, ' ', 1))+2) FOR (CHAR_LENGTH(street_address)-CHAR_LENGTH(SPLIT_PART(street_address, ' ', -1))-CHAR_LENGTH(SPLIT_PART(street_address, ' ', 1))-2)) INTO address_name FROM customers.demographics ORDER BY RANDOM() LIMIT 1;
            SELECT address_number || ' ' || address_name || ' ' || address_type INTO new_address;
            UPDATE customers.demographics SET street_address = new_address WHERE id = customer_id;
            COMMIT;
            PERFORM pg_sleep(150);
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
