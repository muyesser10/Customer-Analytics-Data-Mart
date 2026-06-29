# Architecture - Customer Analytics Data Mart

## Data Flow

Raw Data Layer
(Fact & Dimension Tables)

```
        │
        ▼
```

Data Transformation Layer
(SQL ETL using Modular CTEs)

```
        │
        ├── Customer Profile
        ├── Revenue KPIs
        ├── Behavioral KPIs
        ├── Product Analytics
        ├── Customer Segmentation
        ├── Customer Health Score
        │
        ▼
```

Customer Data Mart
(Analytics Layer)

```
        │
        ▼
```

Stored Procedure

```
analytics.sp_build_customer_datamart()
```

Responsibilities

- Refresh Customer Data Mart
- Execute ETL Pipeline
- Rebuild Customer KPIs
- Run Data Quality Checks
- Execute Validation Rules
- Log Refresh Metadata

```
        │
        ▼
```

Business Intelligence Layer

- Power BI
- Executive Dashboards
- Self-Service Analytics

---

# Core Source Tables

| Table | Description |
|---------|-------------|
| fact_sales | Transaction-level sales records |
| dim_customers | Customer master data |
| dim_products | Product master data |

---

# Transformation Components

| Component | Purpose |
|-----------|----------|
| Customer Profile | Build customer identity and demographic attributes |
| Revenue KPIs | Calculate revenue-related metrics |
| Behavioral KPIs | Measure purchasing behavior |
| Product Analytics | Analyze product preferences and diversity |
| Segmentation | Assign business segments based on customer behavior |
| Health Score | Calculate overall customer health score |
| Data Quality | Validate data integrity before publishing |
| Validation | Compare Data Mart metrics with source tables |

---

# Output Layer

Final Table

```
analytics.customer_data_mart
```

This table serves as the single source of truth for customer-level analytics and is optimized for BI reporting, executive dashboards, customer segmentation, and downstream analytical workloads.

---

# Execution Flow

```
fact_sales
dim_customers
dim_products
        │
        ▼
SQL Transformations (CTEs)
        │
        ▼
Customer Data Mart
        │
        ▼
sp_build_customer_datamart()
        │
        ├── Refresh Data Mart
        ├── Data Quality Checks
        ├── Validation
        ├── Logging
        ▼
Power BI 
```