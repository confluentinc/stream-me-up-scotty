CREATE TABLE customers (id varchar(3) PRIMARY KEY, name varchar(10), age INT, membership varchar);

CREATE TABLE orders (customer_id varchar(3), order_id varchar(2) PRIMARY KEY, price INT, product_code varchar(3));


