/*
===============================================================================
Sprint 8 - Customer Data Mart ETL Automation
===============================================================================

Purpose

Automate the loading process of the Customer Analytics Data Mart.

This sprint introduces the ETL orchestration layer responsible for
refreshing the final Customer Data Mart table and recording execution
metadata for operational monitoring.

Grain

One ETL execution per procedure run.

Sources

analytics.v_customer_data_mart

Outputs

analytics.customer_data_mart
analytics.etl_execution_log

Procedure

analytics.sp_build_customer_datamart

Responsibilities

• Refresh the Customer Data Mart table
• Generate a unique ETL run identifier
• Capture execution timestamps
• Log execution status
• Record loaded row count
• Provide extension points for data quality and validation checks

Notes

This layer contains no business calculations.

All analytical KPIs are consumed from previously validated analytical
views to ensure a clear separation between business logic and ETL
orchestration.

===============================================================================
*/

-- =============================================================================
-- Customer Data Mart Table
-- =============================================================================

CREATE TABLE IF NOT EXISTS `analytics.customer_data_mart` AS 

SELECT *
FROM `analytics.v_customer_data_mart`
WHERE FALSE;



CREATE TABLE IF NOT EXISTS `analytics.etl_execution_log`(

  run_id STRING,
  pipeline_name STRING,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  execution_duration_seconds INT64,
  rows_loaded INT64,
  status STRING,
  error_message STRING
  
);


-- =============================================================================
-- Stored Procedure
-- =============================================================================

CREATE OR REPLACE PROCEDURE `analytics.sp_build_customer_datamart`()

BEGIN

    -- Variable Declarations
    DECLARE v_run_id STRING;
    DECLARE v_start_time TIMESTAMP;
    DECLARE v_end_time TIMESTAMP;
    DECLARE v_rows_loaded INT64;

    -- Initialize ETL Metadata

    SET v_run_id = GENERATE_UUID();
    SET v_start_time = CURRENT_TIMESTAMP();

    -- Main ETL Process

    BEGIN

        -- Refresh Customer Data Mart

        TRUNCATE TABLE `analytics.customer_data_mart`;

        INSERT INTO `analytics.customer_data_mart`
        SELECT *
        FROM `analytics.v_customer_data_mart`;

        -- Capture Row Count

        SET v_rows_loaded= (
                            SELECT COUNT(*)
                            FROM `analytics.customer_data_mart`
                            );

        -- Finish Timestamp

        SET v_end_time = CURRENT_TIMESTAMP();

        -- Write Success Log

        INSERT INTO `analytics.etl_execution_log`(
          run_id,
          pipeline_name,
          start_time,
          end_time,
          execution_duration_seconds,
          rows_loaded,
          status,
          error_message
        )

        VALUES(
          v_run_id,
          'sp_build_customer_datamart',
          v_start_time,
          v_end_time,
          TIMESTAMP_DIFF(v_end_time,v_start_time,SECOND),
          v_rows_loaded,
          'SUCCESS',
          NULL
        );
    -- Error Handling
    EXCEPTION WHEN ERROR THEN 

      SET v_end_time = CURRENT_TIMESTAMP();
      INSERT INTO `analytics.etl_execution_log`(
        run_id,
        pipeline_name,
        start_time,
        end_time,
        execution_duration_seconds,
        rows_loaded,
        status,
        error_message)

      VALUES(
        v_run_id,
        'sp_build_customer_datamart',
        v_start_time,
        v_end_time,
        TIMESTAMP_DIFF(v_end_time,v_start_time,SECOND),
        0,
        'FAILED',
        @@error.message
      );
      RAISE;
    END;
END