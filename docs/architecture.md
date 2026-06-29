# Architecture - Customer Analytics Data Mart

## Data Flow

fact_sales + dim_customers + dim_products
                │
                ▼
        ETL Transformation Layer
                │
   ┌────────────┼─────────────┐
   ▼            ▼             ▼
Revenue     Behavior     Product Analytics
   │            │             │
   └──────┬─────┴──────┬─────┘
          ▼
   Segmentation Layer
          ▼
     Health Score Engine
          ▼
   Customer Data Mart
          ▼
 BI / Dashboard Layer