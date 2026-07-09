/*
===============================================================================
Sprint 10 - Validation Layer
===============================================================================

Purpose

Validate that the Customer Analytics Data Mart is fully reconciled with
its source tables after ETL execution.

Unlike the Data Quality layer, which verifies structural and business
rules, this layer validates that aggregated values stored in the
Customer Data Mart accurately match the source data.

This layer provides reconciliation results for operational monitoring,
auditing and production deployment confidence.

Grain

One row per validation rule per execution.

Sources

analytics.customer_data_mart
analytics.dim_customers
analytics.fact_sales

Output

analytics.validation_results

Validation Rules

• Revenue reconciliation
• Customer count validation
• Order count validation
• Aggregation validation
• Sampling validation

Notes

This layer performs reconciliation only.

No business metrics are recalculated.

Validation results are stored independently from the ETL and Data Quality
layers to provide an additional production verification step before
downstream reporting.

===============================================================================
*/

-- Validation Results Table

CREATE TABLE IF NOT EXISTS `analytics.validation_results`(

    run_id STRING,
    validation_name STRING,
    validation_category STRING,
    source_value NUMERIC,
    target_value NUMERIC,
    difference NUMERIC,
    status STRING,
    validation_timestamp TIMESTAMP

);


-- Validation Execution Metadata


TRUNCATE TABLE `analytics.validation_results`;

DECLARE v_run_id STRING;
DECLARE v_validation_timestamp TIMESTAMP;
DECLARE v_sample_size INT64;

SET v_run_id=GENERATE_UUID();
SET v_validation_timestamp= CURRENT_TIMESTAMP();
SET v_sample_size=10;


-- Revenue Reconciliation

INSERT INTO `analytics.validation_results`

WITH revenue_validation AS(
  SELECT
          (SELECT
            SUM(sales_amount)
          FROM `analytics.fact_sales`) AS source_value,

          (SELECT
            SUM(lifetime_revenue)
          FROM `analytics.customer_data_mart`) AS target_value
        )

SELECT
  v_run_id,
  'Revenue Reconciliation' AS validation_name,
  'Financial Validation' AS validation_category,
  source_value,
  target_value,
  source_value-target_value AS difference,

  IF(source_value=target_value,
  'PASS',
  'FAIL') AS status,

  v_validation_timestamp
FROM revenue_validation;


-- Order Count Validation

INSERT INTO `analytics.validation_results`

WITH order_validation AS (
  SELECT
        (SELECT
          COUNT(DISTINCT order_number)
        FROM `analytics.fact_sales`) AS source_value,

        (SELECT
          SUM(total_orders)
        FROM `analytics.customer_data_mart`) AS target_value
)

SELECT
  v_run_id,
  'Order Count Validation' AS validation_name,
  'Aggregation' AS validation_category,
  source_value,
  target_value,
  source_value-target_value AS difference,

  IF(source_value=target_value,
    'PASS',
    'FAIL') AS status,

  v_validation_timestamp
FROM order_validation;


-- Customer Count Validation

INSERT INTO `analytics.validation_results`

WITH customer_validation AS(
  SELECT
        (SELECT
          COUNT(*)
        FROM `analytics.dim_customers`) AS source_value,

        (SELECT
          COUNT(*)
        FROM `analytics.customer_data_mart`) AS target_value
)


SELECT
  v_run_id,
  'Customer Count Validation' AS validation_name,
  'Completeness Validation' AS validation_category,
  source_value,
  target_value,
  source_value-target_value AS difference,

  IF(source_value=target_value,
     'PASS',
     'FAIL') AS status,

  v_validation_timestamp

FROM customer_validation;


-- Aggregation Validation

INSERT INTO `analytics.validation_results`

WITH quantity_validation AS(
  SELECT
        (SELECT
          SUM(quantity)
        FROM `analytics.fact_sales`) AS source_value,

        (SELECT
          SUM(total_quantity)
        FROM `analytics.customer_data_mart`) AS target_value
)

SELECT
  v_run_id,
  'Quantity Aggregation Validation' AS validation_name,
  'Aggregation Validation' AS validation_category,
  source_value,
  target_value,
  source_value-target_value AS difference,

  IF(source_value=target_value,
      'PASS',
      'FAIL') AS status,

  v_validation_timestamp
FROM quantity_validation;


-- Sampling Validation

INSERT INTO `analytics.validation_results`

WITH sampled_customers AS(
  SELECT 
    customer_key
  FROM `analytics.customer_data_mart`
  ORDER BY RAND()
  LIMIT v_sample_size
),

source_revenue AS(
  SELECT
    customer_key,
    SUM(sales_amount) AS revenue
  FROM `analytics.fact_sales`
  WHERE customer_key IN(SELECT
                          customer_key
                        FROM sampled_customers)
  GROUP BY customer_key 
),

target_revenue AS(
  SELECT
  customer_key,
  SUM(lifetime_revenue) AS revenue
  FROM `analytics.customer_data_mart`
  WHERE customer_key IN(SELECT
                          customer_key
                        FROM sampled_customers)
  GROUP BY customer_key
),

validation_result AS(
  SELECT
    COUNT(*) AS matched_customers
  FROM source_revenue s

  JOIN target_revenue t
  USING(customer_key)

  WHERE s.revenue=t.revenue

)

SELECT
  v_run_id,
  'Customer Sampling Validation' AS validation_name,
  'Sampling Validation' AS validation_category,
  v_sample_size AS source_value,
  matched_customers AS target_value,
  v_sample_size-matched_customers AS difference,

  IF(v_sample_size=matched_customers,
      'PASS',
      'FAIL') AS status,

  v_validation_timestamp
FROM validation_result;

-- View Validation Results

SELECT *
FROM `analytics.validation_results`
ORDER BY validation_timestamp DESC,
         validation_name;


-- Validation Summary

SELECT
  status,
  COUNT(*) AS total_validations
FROM `analytics.validation_results`
GROUP BY status
ORDER BY status;


-- Validation Run Summary

SELECT
  run_id,
  status,
  COUNT(*) AS total_validations
FROM `analytics.validation_results`
GROUP BY run_id,
         status

ORDER BY run_id DESC,
         status

-- =============================================================================
-- Environment Note
-- =============================================================================
-- This script is designed for production BigQuery environments.
-- DDL/DML statements such as CREATE TABLE, TRUNCATE TABLE and INSERT
-- may not execute in the BigQuery Sandbox due to platform limitations.
