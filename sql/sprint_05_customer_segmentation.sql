/*
===============================================================================
Sprint 5 - Customer Segmentation Layer
===============================================================================

Purpose
-------
Build customer segmentation logic based on revenue, frequency, and behavior.

Grain
-----
One row per customer.


Outputs
-------
- revenue_score
- frequency_score
- customer_status
- customer_segment
- customer_value_tier

===============================================================================
*/

CREATE OR REPLACE VIEW `analytics.customer_segmentation` AS

WITH customer_metrics AS(
  SELECT
    rm.customer_key,
    rm.lifetime_revenue,
    rm.total_orders,
    bm.recency_days,
    bm.customer_lifespan_days
    
  FROM `analytics.customer_revenue_metrics` rm 

  INNER JOIN `analytics.customer_behavior_metrics` bm 
  USING(customer_key)
),

ranked_customers AS(
  SELECT *,
    NTILE(5) OVER(ORDER BY lifetime_revenue DESC) AS revenue_score,
    NTILE(5) OVER(ORDER BY total_orders DESC) AS frequency_score
  FROM customer_metrics
)

SELECT
  customer_key,
  revenue_score,
  frequency_score,

  CASE
      WHEN recency_days<=90 THEN 'Active'
      WHEN recency_days<=180 THEN 'Inactive'
      ELSE 'Lost'
  END AS customer_status,

  CASE
      WHEN revenue_score=1 AND recency_days<=90 THEN 'VIP'
      WHEN recency_days BETWEEN 91 AND 180  AND frequency_score<=2 THEN 'At Risk'
      WHEN total_orders>=10 AND recency_days<=180 THEN 'Loyal'
      WHEN customer_lifespan_days<=90 THEN 'New'
      ELSE 'Regular'
  END AS customer_segment,

  CASE revenue_score
      WHEN 1 THEN 'Platinum'
      WHEN 2 THEN 'Gold'
      WHEN 3 THEN 'Silver'
      WHEN 4 THEN 'Bronze'
      ELSE 'Standart'
  END AS customer_value_tier
  
FROM ranked_customers