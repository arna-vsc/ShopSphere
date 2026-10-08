# ShopSphere E-Commerce Analytics Engine

## End-to-End Business Intelligence & Revenue Optimization Architecture

---

## Executive Summary

**ShopSphere E-Commerce Analytics Engine** is an end-to-end business intelligence project designed to analyze sales performance, profitability, customer value, and reverse logistics across an e-commerce business.

The project analyzes **93,987 completed transactions** generating **₹2,07,03,84,938.12 (~₹2.07 Billion)** in net revenue.

Instead of performing heavy transformations and joins inside Power BI, the project engineers data hygiene, ETL, business logic, and customer cohort modeling directly in **MySQL 8.0** through a structured analytical modeling layer.

The curated analytical models are then connected to a **4-page Power BI executive dashboard**, providing decision-ready insights across:

* Sales performance
* Category and margin health
* Customer RFM and lifetime value
* Returns and reverse logistics

---

# Key Enterprise Metrics

| Metric                    |                            Value |
| ------------------------- | -------------------------------: |
| Completed Orders          |                       **93,987** |
| Total Net Sales           | **₹2,07,03,84,938.12 (~₹2.07B)** |
| Gross Profit              | **₹32,99,40,081.07 (~₹329.94M)** |
| Realized Gross Margin     |                       **15.94%** |
| Average Order Value (AOV) |                   **₹22,028.42** |
| Active Customer Base      |      **15,000 unique customers** |
| Total Units Returned      |                  **9,977 units** |
| Return Rate               |                        **5.14%** |

---

# System Architecture & Data Flow

The project follows a layered architecture:


Raw CSV Data
     │
     ▼
Python Automated Ingestion
     │
     ▼
MySQL Staging & Data Quality
     │
     ▼
Data Cleaning & Transformation
     │
     ▼
Business Analysis Layer
     │
     ▼
8 Analytical SQL Views
     │
     ▼
Power BI Semantic Layer
     │
     ▼
4-Page Executive Dashboard


### 1. Source Data

The source dataset contains **163,000+ line items** covering:

* Orders
* Products
* Customers
* Payments
* Returns

### 2. Python Automated Ingestion

`Python/data_ingestion.ipynb` handles automated ingestion using **SQLAlchemy**.

The ingestion process:

* Connects Python to MySQL
* Dynamically loads CSV datasets
* Performs batch insertion
* Handles structured data loading
* Removes **30 duplicate customer records** before database ingestion

### 3. Database Schema & Quality Control

`SQL/01_schema.sql`

Creates the ShopSphere database schema using:

* InnoDB tables
* Primary keys
* Foreign keys
* B-Tree indexes
* Relational constraints

`SQL/02_data_quality.sql`

Contains **14 automated SQL data-quality tests** covering issues such as:

* Orphan records
* Negative prices
* Invalid dates
* Missing relationships
* Duplicate records
* Date logic inconsistencies

### 4. Data Cleaning

`SQL/03_cleaning.sql`

Performs database-level data cleaning and normalization, including:

* Whitespace removal
* NULL handling using `COALESCE`
* Category-name normalization
* Data standardization
* Cleaning inconsistent source values

### 5. Business Analysis Layer

`SQL/04_business_analysis.sql`

Contains the core analytical logic, including:

* Business KPI calculations
* Year-over-Year growth analysis
* Customer spend rankings
* Customer decile analysis
* Revenue and profitability analysis
* CTE-based analytical queries

### 6. Analytical Modeling Layer

`SQL/05_analytical_views.sql`

Creates **8 production analytical views** that pre-aggregate business logic inside MySQL before the data reaches Power BI.

This reduces unnecessary transformation workloads inside Power BI and provides a cleaner reporting layer.

---

# Analytical Views

The project contains **8 dedicated analytical views**.

### `vw_sales_summary`

Provides executive-level sales KPIs:

* Completed orders
* Net sales
* COGS
* Gross profit
* Gross margin %
* Average Order Value (AOV)

### `vw_monthly_sales`

Tracks monthly sales performance across **2023–2025**, including:

* Monthly revenue
* Order volume
* Sales trajectory
* Order run-rate

### `vw_category_performance`

Evaluates performance across all **6 product categories**, including:

* Net revenue
* Units sold
* Gross profit
* Gross margin

### `vw_product_performance`

Provides SKU-level performance metrics:

* Net revenue
* Units sold
* Unit margin
* Return rate
* Product profitability

### `vw_customer_summary`

Provides customer-level behavioral metrics:

* Order count
* Lifetime spend
* Customer activity
* Revenue contribution

### `vw_customer_rfm`

Builds dynamic **RFM segmentation** using:

* **Recency (R)**
* **Frequency (F)**
* **Monetary Value (M)**

Each customer receives an RFM score from **1–5**, which is then used to assign behavioral segments.

### `vw_rfm_segment_summary`

Aggregates customer-level RFM results into segment-level business insights:

* Customer count
* Revenue contribution
* Average customer value
* Segment performance

### `vw_return_summary`

Analyzes reverse logistics by aggregating:

* Return volume
* Return reasons
* Operational issues
* Product/catalog issues
* Customer-driven returns

---

# Power BI Dashboard

The Power BI reporting layer consists of **4 interconnected executive pages**.

## Page 1 — Business Performance

### Executive Macro Health

Provides a high-level view of overall business performance.

Key metrics:

* **₹2.07B Net Sales**
* **₹329.94M Gross Profit**
* **15.94% Gross Margin**
* **₹22,028.42 AOV**
* **93,987 Completed Orders**

This page is designed for executive-level monitoring of overall commercial health.

---

## Page 2 — Category & Profitability

### Margin Trade-Offs

This page evaluates revenue and profitability across the product catalogue.

A key finding is that **Electronics** is the primary revenue engine, generating approximately:

**₹37.36 Cr in net revenue**

However, Electronics also produces the **lowest realized margin** across the catalogue at:

**14.76%**

This highlights an important revenue-versus-profitability trade-off: the category generating significant sales volume is not necessarily the category generating the strongest margins.

---

## Page 3 — Customer Value & RFM Segmentation

### Customer Revenue Concentration

RFM analysis reveals significant revenue concentration among high-value customers.

**87.57% of customers**, consisting primarily of:

* **Loyal Customers — 61.57%**
* **Champions — 26.00%**

collectively contribute:

**95.11% of total enterprise sales**

This represents approximately:

**₹196.90 Cr in revenue**

The analysis highlights the importance of customer retention and high-value customer lifecycle management.

---

## Page 4 — Returns & Customer Experience

### Reverse Logistics

The returns analysis identifies the operational drivers behind product returns.

A major finding is that:

**86.03% of returned units (8,583 units)**

are associated with **controllable operational and catalogue-related issues**, rather than simple buyer remorse.

This creates an opportunity to reduce reverse-logistics costs by addressing:

* Product quality issues
* Catalogue inaccuracies
* Fulfillment problems
* Operational inefficiencies
* Product expectation mismatches

---

# Technology Stack

| Layer                 | Technology         |
| --------------------- | ------------------ |
| Data Source           | CSV                |
| Data Ingestion        | Python             |
| Data Processing       | Pandas             |
| Database Connectivity | SQLAlchemy         |
| Database              | MySQL 8.0          |
| Data Modeling         | SQL Views / CTEs   |
| Business Analysis     | MySQL SQL          |
| Visualization         | Microsoft Power BI |
| Documentation         | Markdown           |

---

# Repository Structure

```text

ShopSphere/
│
├── Data/
│   └── Raw CSV extracts
│
├── Python/
│   └── data_ingestion.ipynb
│
├── SQL/
│   ├── 01_schema.sql
│   ├── 02_data_quality.sql
│   ├── 03_cleaning.sql
│   ├── 04_business_analysis.sql
│   └── 05_analytical_views.sql
│
├── PowerBI/
│   ├── ShopSphere_Dashboard.pbix
│   ├── ShopSphere_Dashboard.pdf
│   
│
├── docs/
│   └── Shopsphere_Project_Documentation.txt
|   └── README.txt
│
└── Screenshots

```

---

# How to Set Up & Replicate

Follow the steps below to reproduce the project from raw data to the final Power BI dashboard.

## Step 1 — Initialize the Database

Run:


SQL/01_schema.sql


This creates the ShopSphere database, tables, relationships, and indexes.

---

## Step 2 — Load the Raw Data

Open:


Python/data_ingestion.ipynb


Configure the MySQL connection and execute the notebook.

The Python pipeline will:

1. Read the raw CSV files.
2. Establish a connection to MySQL using SQLAlchemy.
3. Perform data preparation.
4. Remove duplicate customer records.
5. Batch-insert the datasets into MySQL.

---

## Step 3 — Run Data Quality Checks

Execute:


SQL/02_data_quality.sql


This validates the loaded data and checks for structural and logical inconsistencies.

---

## Step 4 — Clean the Data

Execute:


SQL/03_cleaning.sql


This performs the required data cleaning and normalization operations.

---

## Step 5 — Run Business Analysis

Execute:


SQL/04_business_analysis.sql


This generates the core business analysis, KPIs, growth calculations, and customer rankings.

---

## Step 6 — Create Analytical Views

Execute:


SQL/05_analytical_views.sql


This creates the **8 production analytical views** used by Power BI.

---

## Step 7 — Connect Power BI

Open:


PowerBI/ShopSphere_Dashboard.pbix


Update the MySQL data-source credentials if required.

Then refresh the Power BI model.

The dashboard will populate from the analytical SQL views.

---

# Business Questions Answered

The ShopSphere Analytics Engine is designed to answer key business questions such as:

### Sales Performance

* How much revenue is the business generating?
* How are sales trending month-over-month?
* What is the current order run-rate?
* What is the average order value?

### Profitability

* Which categories generate the most revenue?
* Which categories generate the strongest margins?
* Which products have weak profitability?
* Where are the major revenue-versus-margin trade-offs?

### Customer Analytics

* Who are the highest-value customers?
* Which customer segments contribute the most revenue?
* How concentrated is revenue among high-value customers?
* Which customers should be prioritized for retention initiatives?

### Returns & Reverse Logistics

* What is the overall return rate?
* Which products generate the most returns?
* What are the major return reasons?
* How many returns are driven by controllable operational issues?

---

# Key Business Insights

## 1. Strong Revenue Base

ShopSphere generated approximately **₹2.07 Billion in net sales** from **93,987 completed orders**, demonstrating a substantial transaction base.

## 2. Moderate Profitability

Despite the strong revenue base, the realized gross margin stands at **15.94%**, indicating that margin optimization remains an important business opportunity.

## 3. Electronics Drives Revenue but Underperforms on Margin

Electronics generates approximately **₹37.36 Cr in revenue**, making it a major revenue contributor.

However, its **14.76% realized margin** is the lowest among the six categories.

This suggests the need to investigate:

* Product-level pricing
* Supplier costs
* Discounting
* Product mix
* Return-related costs

## 4. Revenue Is Highly Concentrated Among High-Value Customers

The analysis shows that **87.57% of customers contribute 95.11% of total enterprise revenue**.

This creates a strong strategic case for:

* Customer retention
* Loyalty programs
* Personalized offers
* High-value customer segmentation
* Churn prevention

## 5. Returns Present a Significant Operational Opportunity

With a **5.14% return rate**, reverse logistics represents a meaningful cost and customer-experience consideration.

More importantly, **86.03% of returned units** are associated with controllable operational and catalogue-related issues.

Reducing these returns could improve:

* Gross profitability
* Customer satisfaction
* Inventory efficiency
* Reverse-logistics costs
* Operational performance

---

# Project Outcomes

This project demonstrates an end-to-end analytics workflow covering:

* Raw data ingestion
* Database design
* Data quality engineering
* Data cleaning
* SQL analytics
* Customer segmentation
* RFM modeling
* Revenue analysis
* Profitability analysis
* Return analytics
* Analytical data modeling
* Power BI dashboard development
* Business storytelling
* Strategic recommendations

The architecture separates **data engineering, analytical modeling, and visualization**, creating a scalable workflow where business logic is primarily handled within MySQL and Power BI focuses on interactive reporting and decision support.

---

# Skills Demonstrated

### SQL

* MySQL 8.0
* CTEs
* Window Functions
* Aggregations
* Conditional Aggregation
* Joins
* Subqueries
* Date Functions
* String Functions
* NULL Handling
* RFM Scoring
* Analytical Views
* Data Quality Testing

### Python

* Pandas
* SQLAlchemy
* Automated ingestion
* Batch database loading
* Data cleaning
* Deduplication

### Power BI

* Dashboard development
* KPI design
* Data visualization
* Executive reporting
* Customer segmentation
* Profitability analysis
* Interactive business analysis

### Business Intelligence

* Revenue optimization
* Margin analysis
* Customer lifetime value
* RFM segmentation
* Reverse logistics
* Operational performance analysis
* Executive decision support

---

# Final Architecture

                    SHOPSPHERE ANALYTICS ENGINE
                              │
                              ▼
                    ┌───────────────────┐
                    │   Raw CSV Data    │
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │ Python / Pandas   │
                    │ SQLAlchemy ETL    │
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │    MySQL 8.0      │
                    │                   │
                    │ Schema            │
                    │ Data Quality      │
                    │ Cleaning          │
                    │ Business Analysis │
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │ Analytical Views  │
                    │       (8)         │
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │    Power BI       │
                    │                   │
                    │ 1. Performance    │
                    │ 2. Profitability  │
                    │ 3. Customers/RFM  │
                    │ 4. Returns        │
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │ Executive         │
                    │ Decision Support  │
                    └───────────────────┘

---

## Conclusion

**ShopSphere E-Commerce Analytics Engine** transforms raw transactional data into a structured business intelligence system.

By moving data quality, transformation, business logic, and analytical modeling into MySQL and using Power BI primarily as the visualization and reporting layer, the project demonstrates a practical **end-to-end BI architecture** suitable for scalable analytics workflows.

The resulting system provides visibility into:

**Revenue → Profitability → Customer Value → Operational Efficiency**

and translates transactional data into actionable insights for **revenue optimization, customer retention, margin improvement, and reverse-logistics reduction**.
