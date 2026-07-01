# Data Dictionary - Customer Analytics Data Mart

Customer Data Mart

│

├── Identity

├── Demographics

├── Revenue KPIs

├── Behavioral KPIs

├── Product Analytics

│      ├── Core KPIs

│      └── Advanced KPIs

├── Segmentation

├── Health Score

├── Flags

└── Metadata

## Purpose

This document defines all columns in the Customer Analytics Data Mart.  

---

## Grain

**Grain:** 1 row per `customer_key` per latest ETL snapshot

Each record represents the current state of a customer.

---

# Identity

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| customer_key | INT64 | Unique customer identifier | Direct mapping from dimension table | dim_customers |
| customer_number | STRING | Business customer ID | Source system identifier | dim_customers |
| customer_name | STRING | Full name of customer | CONCAT(first_name, last_name) | dim_customers |

---

# Demographics

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| birth_date | DATE | Customer birth date | Direct mapping | dim_customers |
| age | INT64 | Current age | DATE_DIFF(CURRENT_DATE(), birth_date, YEAR) | Calculated |
| age_group | STRING | Age segmentation bucket | CASE: <20, 20–29, 30–39, 40–49, 50+ | Calculated |
| gender | STRING | Customer gender | Direct mapping | dim_customers |
| country | STRING | Customer country | Direct mapping | dim_customers |

---

# Revenue KPIs

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| lifetime_revenue | NUMERIC | Total revenue generated | SUM(sales_amount) | fact_sales |
| total_orders | INT64 | Total unique orders | COUNT(DISTINCT order_number) | fact_sales |
| total_quantity | INT64 | Total items purchased | SUM(quantity) | fact_sales |
| distinct_products | INT64 | Unique products purchased | COUNT(DISTINCT product_key) | fact_sales |
| average_order_value | NUMERIC | Revenue per order | lifetime_revenue / total_orders | Calculated |
| revenue_per_month | NUMERIC | Monthly average revenue | lifetime_revenue / NULLIF(active_months,0) | Calculated |
| highest_order_value | NUMERIC | Max order value | MAX(order_total) | fact_sales |
| lowest_order_value | NUMERIC | Min order value | MIN(order_total) | fact_sales |

---

# Behavioral KPIs

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| first_purchase_date | DATE | First purchase date | MIN(order_date) | fact_sales |
| last_purchase_date | DATE | Last purchase date | MAX(order_date) | fact_sales |
| customer_lifespan_days | INT64 | Active relationship duration | DATE_DIFF(last_purchase_date, first_purchase_date, DAY) | Calculated |
| customer_lifespan_months | INT64 | Lifetime in months | DATE_DIFF(last_purchase_date, first_purchase_date, MONTH) | Calculated |
| recency_days | INT64 | Days since last purchase | DATE_DIFF(CURRENT_DATE(), last_purchase_date, DAY) | Calculated |
| purchase_frequency | FLOAT64 | Orders per month | total_orders / NULLIF(active_months,0) | Calculated |
| purchase_interval_days | FLOAT64 | Avg gap between purchases | customer_lifespan_days / NULLIF(total_orders-1,1) | Calculated |
| active_months | INT64 | Months with activity | COUNT(DISTINCT FORMAT_DATE('%Y-%m', order_date)) | fact_sales |
| order_velocity | FLOAT64 | Orders per year | total_orders / NULLIF(customer_lifespan_months/12,1) | Calculated |

---

# Product Analytics

## Core Product KPIs

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| favorite_product | STRING | Most purchased product | ROW_NUMBER() OVER (PARTITION BY customer_key ORDER BY COUNT(*) DESC) = 1 | Calculated |
| favorite_category | STRING | Most purchased category | Highest purchase frequency category | fact_sales + dim_products |
| product_diversity | INT64 | Number of unique products | COUNT(DISTINCT product_key) | fact_sales |
| category_diversity | INT64 | Number of categories purchased | COUNT(DISTINCT category) | dim_products |
| repeat_purchase_rate | FLOAT64 | Repeat purchase ratio | repeat_orders / total_orders | Calculated |


## Advanced Product Analytics

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| favorite_product_quantity | INT64 | Total quantity purchased for the favorite product | SUM(quantity) for favorite_product | Calculated |
| favorite_product_share | FLOAT64 | Share of purchases from favorite product | favorite_product_quantity / total_quantity | Calculated |
| favorite_category_share | FLOAT64 | Share of purchases from favorite category | favorite_category_quantity / total_quantity | Calculated |
| avg_products_per_order | FLOAT64 | Average number of products purchased per order | AVG(distinct_products_per_order) | Calculated |
| avg_categories_per_order | FLOAT64 | Average number of distinct categories per order | AVG(distinct_categories_per_order) | Calculated |
| single_category_customer | BOOLEAN | Customer purchases from only one category | category_diversity = 1 for all purchases | Calculated |
| cross_category_customer | BOOLEAN | Customer purchases from multiple categories | category_diversity > 1 across purchase history | Calculated |
| first_product_purchased | STRING | First purchased product | Product purchased in customer's earliest completed order. | Calculated |
| last_product_purchased | STRING | Most recently purchased product |Product purchased in customer's most recent completed order. | Calculated |

---

# Segmentation

## Customer Status

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| customer_status | STRING | Customer lifecycle status | Active: ≤ 90 days<br>Inactive: 91–180 days<br>Lost: > 180 days | recency_days |

---

## Customer Segment

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| customer_segment | STRING | Business segment | VIP / Loyal / New / At Risk | Rule-based |

### Rules (Priority Order)

- VIP → lifetime_revenue in top 20% AND recency_days ≤ 90  
- At Risk → recency_days 91–180 AND frequency_score ≤ 2  
- Loyal → total_orders ≥ 10 AND recency_days ≤ 180  
- New → customer_lifespan_days ≤ 90  

Priority: VIP > At Risk > Loyal > New

---

## Customer Value Tier

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| customer_value_tier | STRING | Revenue tier | NTILE(5) over lifetime_revenue | fact_sales |

Mapping:
- 1 → Platinum  
- 2 → Gold  
- 3 → Silver  
- 4 → Bronze  
- 5 → Standard  

---

# Health Score

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| revenue_score | INT64 | Revenue performance | NTILE(5) over lifetime_revenue | Calculated |
| frequency_score | INT64 | Purchase frequency | NTILE(5) over total_orders | Calculated |
| recency_score | INT64 | Customer recency | NTILE(5) ASC on recency_days | Calculated |
| engagement_score | INT64 | Activity intensity | total_orders / NULLIF(active_months,1) then bucketed | Calculated |
| diversity_score | INT64 | Product diversity | (product_diversity + category_diversity) NTILE(5) | Calculated |
| health_score | INT64 | Overall health score | Weighted sum scaled to 0–100 | Calculated |

### Health Score Formula

health_score =
(0.30 * revenue_score +
0.25 * frequency_score +
0.20 * recency_score +
0.15 * engagement_score +
0.10 * diversity_score) * 20

---

# Flags

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| is_active_customer | BOOLEAN | Active customer flag | recency_days ≤ 90 | Calculated |
| is_vip | BOOLEAN | VIP customer | Platinum AND recency_days ≤ 90 | Calculated |
| is_high_value | BOOLEAN | Top customers | Top 20% revenue | Calculated |
| is_at_risk | BOOLEAN | Churn risk | recency_days 91–180 AND frequency_score ≤ 2 | Calculated |
| is_churned | BOOLEAN | Lost customer | recency_days > 180 | Calculated |

---

# Metadata

| Column | Data Type | Description | KPI / Calculation Logic | Source |
|--------|----------|-------------|--------------------------|--------|
| data_refresh_date | TIMESTAMP | ETL timestamp | CURRENT_TIMESTAMP() | ETL |
| etl_run_id | STRING | ETL run identifier | UUID | ETL |
| record_created_at | TIMESTAMP | Record timestamp | CURRENT_TIMESTAMP() | ETL |

---