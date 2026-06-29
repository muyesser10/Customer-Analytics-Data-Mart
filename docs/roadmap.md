# 📌 ROADMAP - Customer Analytics Data Mart

## 🎯 Project Overview

This project aims to build a **Customer Analytics Data Mart** that transforms raw transactional data into a customer-centric analytical model.

The final output supports:
- Customer segmentation
- Revenue analytics
- Behavioral analysis
- Customer health monitoring
- Executive reporting dashboards

---

## 🧭 Project Structure

The project follows a structured **ETL + Analytics Engineering workflow**.

---

# 🚀 Sprint Roadmap

---

## 🟦 Sprint 0 - Project Design & Architecture

### Objective
Define the analytical foundation before SQL development.

### Deliverables
- Business case definition
- Architecture design
- Data flow mapping
- Sprint roadmap
- Data dictionary

### Files
- docs/business_case.md
- docs/architecture.md
- docs/roadmap.md
- docs/data_dictionary.md
---

## 🟦 Sprint 1 - Customer Profile Layer

### Objective
Build the base customer-level dataset.

### Focus
- Customer identity
- Demographics enrichment
- Basic attributes

### Outputs
- customer_key
- customer_name
- age
- age_group
- gender
- country

### Source Tables
- dim_customers

---

## 🟦 Sprint 2 - Revenue KPIs

### Objective
Transform transactional data into revenue metrics.

### Key Metrics
- lifetime_revenue
- total_orders
- total_quantity
- distinct_products
- average_order_value
- revenue_per_month
- highest_order_value
- lowest_order_value

### Source Tables
- fact_sales

---

## 🟦 Sprint 3 - Behavioral KPIs

### Objective
Analyze customer activity patterns.

### Key Metrics
- first_purchase_date
- last_purchase_date
- recency_days
- customer_lifespan_days
- customer_lifespan_months
- purchase_frequency
- purchase_interval_days
- active_months
- order_velocity

---

## 🟦 Sprint 4 - Product Analytics Layer

### Objective
Analyze customer-product interactions.

### Key Metrics
- favorite_product
- favorite_category
- product_diversity
- category_diversity
- repeat_purchase_rate

### Source Tables
- fact_sales
- dim_products

---

## 🟦 Sprint 5 - Segmentation Layer

### Objective
Build business-driven segmentation.

---

### Customer Status Rules

| Status | Rule |
|--------|------|
| Active | recency_days ≤ 90 |
| Inactive | 91–180 days |
| Lost | > 180 days |

---

### Customer Segment Rules

| Segment | Rule |
|--------|------|
| VIP | Top 20% revenue + recency ≤ 90 |
| Loyal | total_orders ≥ 10 + recency ≤ 180 |
| New | lifespan ≤ 90 days |
| At Risk | 91–180 recency + low frequency |

---

### Customer Value Tier

- Based on NTILE(5) over lifetime_revenue

---

## 🟦 Sprint 6 - Health Score Engine

### Objective
Build composite customer scoring system.

### Score Components
- revenue_score
- frequency_score
- recency_score
- engagement_score
- diversity_score

### Weights
- Revenue: 30%
- Frequency: 25%
- Recency: 20%
- Engagement: 15%
- Diversity: 10%

### Output
- health_score (0–100)

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
- ETL run tracking
- Logging

---

## 🟦 Sprint 9 - Data Quality Layer

### Objective
Ensure data integrity.

### Checks
- Null keys
- Duplicate customers
- Negative revenue
- Invalid dates
- Orphan records
- Outliers

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