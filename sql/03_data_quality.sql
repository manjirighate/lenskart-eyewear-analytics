USE LenskartAnalytics;

SELECT
  SUM(order_date IS NULL)        AS null_dates,
  SUM(city = '' OR city IS NULL) AS blank_city,
  SUM(quantity <= 0)             AS bad_qty,
  SUM(unit_price <= 0)           AS bad_price,
  SUM(net_sales_amount < 0)      AS negative_sales,
  SUM(customer_age < 10 OR customer_age > 100) AS odd_age,
  SUM(discount_percent < 0 OR discount_percent > 100) AS odd_discount
FROM raw_sales;