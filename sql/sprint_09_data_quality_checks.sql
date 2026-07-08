/*
===============================================================================
Sprint 9 - Data Quality Layer
===============================================================================

Purpose

Validate the integrity and reliability of the Customer Analytics Data Mart
by executing automated data quality checks after each ETL execution.

This layer identifies structural and business-level data quality issues
and records the results for operational monitoring and auditing.

Grain

One row per data quality check per execution.

Sources

analytics.customer_data_mart
analytics.dim_customers
analytics.fact_sales

Output

analytics.data_quality_results

Checks

• Null primary keys
• Duplicate customers
• Negative revenue
• Invalid dates
• Orphan records

Notes

This layer performs validation only.

No analytical KPIs or business metrics are calculated.

All quality checks are executed independently of the business logic layer
to ensure data reliability before downstream reporting and analytics.

===============================================================================
*/

-- =============================================================================
-- Data Quality Results Table
-- =============================================================================

CREATE TABLE IF NOT EXISTS `analytics.data_quality_results`(

  run_id STRING,
  check_name STRING,
  check_category STRING,
  severity STRING,
  failed_records INT64,
  status STRING,
  check_timestamp TIMESTAMP

);

-- =============================================================================
-- Refresh Data Quality Results
-- =============================================================================

TRUNCATE TABLE `analytics.data_quality_results`;

DECLARE v_run_id STRING;
DECLARE v_check_timestamp TIMESTAMP;

SET v_run_id=GENERATE_UUID();
SET v_check_timestamp=CURRENT_TIMESTAMP();

INSERT INTO `analytics.data_quality_results`(

  run_id,
  check_name,
  check_category,
  severity,
  failed_records,
  status,
  check_timestamp

)

-- ---------------------------------------------------------------------------
-- Null Primary Key Check
-- ---------------------------------------------------------------------------


SELECT 
  v_run_id,
  'Null Customer Key' AS check_name,
  'Null Check' AS check_category,
  'CRITICAL' AS severity,
  COUNT(*) AS failed_records,
  IF(COUNT(*)=0,'PASS','FAIL') AS status,
  v_check_timestamp
FROM `analytics.customer_data_mart`
WHERE customer_key IS NULL

UNION ALL

-- ---------------------------------------------------------------------------
-- Duplicate Customer Check
-- ---------------------------------------------------------------------------

SELECT
  v_run_id,
  'Duplicate Customer Check' AS check_name,
  'Duplicate Check' AS check_category,
  'CRITICAL' AS severity,
  COUNT(*) AS failed_records,
  IF(COUNT(*)=0,'PASS','FAIL'),
  v_check_timestamp
  
  FROM(

      SELECT 
        customer_key
      FROM `analytics.customer_data_mart`
      GROUP BY customer_key
      HAVING COUNT(*)>1

      )

UNION ALL

-- ---------------------------------------------------------------------------
-- Negative Revenue Check
-- ---------------------------------------------------------------------------

SELECT 
  v_run_id,
  'Negative Revenue' AS check_name,
  'Business Rule Check' AS check_category,
  'WARNING' AS severity,
  COUNT(*) AS failed_records,
  IF(COUNT(*)=0,'PASS','FAIL'),
  v_check_timestamp

FROM `analytics.customer_data_mart`
WHERE lifetime_revenue<0

UNION ALL

-- ---------------------------------------------------------------------------
-- Invalid Date Check
-- ---------------------------------------------------------------------------

SELECT
  v_run_id,
  'Invalid Purchase Date' AS check_name,
  'Date Validation' AS check_category,
  'CRITICAL' AS severity,
  COUNT(*) AS failed_records,
  IF(COUNT(*)=0,'PASS','FAIL'),
  v_check_timestamp

FROM `analytics.customer_data_mart`
WHERE first_purchase_date>last_purchase_date

UNION ALL

-- ---------------------------------------------------------------------------
-- Orphan Customer Check
-- ---------------------------------------------------------------------------

SELECT
  v_run_id,
  'Orphan Customer' AS check_name,
  'Referential Integrity' AS check_category,
  'CRITICAL' AS severity,
  COUNT(*) AS failed_records,
  IF(COUNT(*)=0,'PASS','FAIL'),
  v_check_timestamp
FROM `analytics.fact_sales` fs

LEFT JOIN `analytics.dim_customers` dc 
USING(customer_key)

WHERE dc.customer_key IS NULL;


-- =============================================================================
-- Validation Queries
-- =============================================================================

-- View all data quality check results

SELECT *
FROM `analytics.data_quality_results`
ORDER BY check_timestamp DESC,
         status,
         check_name;


-- Data Quality Summary

SELECT 
  status,
  COUNT(*) AS total_checks
FROM `analytics.data_quality_results`
GROUP BY status
ORDER BY status;


SELECT
  run_id,
  status,
COUNT(*) AS total_checks,
SUM(failed_records) AS total_failed_records

FROM `analytics.data_quality_results`
GROUP BY run_id,
         status

ORDER BY run_id DESC,
                status;


-- =============================================================================
-- Environment Note
-- =============================================================================
-- This script is designed for production BigQuery environments.
-- DDL/DML statements such as CREATE TABLE, TRUNCATE TABLE and INSERT
-- may not execute in the BigQuery Sandbox due to platform limitations.
