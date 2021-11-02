CREATE SCHEMA bank;
SET search_path to bank;

CREATE EXTENSION postgis;

CREATE TABLE customers (
	customer_id VARCHAR(50) PRIMARY KEY,
	first_name VARCHAR(25),
	last_name VARCHAR(25),
	phone_number VARCHAR(25),
	email_address VARCHAR(50),
	street_address VARCHAR(100),
	city VARCHAR(50),
	state_province VARCHAR(50),
	country VARCHAR(50),
	country_code VARCHAR(10),
	postal_code VARCHAR(15)
);

COPY customers(customer_id, first_name, last_name, phone_number, email_address, street_address, city, state_province, country, country_code, postal_code)
FROM '/data/customers.csv' 
DELIMITER ',' 
CSV HEADER;

CREATE TABLE accounts (
	account_id VARCHAR(50) PRIMARY KEY,
	customer_id VARCHAR(50),
	card_number VARCHAR(50),
	account_type VARCHAR(25),
	account_tier VARCHAR(25), 
	account_standing VARCHAR(25)
);

COPY accounts(account_id, customer_id, card_number, account_type, account_tier, account_standing)
FROM '/data/accounts.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE transactions (
	transaction_id VARCHAR(50) PRIMARY KEY,
	transaction_amount INT,
	card_number VARCHAR(50)
);

COMMIT;