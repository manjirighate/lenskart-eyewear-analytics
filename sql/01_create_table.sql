SELECT VERSION();
CREATE DATABASE LenskartAnalytics;
USE LenskartAnalytics;

CREATE TABLE raw_sales (
  order_id          VARCHAR(20),
  order_date        DATE,
  city              VARCHAR(50),
  state             VARCHAR(50),
  sales_channel     VARCHAR(20),
  store_type        VARCHAR(30),
  product_category  VARCHAR(50),
  quantity          INT,
  unit_price        DECIMAL(10,2),
  discount_percent  DECIMAL(5,2),
  net_sales_amount  DECIMAL(12,2),
  payment_mode      VARCHAR(30),
  customer_gender   VARCHAR(10),
  customer_age      INT
);