USE LenskartAnalytics;

-- ===== DIMENSION TABLES =====

-- Product category
CREATE TABLE dim_product_category (
  category_key     INT AUTO_INCREMENT PRIMARY KEY,
  product_category VARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO dim_product_category (product_category)
SELECT DISTINCT product_category FROM raw_sales ORDER BY product_category;

-- Location (city + state)
CREATE TABLE dim_location (
  location_key INT AUTO_INCREMENT PRIMARY KEY,
  city         VARCHAR(50) NOT NULL,
  state        VARCHAR(50) NOT NULL,
  UNIQUE (city, state)
);
INSERT INTO dim_location (city, state)
SELECT DISTINCT city, state FROM raw_sales ORDER BY state, city;

-- Channel (sales_channel + store_type)
CREATE TABLE dim_channel (
  channel_key   INT AUTO_INCREMENT PRIMARY KEY,
  sales_channel VARCHAR(20) NOT NULL,
  store_type    VARCHAR(30) NOT NULL,
  UNIQUE (sales_channel, store_type)
);
INSERT INTO dim_channel (sales_channel, store_type)
SELECT DISTINCT sales_channel, store_type FROM raw_sales;

-- Payment mode
CREATE TABLE dim_payment (
  payment_key  INT AUTO_INCREMENT PRIMARY KEY,
  payment_mode VARCHAR(30) NOT NULL UNIQUE
);
INSERT INTO dim_payment (payment_mode)
SELECT DISTINCT payment_mode FROM raw_sales;

-- Date: one row per day, 2022-01-01 to 2025-12-31
CREATE TABLE dim_date (
  date_key         INT PRIMARY KEY,        -- e.g. 20220115
  full_date        DATE NOT NULL UNIQUE,
  year_num         INT,
  quarter_num      INT,
  month_num        INT,
  month_name       VARCHAR(10),
  year_month_label CHAR(7),                -- e.g. 2022-01
  day_of_week      INT,
  day_name         VARCHAR(10),
  is_weekend       TINYINT
);

SET SESSION cte_max_recursion_depth = 2000;

INSERT INTO dim_date
WITH RECURSIVE d AS (
  SELECT DATE('2022-01-01') AS dt
  UNION ALL
  SELECT dt + INTERVAL 1 DAY FROM d WHERE dt < '2025-12-31'
)
SELECT DATE_FORMAT(dt, '%Y%m%d') + 0,
       dt,
       YEAR(dt),
       QUARTER(dt),
       MONTH(dt),
       DATE_FORMAT(dt, '%b'),
       DATE_FORMAT(dt, '%Y-%m'),
       DAYOFWEEK(dt),
       DATE_FORMAT(dt, '%a'),
       CASE WHEN DAYOFWEEK(dt) IN (1, 7) THEN 1 ELSE 0 END
FROM d;

-- ===== FACT TABLE =====

CREATE TABLE fact_sales (
  order_id         VARCHAR(20) PRIMARY KEY,
  date_key         INT NOT NULL,
  location_key     INT NOT NULL,
  category_key     INT NOT NULL,
  channel_key      INT NOT NULL,
  payment_key      INT NOT NULL,
  customer_gender  VARCHAR(10),
  customer_age     INT,
  quantity         INT,
  unit_price       DECIMAL(10,2),
  discount_percent DECIMAL(5,2),
  net_sales_amount DECIMAL(12,2),
  FOREIGN KEY (date_key)     REFERENCES dim_date(date_key),
  FOREIGN KEY (location_key) REFERENCES dim_location(location_key),
  FOREIGN KEY (category_key) REFERENCES dim_product_category(category_key),
  FOREIGN KEY (channel_key)  REFERENCES dim_channel(channel_key),
  FOREIGN KEY (payment_key)  REFERENCES dim_payment(payment_key)
);

INSERT INTO fact_sales
SELECT r.order_id,
       DATE_FORMAT(r.order_date, '%Y%m%d') + 0,
       l.location_key,
       c.category_key,
       ch.channel_key,
       p.payment_key,
       r.customer_gender,
       r.customer_age,
       r.quantity,
       r.unit_price,
       r.discount_percent,
       r.net_sales_amount
FROM raw_sales r
JOIN dim_location l          ON l.city = r.city AND l.state = r.state
JOIN dim_product_category c  ON c.product_category = r.product_category
JOIN dim_channel ch          ON ch.sales_channel = r.sales_channel
                            AND ch.store_type = r.store_type
JOIN dim_payment p           ON p.payment_mode = r.payment_mode;

-- ===== VALIDATION =====
SELECT (SELECT COUNT(*) FROM raw_sales)               AS raw_rows,
       (SELECT COUNT(*) FROM fact_sales)              AS fact_rows,
       (SELECT SUM(net_sales_amount) FROM raw_sales)  AS raw_total,
       (SELECT SUM(net_sales_amount) FROM fact_sales) AS fact_total;

SELECT d.year_num, COUNT(*) AS orders, SUM(f.net_sales_amount) AS net_sales
FROM fact_sales f
JOIN dim_date d ON d.date_key = f.date_key
GROUP BY d.year_num
ORDER BY d.year_num;

