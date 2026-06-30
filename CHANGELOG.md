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