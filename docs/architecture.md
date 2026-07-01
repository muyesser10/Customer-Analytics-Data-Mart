# Architecture - Customer Analytics Data Mart

## Data Flow

fact_sales + dim_customers + dim_products
            │
            ▼
   ETL Transformation Layer
            │
 ┌──────────┼──────────────┐
 ▼          ▼              ▼
Revenue   Behavior   Product Analytics
                        │
                        ├── Favorite Product
                        ├── Favorite Category
                        ├── Product Diversity
                        ├── Repeat Purchase
                        ├── Product Affinity
                        └── Purchase Journey
            │
            ▼
     Segmentation Layer
            ▼
    Health Score Engine
            ▼
   Customer Data Mart
            ▼
    BI / Dashboard Layer