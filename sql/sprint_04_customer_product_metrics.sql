/*
===============================================================================
Sprint 4 - Customer Product Metrics Layer
===============================================================================

Purpose
-------
Build customer-level product analytics by modeling purchasing behavior,
product preferences, category affinity, diversity metrics, and advanced
customer-product interaction metrics.

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
This layer consolidates both core and advanced product analytics into a
single customer-level view.

Core Product KPIs include:
- favorite_product
- favorite_category
- product_diversity
- category_diversity
- repeat_purchase_rate

Advanced Product Analytics include:
- favorite_product_quantity
- favorite_product_share
- favorite_category_share
- avg_products_per_order
- avg_categories_per_order
- single_category_customer
- cross_category_customer
- first_product_purchased
- last_product_purchased

These metrics provide deeper insight into customer purchasing behavior
and are consumed by downstream segmentation, health scoring, and the
Customer Data Mart.

===============================================================================
*/


CREATE OR REPLACE VIEW `analytics.customer_product_metrics` AS 

WITH base_sales AS(
  SELECT 
    fs.customer_key,
    fs.order_number,
    fs.order_date,
    fs.product_key,
    dp.product_name,
    dp.category,
    fs.quantity
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
),

customer_product_totals AS(
  SELECT
    customer_key,
    SUM(total_quantity) AS total_quantity
  FROM product_summary
  GROUP BY customer_key
),

customer_category_totals AS(
  SELECT
  customer_key,
  SUM(total_quantity) AS total_quantity
  FROM category_summary
  GROUP BY customer_key
),

favorite_product_metrics AS(
  SELECT 
    fp.customer_key,
    ps.total_quantity AS favorite_product_quantity,
    SAFE_DIVIDE(ps.total_quantity,cpt.total_quantity) AS favorite_product_share
    
  FROM favorite_product fp
  
  JOIN  product_summary ps
  ON fp.customer_key=ps.customer_key
  AND fp.favorite_product=ps.product_name

  
  JOIN customer_product_totals cpt
  ON fp.customer_key=cpt.customer_key
),

favorite_category_metrics AS(
  SELECT
    fc.customer_key,
    SAFE_DIVIDE(cs.total_quantity,cct.total_quantity) AS favorite_category_share

  FROM favorite_category fc

  JOIN category_summary cs
  ON fc.customer_key=cs.customer_key
  AND fc.favorite_category=cs.category

  JOIN customer_category_totals cct
  ON fc.customer_key=cct.customer_key
),

order_metrics AS(
  SELECT
    customer_key,
    AVG(products_per_order) AS avg_products_per_order,
    AVG(categories_per_order) AS avg_categories_per_order

  FROM(
        SELECT
          customer_key,
          order_number,
          COUNT(DISTINCT product_key) AS products_per_order,
          COUNT(DISTINCT category) AS categories_per_order
        FROM base_sales
        GROUP BY  customer_key,
                  order_number                
      )
  GROUP BY customer_key
),

customer_category_flags AS(
  SELECT
    customer_key,
    category_diversity=1 AS single_category_customer,
    category_diversity>1 AS cross_category_customer
  FROM diversity_metrics
),

purchase_journey AS(
  SELECT
    customer_key,
    MAX(
        IF(first_purchase=1,product_name,NULL)
        ) AS first_product_purchased,

    MAX(
        IF(last_purchase=1,product_name,NULL)
        ) AS last_product_purchased

  FROM(
        SELECT
          customer_key,
          product_name,

          ROW_NUMBER() OVER(PARTITION BY customer_key ORDER BY order_date,
                                                               order_number,
                                                               product_name) AS first_purchase,

          ROW_NUMBER() OVER(PARTITION BY customer_key ORDER BY order_date DESC,
                                                               order_number DESC,
                                                               product_name DESC) AS last_purchase
        FROM base_sales  
      )
  GROUP BY customer_key
)

SELECT

  dm.customer_key,

  -- Core Product KPIs
  fp.favorite_product,
  fc.favorite_category,
  dm.product_diversity,
  dm.category_diversity,
  rpm.repeat_purchase_rate,

  -- Advanced Product Analytics
  fpm.favorite_product_quantity,
  fpm.favorite_product_share,
  fcm.favorite_category_share,
  om.avg_products_per_order,
  om.avg_categories_per_order,
  ccf.single_category_customer,
  ccf.cross_category_customer,
  pj.first_product_purchased,
  pj.last_product_purchased


FROM diversity_metrics dm

LEFT JOIN favorite_product fp
USING(customer_key)

LEFT JOIN favorite_category fc
USING(customer_key)

LEFT JOIN repeat_purchase_metrics rpm
USING(customer_key)

LEFT JOIN favorite_product_metrics fpm
USING(customer_key)

LEFT JOIN favorite_category_metrics fcm
USING(customer_key)

LEFT JOIN order_metrics om
USING(customer_key)

LEFT JOIN customer_category_flags ccf
USING (customer_key)

LEFT JOIN purchase_journey pj
USING (customer_key)