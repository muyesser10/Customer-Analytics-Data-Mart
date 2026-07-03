/*
===============================================================================
Sprint 4 - Customer Product Metrics Layer
===============================================================================

Purpose
-------
Build customer-level product analytics and affinity metrics.

Grain
-----
One row per customer.

Sources
-------
analytics.fact_sales
analytics.dim_products

Output
------
analytics.customer_product_metrics

Notes
-----
This layer analyzes customer purchasing behavior at the product level.
It identifies favorite products, preferred categories, product diversity,
and repeat purchase behavior. These metrics support customer segmentation,
health scoring, and recommendation use cases.

===============================================================================
*/


CREATE OR REPLACE VIEW `analytics.customer_product_metrics` AS 

WITH base_sales AS(
  SELECT 
    fs.customer_key,
    fs.order_number,
    fs.product_key,
    dp.product_name,
    dp.category,
    fs.quantity,
  FROM `analytics.fact_sales` fs

  LEFT JOIN `analytics.dim_products` dp
  USING(product_key)
),

product_summary AS(
  SELECT
    customer_key,
    product_key,
    product_name,
    COUNT(*) AS purchase_count,
    SUM(quantity) AS total_quantity
  FROM base_sales
  GROUP BY customer_key,
           product_key,
           product_name 
),

favorite_product AS(
  SELECT *
  FROM(
      SELECT
        customer_key,
        product_name AS favorite_product,
        ROW_NUMBER() OVER(PARTITION BY customer_key ORDER BY purchase_count DESC,
                                                             total_quantity DESC,
                                                             product_name) AS rn
      FROM product_summary
      )
  WHERE rn=1
),

category_summary AS (
  SELECT
    customer_key,
    category,
    COUNT(*) AS purchase_count,
    SUM(quantity) AS total_quantity
  FROM base_sales
  GROUP BY customer_key,
           category
),

favorite_category AS(
  SELECT *
  FROM(
       SELECT
        customer_key,
        category AS favorite_category,
        ROW_NUMBER() OVER(PARTITION BY customer_key ORDER BY purchase_count DESC,
                                                             total_quantity DESC,
                                                             category) AS rn
       FROM category_summary
      )
  WHERE rn=1
),

diversity_metrics AS(
  SELECT
    customer_key,
    COUNT(DISTINCT product_key) AS product_diversity,
    COUNT(DISTINCT category) AS category_diversity
  FROM base_sales
  GROUP BY customer_key
),

repeat_purchase_metrics AS(
  SELECT
    customer_key,
    SAFE_DIVIDE(COUNTIF(purchase_count>1),COUNT(*)) AS repeat_purchase_rate
  FROM product_summary
  GROUP BY customer_key
)

SELECT

  dm.customer_key,
  fp.favorite_product,
  fc.favorite_category,
  dm.product_diversity,
  dm.category_diversity,
  rpm.repeat_purchase_rate

FROM diversity_metrics dm

LEFT JOIN favorite_product fp
USING(customer_key)

LEFT JOIN favorite_category fc
USING(customer_key)

LEFT JOIN repeat_purchase_metrics rpm
USING(customer_key)