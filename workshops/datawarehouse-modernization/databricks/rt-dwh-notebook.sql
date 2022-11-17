-- Databricks notebook source
CREATE TABLE orders_enriched (order_id STRING, 
                                  product_id STRING, size STRING, product STRING, department STRING, price STRING,
                                  id STRING, first_name STRING, last_name STRING, email STRING, phone STRING,
                                  street_address STRING, state STRING, zip_code STRING, country STRING, country_code STRING,
                                  partition INT) USING DELTA;

-- COMMAND ----------

SELECT state, order_id FROM default.orders_enriched;

-- COMMAND ----------

select state, float(split(price, '[$]')[1]) as price from default.orders_enriched;

-- COMMAND ----------

SELECT * FROM default.orders_enriched;

-- COMMAND ----------


