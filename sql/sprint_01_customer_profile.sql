/*
=============================================================
Sprint 1 - Customer Profile Layer
=============================================================

Purpose
-------
Build the foundational customer profile.

Grain
-----
One row per customer.

Sources
-------
analytics.dim_customers
analytics.fact_sales

Output
------
analytics.customer_profile

=============================================================
*/

CREATE OR REPLACE VIEW `analytics.customer_profile` AS

WITH base_customers AS (

    SELECT
        customer_key,
        customer_number,
        CONCAT(first_name, ' ', last_name) AS customer_name,
        birthdate AS birth_date,
        gender,
        country
    FROM `analytics.dim_customers`

),

global_params AS (

    SELECT
        MAX(order_date) AS reference_date
    FROM `analytics.fact_sales`

),

customers_with_age AS (

    SELECT
        *,
        CASE
            WHEN birth_date IS NULL THEN NULL
            ELSE DATE_DIFF(reference_date, birth_date, YEAR)
        END AS age
    FROM base_customers 
    CROSS JOIN global_params 

)

SELECT

    customer_key,
    customer_number,
    customer_name,
    birth_date,
    gender,
    country,

    age,

    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group

FROM customers_with_age;


