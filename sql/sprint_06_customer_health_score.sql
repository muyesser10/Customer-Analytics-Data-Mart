/*
===============================================================================
Sprint 6 - Customer Health Score Layer
===============================================================================

Purpose
-------
Build a composite customer health scoring layer by combining revenue,
behavioral, and product analytics metrics into standardized customer scores.

Grain
-----
One row per customer.

Sources
-------
analytics.customer_segmentation
analytics.customer_behavior_metrics
analytics.customer_product_metrics

Output
------
analytics.customer_health_score

Notes
-----
This layer standardizes customer performance using NTILE-based scoring
and produces the final health_score (20–100), which will be consumed by
the Customer Data Mart.

Scoring Convention
------------------
All score metrics follow a consistent ranking convention:

• 1 = Best
• 5 = Worst

Metrics where higher values indicate better performance
(revenue, frequency, engagement, diversity)
are ranked in DESC order.

The recency metric is ranked in ASC order because
lower recency_days indicates a healthier customer.

During health score calculation, scores are inverted
using (6 - score) so that higher weighted values
represent healthier customers.

===============================================================================
*/


CREATE OR REPLACE VIEW `analytics.customer_health_score` AS

WITH base_scores AS(
  SELECT

    s.customer_key,
    s.revenue_score,
    s.frequency_score,

    b.recency_days,
    b.total_orders,
    b.active_months,

    p.product_diversity,
    p.category_diversity

  FROM `analytics.customer_segmentation` s

  JOIN `analytics.customer_behavior_metrics` b 
  USING(customer_key)  

  JOIN `analytics.customer_product_metrics` p
  USING(customer_key)
),

derived_metrics AS(
  SELECT 
    customer_key,
    revenue_score,
    frequency_score,
    recency_days,
    total_orders,
    active_months,
    product_diversity,
    category_diversity,

    SAFE_DIVIDE(total_orders,
                NULLIF(active_months,0)) AS engagement_metric,

    (product_diversity + category_diversity) AS diversity_metric

  FROM base_scores
),

scored_metrics AS (
  SELECT *,

  NTILE(5) OVER(ORDER BY recency_days ASC)  AS recency_score, 

  NTILE(5) OVER(ORDER BY engagement_metric DESC) AS engagement_score, 

  NTILE(5) OVER (ORDER BY diversity_metric  DESC) AS diversity_score 

  FROM derived_metrics
)


-- Convert ranking scores (1 = Best, 5 = Worst)
-- into weighted point scores (5 = Best, 1 = Worst)
-- before calculating the composite health score.

SELECT
  customer_key,
  revenue_score,
  frequency_score,
  recency_score,
  engagement_score,
  diversity_score,

  CAST
    (ROUND
        (
        ((6-revenue_score)*0.30+
        (6-frequency_score)*0.25+
        (6-recency_score)*0.20+
        (6-engagement_score)*0.15+
        (6-diversity_score)*0.10)*20
        ) AS INT64) 
  AS health_score

FROM scored_metrics