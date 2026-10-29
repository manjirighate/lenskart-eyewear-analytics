USE LenskartAnalytics;

SELECT * FROM raw_sales LIMIT 5;

SELECT
  COUNT(*)                  AS total_rows,
  COUNT(DISTINCT order_id)  AS unique_orders,
  MIN(order_date)           AS first_date,
  MAX(order_date)           AS last_date,
  SUM(net_sales_amount)     AS total_sales
FROM raw_sales;