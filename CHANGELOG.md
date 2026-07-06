Customer Analytics Data Mart - Changelog

This document tracks all changes, enhancements, and iterations made to the Customer Analytics Data Mart project.

The project follows an incremental **ETL + Analytics Engineering sprint-based approach**.

---

## 🟦 Sprint 0 - Project Initialization

### Added
- Business case definition
- Architecture design
- Data dictionary
- Sprint roadmap definition
---

## 🟦 Sprint 1 - Customer Profile Layer

### Added

- Created `customer_profile` analytical view
- Implemented customer identity layer
- Added demographic attributes
  - customer_name
  - birth_date
  - age
  - age_group
  - gender
  - country
- Calculated customer age using dataset reference date
- Implemented age group classification
- Established customer-level grain (1 row per customer)

---

## 🟦 Sprint 2 - Customer Revenue Metrics Layer

### Added

- Created `customer_revenue_metrics` analytical view
- Aggregated transactional sales to customer level
- Implemented revenue KPIs
  - lifetime_revenue
  - total_orders
  - total_quantity
  - distinct_products
  - average_order_value
  - revenue_per_month
  - highest_order_value
  - lowest_order_value
- Used SAFE_DIVIDE to prevent division-by-zero errors
- Established reusable revenue layer for downstream analytics

---

## 🟦 Sprint 3 - Customer Behavioral Metrics Layer

### Added

- Created `customer_behavior_metrics` analytical view
- Built customer lifecycle metrics
  - first_purchase_date
  - last_purchase_date
  - customer_lifespan_days
  - customer_lifespan_months
  - recency_days
- Implemented customer activity metrics
  - active_months
  - purchase_frequency
  - purchase_interval_days
  - order_velocity
- Used latest transaction date as reference date for reproducible calculations
- Reused `customer_revenue_metrics` to avoid duplicated business logic
- Established reusable behavioral layer for segmentation and health scoring

---


## 🟦 Sprint 4 - Customer Product Metrics Layer

### Added

- Created `customer_product_metrics` analytical view

- Implemented core product analytics
  - favorite_product
  - favorite_category
  - product_diversity
  - category_diversity
  - repeat_purchase_rate

- Added advanced product analytics
  - favorite_product_quantity
  - favorite_product_share
  - favorite_category_share
  - avg_products_per_order
  - avg_categories_per_order
  - single_category_customer
  - cross_category_customer
  - first_product_purchased
  - last_product_purchased

- Used window functions to identify favorite products and categories
- Built reusable aggregation layers to avoid duplicated calculations
- Established reusable product analytics layer for health scoring and the Customer Data Mart


---

## 🟦 Sprint 5 - Customer Segmentation Layer

### Added

- Customer segmentation layer (`customer_segmentation`)
- Revenue ranking using `NTILE(5)`
- Frequency ranking using `NTILE(5)`
- Customer lifecycle status classification
- Business-driven customer segments
- Customer value tier classification


## 🟦 Sprint 6 - Customer Health Score Layer

### Added

- Created `customer_health_score` analytical view
- Implemented customer health scoring framework
- Calculated standardized scoring metrics
  - revenue_score
  - frequency_score
  - recency_score
  - engagement_score
  - diversity_score
- Built engagement metric using orders per active month
- Built diversity metric using combined product and category diversity
- Standardized customer metrics using `NTILE(5)` ranking
- Applied a consistent scoring convention
  - 1 = Best
  - 5 = Worst
- Inverted ranking scores during health score calculation to produce positive weighted contributions
- Calculated weighted composite `health_score` using revenue, frequency, recency, engagement, and diversity scores
- Established reusable customer health scoring layer for the Customer Data Mart

---

