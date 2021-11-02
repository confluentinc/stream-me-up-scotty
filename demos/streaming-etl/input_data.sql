INSERT INTO customers (id, name, age, membership) VALUES ('001', 'Ironman', 45, 'premium');
INSERT INTO customers (id, name, age, membership) VALUES ('005', 'Blackwidow', 35, 'standard');
INSERT INTO customers (id, name, age, membership) VALUES ('007', 'Shangchi', 40, 'standard');

INSERT INTO orders (customer_id, order_id, price, product_code) VALUES ('001', '20', 65, 'x01');
INSERT INTO orders (customer_id, order_id, price, product_code) VALUES ('005', '21', 65, 'x01');
INSERT INTO orders (customer_id, order_id, price, product_code) VALUES ('001', '22', 50, 'y01');
INSERT INTO orders (customer_id, order_id, price, product_code) VALUES ('001', '31', 350, 'z03');
INSERT INTO orders (customer_id, order_id, price, product_code) VALUES ('007', '33', 65, 'x01');
INSERT INTO orders (customer_id, order_id, price, product_code) VALUES ('005', '39', 175, 'z01');
INSERT INTO orders (customer_id, order_id, price, product_code) VALUES ('001', '40', 500, 'y02');
INSERT INTO orders (customer_id, order_id, price, product_code) VALUES ('005', '41', 90, 'x02');
INSERT INTO orders (customer_id, order_id, price, product_code) VALUES ('007', '44', 1000, 'y03');

