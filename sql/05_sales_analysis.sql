USE LenskartAnalytics;

-- 1. Is order_id unique? (should return 0)
SELECT COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids
FROM raw_sales;

-- 2. Date range of the data
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order
FROM raw_sales;

-- 3. Monthly sales trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       COUNT(*) AS orders,
       SUM(quantity) AS units,
       SUM(net_sales_amount) AS net_sales
FROM raw_sales
GROUP BY month
ORDER BY month;

-- 4. Sales by category
SELECT product_category,
       COUNT(*) AS orders,
       SUM(net_sales_amount) AS net_sales,
       ROUND(AVG(net_sales_amount), 2) AS avg_order_value
FROM raw_sales
GROUP BY product_category
ORDER BY net_sales DESC;

-- 5. Top 10 states by revenue
SELECT state, SUM(net_sales_amount) AS net_sales
FROM raw_sales
GROUP BY state
ORDER BY net_sales DESC
LIMIT 10;

-- 6. Customer age groups
SELECT CASE
         WHEN customer_age < 25 THEN '18-24'
         WHEN customer_age < 35 THEN '25-34'
         WHEN customer_age < 45 THEN '35-44'
         ELSE '45+' END AS age_group,
       COUNT(*) AS orders,
       SUM(net_sales_amount) AS net_sales
FROM raw_sales
GROUP BY age_group
ORDER BY age_group;