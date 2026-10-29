USE LenskartAnalytics;

SELECT product_category, COUNT(*) AS orders FROM raw_sales GROUP BY product_category ORDER BY orders DESC;
SELECT sales_channel, store_type, COUNT(*) AS orders FROM raw_sales GROUP BY sales_channel, store_type;
SELECT payment_mode, COUNT(*) AS orders FROM raw_sales GROUP BY payment_mode ORDER BY orders DESC;
SELECT customer_gender, COUNT(*) AS orders FROM raw_sales GROUP BY customer_gender;
SELECT COUNT(DISTINCT state) AS states, COUNT(DISTINCT city) AS cities FROM raw_sales;

SELECT COUNT(*) AS mismatched_rows
FROM raw_sales
WHERE ABS(net_sales_amount - quantity * unit_price * (1 - discount_percent/100)) > 1;