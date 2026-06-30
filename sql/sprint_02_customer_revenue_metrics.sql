/*
===============================================================================
Sprint 2 - Customer Revenue Metrics Layer
===============================================================================

Purpose
-------
Build customer-level revenue metrics from transactional sales data.

Grain
-----
One row per customer.

Sources
-------
analytics.fact_sales

Output
------
analytics.customer_revenue_metrics

Notes
-----
This layer aggregates transaction-level sales into customer-level revenue KPIs.
It serves as the revenue foundation for segmentation, health scoring, and the
final Customer Analytics Data Mart.

===============================================================================
*/

CREATE OR REPLACE VIEW `analytics.customer_revenue_metrics` AS

WITH valid_sales AS (
  SELECT
    customer_key,
    order_number,
    product_key,
    order_date,
    quantity,
    sales_amount
  FROM `analytics.fact_sales`
  WHERE customer_key IS NOT NULL
      AND order_number IS NOT NULL
      AND order_date IS NOT NULL
      AND sales_amount IS NOT NULL

),

order_level_sales AS(
  SELECT
    customer_key,
    order_number,
    order_date,
    SUM(sales_amount) AS order_total
  FROM valid_sales
  GROUP BY customer_key,
           order_number,
           order_date
),

customer_revenue AS (
  SELECT
    customer_key,
    SUM(sales_amount) AS lifetime_revenue,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS distinct_products
  FROM valid_sales
  GROUP BY customer_key
),

order_statistics AS(
  SELECT
    customer_key,
    MAX(order_total) AS highest_order_value,
    MIN(order_total) AS lowest_order_value,
  FROM order_level_sales
  GROUP BY customer_key
)


SELECT
  cr.customer_key,
  cr.lifetime_revenue,
  cr.total_orders,
  cr.total_quantity,
  cr.distinct_products,
  SAFE_DIVIDE(cr.lifetime_revenue,cr.total_orders) AS average_order_value,
  os.highest_order_value,
  os.lowest_order_value,
FROM customer_revenue cr
LEFT JOIN order_statistics os
USING(customer_key)
