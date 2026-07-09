# 🚀 Sprint Breakdown - Customer Analytics Data Mart

---

## 🟦 Sprint 0 - Project Design (COMPLETED)

### Objective
Define architecture, business case, data dictionary, and analytical scope.

### Deliverables
- Business case
- Architecture design
- Roadmap
- Data dictionary

### Output
Foundation for all downstream analytics layers.

---

## 🟦 Sprint 1 - Customer Profile Layer

### Objective
Build the base customer entity and demographic enrichment layer.

### Outputs
- customer_key
- customer_number
- customer_name
- birth_date
- age
- age_group
- gender
- country

### Source
- dim_customers

### Notes
This is the **identity layer**. No aggregations yet. Only enriched customer attributes.

---

## 🟦 Sprint 2 - Revenue KPIs

### Objective
Build customer-level revenue aggregation layer.

### Outputs
- lifetime_revenue
- total_orders
- total_quantity
- distinct_products
- average_order_value
- revenue_per_month
- highest_order_value
- lowest_order_value

### Source
- fact_sales

### Dependency
Required for:
- value tier (Sprint 5)
- health score (Sprint 6)
- segmentation logic

---

## 🟦 Sprint 3 - Behavioral KPIs

### Objective
Model customer lifecycle and purchase behavior.

### Outputs
- first_purchase_date
- last_purchase_date
- recency_days
- customer_lifespan_days
- customer_lifespan_months
- active_months
- purchase_frequency
- purchase_interval_days
- order_velocity

### Key Design Rules
- recency_days is the **core driver metric**
- All segmentation and scoring systems depend on this layer

---

## 🟦 Sprint 4 - Product Analytics Layer

### Objective
Analyze customer-product interaction behavior.

### Outputs
- favorite_product
- favorite_category
- product_diversity
- category_diversity
- repeat_purchase_rate

### Key Implementation Rule
favorite_product MUST be computed using:

- aggregation CTE
- window function ranking
- top-1 selection per customer

---

## 🟦 Sprint 5 - Segmentation Layer

### Objective
Create business-driven customer classification system.

---

### Scoring Inputs

- revenue_score → NTILE(5) over lifetime_revenue
- frequency_score → NTILE(5) over total_orders

---

### Customer Status (Lifecycle)

- Active → recency_days ≤ 90
- Inactive → 91–180 days
- Lost → > 180 days

---

### Customer Segment (Business Logic)

Priority-based rules:

1. VIP → lifetime_revenue in top 20% AND recency_days ≤ 90  
2. At Risk → 91–180 recency_days AND frequency_score ≤ 2
3. Loyal → total_orders ≥ 10 AND recency_days ≤ 180  
4. New → customer_lifespan_days ≤ 90  

---

### Customer Value Tier

- NTILE(5) over lifetime_revenue

Mapping:
- 1 → Platinum
- 2 → Gold
- 3 → Silver
- 4 → Bronze
- 5 → Standard

---

## 🟦 Sprint 6 - Health Score Engine

### Objective
Build a composite customer scoring system for analytics & retention.

---

### Components

Uses ranking metrics generated in Sprint 5 together with additional behavioral scoring.

- recency_score → NTILE over recency_days (ASC)
- engagement_score → total_orders / active_months
- diversity_score → product + category diversity

Inputs from Sprint 5:

- revenue_score
- frequency_score

---

### Final Health Score Formula

```sql
health_score =
(0.30 * revenue_score +
 0.25 * frequency_score +
 0.20 * recency_score +
 0.15 * engagement_score +
 0.10 * diversity_score) * 20

---

## 🟦 Sprint 7 - Customer Data Mart Build

### Objective
Combine all layers into final dataset.

### Output Table
- customer_data_mart

### Includes
- Identity
- Demographics
- Revenue KPIs
- Behavioral KPIs
- Product KPIs
- Segmentation
- Health Score
- Flags
- Advanced Product Analytics

### Additional Analytical Metrics

The final Customer Data Mart enriches the analytical model with advanced
customer-product interaction metrics that are not required by downstream
layers but provide additional business value.

Included metrics:

- favorite_product_quantity
- favorite_category_share
- avg_products_per_order
- avg_categories_per_order
- single_category_customer
- cross_category_customer
- first_product_purchased
- last_product_purchased

---

## 🟦 Sprint 8 - Stored Procedure Automation

### Objective

Automate the end-to-end Customer Analytics Data Mart pipeline.

### Procedure

- sp_build_customer_datamart

### Responsibilities

- TRUNCATE + INSERT
- KPI recalculation
- ETL logging
- execution tracking
- Data Quality execution
- Validation execution

---

## 🟦 Sprint 9 - Data Quality Layer

### Objective

Ensure data integrity and reliability before downstream reporting and analytics.

### Output

- data_quality_results

### Automated Checks

- Null primary keys
- Duplicate customers
- Negative revenue
- Invalid dates
- Orphan records

### Monitoring Metadata

- ETL run identifier (run_id)
- Severity level (CRITICAL / WARNING)
- Execution timestamp
- PASS / FAIL status
- Failed record count

### Notes

The Data Quality layer validates structural integrity and business rules before analytical consumption. Validation results are stored independently for operational monitoring, auditing, and troubleshooting.

---

## 🟦 Sprint 10 - Validation Layer

### Objective

Validate that the Customer Analytics Data Mart is fully reconciled with source tables after ETL execution to ensure production-ready analytical consistency.

### Output

- validation_results

### Validation Rules

- Revenue reconciliation
- Order count validation
- Customer count validation
- Quantity aggregation validation
- Customer sampling validation

### Validation Metadata

- Validation run identifier (run_id)
- Validation timestamp
- Source value
- Target value
- Difference
- PASS / FAIL status

### Notes

The Validation layer performs post-ETL reconciliation between source tables and the Customer Data Mart.

Unlike the Data Quality layer, no business rules or data cleansing checks are performed. Validation focuses exclusively on verifying that ETL aggregations have been loaded correctly.

---

## 📌 Final Output

```sql
CALL sp_build_customer_datamart();
```

Execution Flow

Customer Data Mart Build

↓

Data Quality Checks

↓

Validation Layer

↓

Analytics Ready

---
