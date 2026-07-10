# Customer Analytics Data Mart

An end-to-end Customer Analytics Data Mart built with **Google BigQuery**, following modern Data Engineering and Business Intelligence practices.

This project transforms raw transactional and dimensional data into a business-ready analytical model through a layered architecture. It combines customer profiling, revenue analytics, behavioral metrics, product insights, customer segmentation, health scoring, automated ETL, data quality checks, and validation controls to support reliable reporting and decision-making.

The implementation follows an incremental sprint-based development approach, where each layer builds upon the previous one to create a maintainable and scalable analytics solution.

---

# Project Overview

The primary objective of this project is to design a production-oriented Customer Analytics Data Mart that enables organizations to analyze customer behavior, measure business performance, and support data-driven decision making.

Rather than producing isolated SQL queries, the project demonstrates how analytical data products are developed in real-world environments using modular transformations, reusable SQL components, automated ETL processes, and operational monitoring.

The final solution includes:

- Customer profile enrichment
- Revenue and behavioral KPI modeling
- Product affinity analytics
- Business-driven customer segmentation
- Composite customer health scoring
- Centralized Customer Data Mart
- Automated ETL with Stored Procedures
- Data Quality framework
- Validation and reconciliation framework

---

# Business Problem

Operational systems are optimized for transaction processing rather than analytical reporting. As customer data grows across multiple tables, generating reliable business insights becomes increasingly complex and expensive.

Business teams often face challenges such as:

- Fragmented customer information
- Repeated KPI calculations across reports
- Inconsistent business definitions
- Limited visibility into customer lifecycle and purchasing behavior
- Manual validation of analytical outputs
- Lack of standardized monitoring after ETL execution

To address these challenges, organizations commonly implement analytical data marts that centralize business logic and provide a trusted, reusable data source for downstream reporting and analytics.

This project simulates that real-world scenario by designing a Customer Analytics Data Mart using production-oriented engineering principles.

---

# Solution Overview

The solution is implemented as a layered analytics architecture, where each sprint introduces a dedicated business capability while maintaining clear dependencies between analytical layers.

The architecture progressively evolves through:

- Customer identity and demographic modeling
- Revenue aggregation
- Behavioral analytics
- Product interaction analysis
- Customer segmentation
- Health score calculation
- Customer Data Mart construction
- Automated ETL execution
- Data Quality monitoring
- Validation and reconciliation

This layered approach improves maintainability, simplifies future enhancements, and promotes reusable business logic across analytical workloads.

---

# Repository Structure

```text
Customer-Analytics-Data-Mart/
│
├── datasets/
│
├── docs/
│   ├── architecture.md
│   ├── roadmap.md
│   ├── data_dictionary.md
│   ├── business_insights.md
│   ├── findings.md
│   └── changelog.md
│
├── sql/
│   ├── sprint_0_project_design.sql
│   ├── sprint_1_customer_profile.sql
│   ├── sprint_2_revenue_kpis.sql
│   ├── sprint_3_behavioral_kpis.sql
│   ├── sprint_4_product_analytics.sql
│   ├── sprint_5_segmentation.sql
│   ├── sprint_6_health_score.sql
│   ├── sprint_7_customer_data_mart.sql
│   ├── sprint_8_stored_procedure.sql
│   ├── sprint_9_data_quality.sql
│   └── sprint_10_validation.sql
│
├── images/
│
├── README.md
└── LICENSE
```

---

# Sprint Breakdown

The project was developed incrementally using a sprint-based approach, where each sprint introduced a new analytical capability while building on previously completed layers.

| Sprint | Description |
|---------|-------------|
| **Sprint 0** | Defined the business case, solution architecture, development roadmap, and data dictionary. |
| **Sprint 1** | Built the customer identity and demographic layer with enriched customer attributes. |
| **Sprint 2** | Developed customer-level revenue KPIs, including lifetime revenue, order metrics, and purchasing value indicators. |
| **Sprint 3** | Modeled customer behavioral analytics such as recency, lifespan, purchase frequency, and activity metrics. |
| **Sprint 4** | Implemented product analytics including favorite products, category preferences, diversity metrics, and repeat purchase behavior. |
| **Sprint 5** | Designed a business-driven customer segmentation framework using lifecycle rules, value tiers, and customer segments. |
| **Sprint 6** | Built a composite Customer Health Score by combining revenue, frequency, engagement, recency, and diversity indicators. |
| **Sprint 7** | Integrated all analytical layers into a centralized Customer Analytics Data Mart with additional advanced product metrics. |
| **Sprint 8** | Automated the ETL pipeline using a stored procedure with execution management and refresh logic. |
| **Sprint 9** | Implemented a Data Quality framework with automated integrity checks, execution metadata, and quality reporting. |
| **Sprint 10** | Developed a Validation framework to reconcile Data Mart outputs with source systems through financial, aggregation, and sampling validations. |

---

# Project Evolution

The project evolved from a basic analytical model into a production-oriented Customer Analytics Data Mart by progressively introducing new business capabilities and operational components.

```text
Project Design
        │
        ▼
Customer Profile
        │
        ▼
Revenue KPIs
        │
        ▼
Behavioral Analytics
        │
        ▼
Product Analytics
        │
        ▼
Customer Segmentation
        │
        ▼
Health Score Engine
        │
        ▼
Customer Data Mart
        │
        ▼
ETL Automation
        │
        ▼
Data Quality Framework
        │
        ▼
Validation Framework
```

Each sprint was designed to remain independent while providing reusable outputs for downstream analytical layers. This modular architecture improves maintainability, simplifies future enhancements, and reflects how analytical data platforms are typically developed in enterprise environments.


---

# Customer Analytics Data Mart Design

The final Customer Analytics Data Mart consolidates customer, transactional, and product information into a single analytical dataset with **one row per customer**.

The model follows a layered architecture where each analytical domain is developed independently and integrated into the final Data Mart, ensuring reusable business logic and simplified downstream reporting.

```text
Customer Data Mart
│
├── Identity
├── Demographics
├── Revenue KPIs
├── Behavioral KPIs
├── Product Analytics
│      ├── Core KPIs
│      └── Advanced KPIs
├── Customer Segmentation
├── Health Score
├── Business Flags
└── ETL Metadata
```

This design separates business domains while providing a unified analytical model for reporting, dashboarding, customer segmentation, and business intelligence.

---

# Key Business Metrics

The Customer Data Mart contains a comprehensive set of business metrics designed to support customer analytics and operational reporting.

### Revenue Analytics

- Lifetime Revenue
- Total Orders
- Total Quantity Purchased
- Average Order Value
- Revenue per Active Month
- Highest Order Value
- Lowest Order Value

### Customer Behavior

- First Purchase Date
- Last Purchase Date
- Customer Lifespan
- Recency
- Purchase Frequency
- Purchase Interval
- Active Months
- Order Velocity

### Product Analytics

- Favorite Product
- Favorite Category
- Product Diversity
- Category Diversity
- Repeat Purchase Rate
- Favorite Product Share
- Favorite Category Share
- Average Products per Order
- Average Categories per Order
- First Purchased Product
- Last Purchased Product

### Customer Segmentation

- Customer Status
- Customer Segment
- Customer Value Tier

### Customer Scoring

- Revenue Score
- Frequency Score
- Recency Score
- Engagement Score
- Diversity Score
- Customer Health Score

### Business Flags

- Active Customer
- VIP Customer
- High Value Customer
- At Risk Customer
- Churned Customer

---

# SQL Techniques

This project demonstrates practical SQL patterns commonly used in modern Data Engineering and Business Intelligence workflows.

### Query Design

- Common Table Expressions (CTEs)
- Multi-step SQL transformations
- Modular query design
- Reusable business logic

### Analytical SQL

- Window Functions
- Ranking Functions
- Aggregate Functions
- Conditional Logic (CASE)
- Date Calculations

### Data Modeling

- Fact and Dimension modeling
- Customer-level aggregations
- Business KPI calculations
- Layered Data Mart design

### Production SQL

- Stored Procedures
- ETL Automation
- Data Quality Framework
- Validation & Reconciliation
- Execution Metadata
- Audit Logging

### BigQuery Features

- Standard SQL
- DECLARE / SET variables
- CREATE TABLE IF NOT EXISTS
- TRUNCATE + INSERT pattern
- UUID generation
- Random sampling


---

# Production Features

Beyond analytical modeling, the project incorporates several operational components commonly found in modern data platforms. These features improve automation, reliability, and maintainability while supporting production-oriented analytics workflows.

## ETL Automation

The Customer Data Mart is generated through a dedicated stored procedure that automates the entire refresh process.

### Stored Procedure

```sql
CALL analytics.sp_build_customer_datamart();
```

### Responsibilities

- Refresh the Customer Data Mart
- Recalculate all analytical KPIs
- Execute transformations in the correct dependency order
- Simplify scheduled ETL execution
- Provide a reusable entry point for future orchestration

This approach separates transformation logic from execution logic and enables repeatable Data Mart refreshes with a single procedure call.

---

## Data Quality Framework

A dedicated Data Quality layer validates the integrity of source and analytical data before downstream reporting.

### Automated Checks

- Null Primary Keys
- Duplicate Customers
- Negative Revenue
- Invalid Dates
- Orphan Records

Each execution generates standardized quality results including:

- Run Identifier
- Validation Category
- Severity Level
- Failed Record Count
- PASS / FAIL Status
- Execution Timestamp

The framework supports operational monitoring, troubleshooting, and quality auditing independently from business transformations.

---

## Validation Framework

After the Data Mart is refreshed, an independent validation layer reconciles analytical outputs against the source system to verify ETL correctness.

### Validation Rules

- Revenue Reconciliation
- Customer Count Validation
- Order Count Validation
- Quantity Aggregation Validation
- Random Customer Sampling Validation

Each validation execution records:

- Run Identifier
- Validation Category
- Source Value
- Target Value
- Difference
- PASS / FAIL Status
- Validation Timestamp

Unlike the Data Quality framework, this layer focuses on reconciliation rather than business rule validation, providing additional confidence before downstream reporting.

---

# How to Run

Execute the project components in the following order.

## 1. Create Source Tables

```text
dim_customers
dim_products
fact_sales
```

## 2. Execute Sprint Scripts

Run the SQL scripts sequentially from Sprint 1 through Sprint 10.

```text
Sprint 1 → Customer Profile
Sprint 2 → Revenue KPIs
Sprint 3 → Behavioral KPIs
Sprint 4 → Product Analytics
Sprint 5 → Segmentation
Sprint 6 → Health Score
Sprint 7 → Customer Data Mart
Sprint 8 → Stored Procedure
Sprint 9 → Data Quality
Sprint 10 → Validation
```

## 3. Build the Customer Data Mart

```sql
CALL analytics.sp_build_customer_datamart();
```

## 4. Review Operational Results

After execution, review the generated monitoring tables.

```text
analytics.customer_data_mart
analytics.data_quality_results
analytics.validation_results
```

These tables provide the analytical output together with operational quality and validation information generated during the ETL process.



---

# Future Improvements

Although the current implementation provides a complete Customer Analytics Data Mart, the architecture has been designed to support future enhancements commonly found in enterprise analytics platforms.

Potential improvements include:

### Data Engineering

- Incremental ETL processing
- Partitioned and clustered BigQuery tables
- Configuration-driven validation framework
- Historical snapshot management (SCD Type 2)
- Workflow orchestration with Apache Airflow

### Data Quality & Monitoring

- Freshness validation
- Volume anomaly detection
- Schema drift monitoring
- Automated alerting
- Historical quality trend reporting

### Analytics

- RFM segmentation
- Customer Lifetime Value (CLV) modeling
- Churn prediction
- Cohort analysis
- Market Basket Analysis

### Reporting

- Interactive Power BI dashboard
- Executive KPI dashboard
- Customer segmentation dashboard
- Data Quality monitoring dashboard
- Validation monitoring dashboard

These enhancements would further strengthen the platform by improving scalability, operational monitoring, and advanced analytical capabilities.

---

# Author

**Müyesser Şenyüz**

Software Engineer | Data Analytics | Business Intelligence | Data Engineering

### Connect with me

- **LinkedIn:** [Müyesser Şenyüz](https://www.linkedin.com/in/muyessersenyuz/)
- **GitHub:** [@muyesser10](https://github.com/muyesser10)

---

## Project Status

**Completed**

This project demonstrates the end-to-end development of a Customer Analytics Data Mart using Google BigQuery, covering analytical modeling, ETL automation, Data Quality, and Validation frameworks through a structured sprint-based implementation.