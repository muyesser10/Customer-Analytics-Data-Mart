/*
===============================================================================
Sprint 3 - Customer Behavioral Metrics Layer
===============================================================================

Purpose
-------
Build customer-level behavioral metrics based on purchase history and customer
activity over time.

Grain
-----
One row per customer.

Sources
-------
analytics.fact_sales
analytics.customer_revenue_metrics

Output
------
analytics.customer_behavior_metrics


Notes
-----
This layer transforms transactional purchase history into behavioral KPIs.
It measures customer lifecycle, purchase activity, and engagement over time.


===============================================================================
*/




CREATE OR REPLACE VIEW `analytics.customer_behavior_metrics` AS

WITH valid_sales AS(
  SELECT
    customer_key,
    order_number,
    order_date,
  FROM `analytics.fact_sales`
  WHERE order_date IS NOT NULL
),

reference_date AS(
  SELECT 
    MAX(order_date) AS reference_date
  FROM `analytics.fact_sales`
),

purchase_dates AS(
  SELECT
    customer_key,
    MIN(order_date) AS first_purchase_date,
    MAX(order_date) AS last_purchase_date,
  FROM valid_sales
  GROUP BY customer_key
),

customer_lifecycle AS(
  SELECT
    pd.customer_key,
    pd.first_purchase_date,
    pd.last_purchase_date,
    DATE_DIFF(pd.last_purchase_date,pd.first_purchase_date,DAY) AS customer_lifespan_days,
    DATE_DIFF(pd.last_purchase_date,pd.first_purchase_date,MONTH) AS customer_lifespan_months,
    DATE_DIFF(rd.reference_date,pd.last_purchase_date,DAY) AS recency_days
  FROM purchase_dates pd
  CROSS JOIN reference_date rd
),

customer_activity AS(
  SELECT
  customer_key,
  COUNT(DISTINCT FORMAT_DATE('%Y-%m', order_date)) AS active_months
  FROM valid_sales
  GROUP BY customer_key
)

SELECT
  cl.customer_key,
  cl.first_purchase_date,
  cl.last_purchase_date,
  cl.customer_lifespan_days,
  cl.customer_lifespan_months,
  cl.recency_days,
  ca.active_months,
  rm.total_orders,
  SAFE_DIVIDE(rm.total_orders,ca.active_months) AS purchase_frequency,
  SAFE_DIVIDE(cl.customer_lifespan_days,NULLIF(rm.total_orders-1,0)) AS purchase_interval_days,
  SAFE_DIVIDE(rm.total_orders,NULLIF(cl.customer_lifespan_months/12,0)) AS order_velocity

FROM customer_lifecycle cl

LEFT JOIN customer_activity ca
USING(customer_key)

LEFT JOIN `analytics.customer_revenue_metrics` rm
USING(customer_key)