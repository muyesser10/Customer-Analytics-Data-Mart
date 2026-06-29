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

### Customer Status (Lifecycle)

- Active → recency_days ≤ 90
- Inactive → 91–180 days
- Lost → > 180 days

---

### Customer Segment (Business Logic)

Priority-based rules:

1. VIP → lifetime_revenue in top 20% AND recency_days ≤ 90  
2. At Risk → 91–180 recency_days AND low frequency_score  
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

- revenue_score → NTILE over lifetime_revenue
- frequency_score → NTILE over total_orders
- recency_score → NTILE over recency_days (ASC)
- engagement_score → total_orders / active_months
- diversity_score → product + category diversity

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

---

## 🟦 Sprint 8 - Stored Procedure Automation

### Objective
Automate ETL pipeline.

### Procedure
- sp_build_customer_datamart

### Responsibilities
- TRUNCATE + INSERT
- KPI recalculation
- ETL logging
- execution tracking
- validation hooks

---

## 🟦 Sprint 9 - Data Quality Layer

### Objective
Ensure data integrity and reliability.

### Checks
- Null primary keys
- Duplicate customers
- Negative revenue
- Invalid dates
- Orphan records

---

## 🟦 Sprint 10 - Validation Layer

### Objective
Ensure consistency with source.

### Validations
- Revenue reconciliation
- Order count matching
- Customer count validation
- Sampling checks
- Aggregation checks

---

## 📌 Final Output

```sql
CALL sp_build_customer_datamart();