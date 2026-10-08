# 🛒 ShopSphere E-Commerce Analytics Engine

### End-to-End Business Intelligence & Revenue Optimization

An end-to-end **e-commerce analytics and business intelligence project** analyzing **93,987 completed transactions** and approximately **₹2.07B in net revenue**.

The project transforms raw transactional data into a production-style analytical workflow covering **automated data ingestion, data quality engineering, SQL-based transformation, business analysis, customer RFM segmentation, profitability analysis, reverse logistics, and an interactive Power BI executive dashboard**.

Rather than performing heavy transformation logic inside Power BI, the project moves core data preparation and business logic into **MySQL 8.0**, creating a structured analytical layer that feeds the reporting model.

---

# 📊 Executive Summary

ShopSphere analyzes the business across four major dimensions:

* 💰 **Sales Performance** — Revenue, orders, AOV, and sales trends
* 📈 **Category & Profitability** — Revenue, gross profit, and margin performance
* 👥 **Customer Value** — Customer behavior, RFM segmentation, and revenue concentration
* 🔄 **Returns & Reverse Logistics** — Return volumes, causes, and controllable operational issues

The final solution consists of a **MySQL analytical backend** and a **4-page Power BI executive dashboard** designed for decision support.

---

# 🚀 Key Business Metrics

| KPI                   |         Result |
| --------------------- | -------------: |
| Completed Orders      |     **93,987** |
| Net Sales             |     **₹2.07B** |
| Gross Profit          |   **₹329.94M** |
| Realized Gross Margin |     **15.94%** |
| Average Order Value   | **₹22,028.42** |
| Active Customers      |     **15,000** |
| Units Returned        |      **9,977** |
| Return Rate           |      **5.14%** |

These metrics establish the overall commercial scale, profitability, customer base, and reverse-logistics footprint of the business.

---

# 🔎 Key Business Insights

## 1. Strong Revenue Base

ShopSphere generated approximately:

### **₹2.07 Billion in Net Sales**

from:

### **93,987 Completed Orders**

This establishes a substantial transactional base for analyzing revenue performance, customer behavior, product economics, and operational efficiency.

---

## 2. Revenue Does Not Equal Profitability

Despite the large revenue base, realized gross margin is:

### **15.94%**

This indicates that **margin optimization remains an important business opportunity**.

The analysis therefore goes beyond revenue reporting to identify categories and products where high sales do not necessarily translate into strong profitability.

---

## 3. Electronics Is a Major Revenue Engine — But Has the Lowest Margin

Electronics generates approximately:

### **₹37.36 Cr in Net Revenue**

However, it records the lowest realized margin across the six categories:

### **14.76%**

This creates a clear **revenue-versus-profitability trade-off**.

Potential areas for investigation include:

* Product-level pricing
* Supplier costs
* Discounting
* Product mix
* Return-related costs

---

## 4. Customer Revenue Is Highly Concentrated

RFM analysis identifies substantial revenue concentration among high-value customers.

**87.57% of customers** — primarily:

* Loyal Customers — **61.57%**
* Champions — **26.00%**

collectively contribute:

### **95.11% of Total Enterprise Sales**

representing approximately:

### **₹196.90 Cr in Revenue**

This highlights the strategic importance of:

* Customer retention
* Loyalty programs
* Personalized offers
* High-value customer segmentation
* Churn prevention

---

## 5. Returns Create a Significant Operational Opportunity

The overall return rate is:

### **5.14%**

with:

### **9,977 Returned Units**

More importantly, **86.03% of returned units**, representing **8,583 units**, are associated with controllable operational and catalogue-related issues.

These include areas such as:

* Product quality
* Catalogue inaccuracies
* Fulfillment problems
* Operational inefficiencies
* Product expectation mismatches

## Reducing these returns could improve profitability, customer satisfaction, inventory efficiency, and reverse-logistics costs.

# 🏗️ System Architecture

The project follows a layered analytics architecture:

```text
                    ┌──────────────────────┐
                    │     Raw CSV Data     │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Python / Pandas      │
                    │ Automated Ingestion  │
                    │ + SQLAlchemy         │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      MySQL 8.0       │
                    │                      │
                    │ Schema               │
                    │ Data Quality         │
                    │ Cleaning             │
                    │ Business Analysis    │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  Analytical Views    │
                    │         (8)          │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      Power BI        │
                    │                      │
                    │ 1. Performance       │
                    │ 2. Profitability     │
                    │ 3. Customers / RFM   │
                    │ 4. Returns           │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Executive Decision   │
                    │ Support              │
                    └──────────────────────┘
```

The architecture separates **data ingestion, data quality, transformation, analytical modeling, and visualization**, reducing the dependency on heavy transformation logic inside Power BI.

---

# 🔄 End-to-End Data Pipeline

## 1. Source Data

The source dataset contains **163,000+ line items** covering:

* Orders
* Products
* Customers
* Payments
* Returns

---

## 2. Automated Data Ingestion

`Python/data_ingestion.ipynb` handles automated database ingestion using **SQLAlchemy**.

The pipeline:

1. Connects Python to MySQL
2. Dynamically loads CSV datasets
3. Performs structured data preparation
4. Removes **30 duplicate customer records**
5. Performs batch insertion into MySQL

---

## 3. Database Schema & Data Quality

### `SQL/01_schema.sql`

Creates the ShopSphere database architecture using:

* InnoDB tables
* Primary keys
* Foreign keys
* B-tree indexes
* Relational constraints

### `SQL/02_data_quality.sql`

Contains **14 automated SQL data-quality tests** covering:

* Orphan records
* Negative prices
* Invalid dates
* Missing relationships
* Duplicate records
* Date inconsistencies

---

## 4. Data Cleaning & Normalization

### `SQL/03_cleaning.sql`

Performs database-level cleaning and standardization, including:

* Whitespace removal
* `COALESCE`-based NULL handling
* Category normalization
* Data standardization
* Inconsistent source-value cleanup

---

## 5. Business Analysis Layer

### `SQL/04_business_analysis.sql`

Contains core business analytics including:

* KPI calculations
* Year-over-Year growth
* Customer spend rankings
* Customer decile analysis
* Revenue analysis
* Profitability analysis
* CTE-based analytical queries

---

## 6. Analytical Modeling Layer

### `SQL/05_analytical_views.sql`

Creates **8 production analytical SQL views**.

These views pre-aggregate business logic inside MySQL before the data reaches Power BI, providing a cleaner and more structured reporting layer.

---

# 🧠 Analytical SQL Views

The project contains **8 dedicated analytical views**.

| View                      | Purpose                         |
| ------------------------- | ------------------------------- |
| `vw_sales_summary`        | Executive sales KPIs            |
| `vw_monthly_sales`        | Monthly sales trends            |
| `vw_category_performance` | Category revenue & margin       |
| `vw_product_performance`  | SKU-level profitability         |
| `vw_customer_summary`     | Customer behavior & value       |
| `vw_customer_rfm`         | RFM scoring & segmentation      |
| `vw_rfm_segment_summary`  | Segment-level customer insights |
| `vw_return_summary`       | Returns & reverse logistics     |

### `vw_sales_summary`

Provides:

* Completed orders
* Net sales
* COGS
* Gross profit
* Gross margin
* AOV

### `vw_monthly_sales`

Tracks sales performance across **2023–2025**, including:

* Monthly revenue
* Order volume
* Sales trajectory
* Order run-rate

### `vw_category_performance`

Evaluates all **6 product categories** across:

* Net revenue
* Units sold
* Gross profit
* Gross margin

### `vw_product_performance`

Provides SKU-level:

* Net revenue
* Units sold
* Unit margin
* Return rate
* Product profitability

### `vw_customer_summary`

Provides:

* Order count
* Lifetime spend
* Customer activity
* Revenue contribution

### `vw_customer_rfm`

Builds RFM segmentation using:

* **Recency**
* **Frequency**
* **Monetary Value**

Each customer receives an RFM score from **1–5**.

### `vw_rfm_segment_summary`

Aggregates customer RFM results into:

* Customer count
* Revenue contribution
* Average customer value
* Segment performance

### `vw_return_summary`

Analyzes reverse logistics through:

* Return volume
* Return reasons
* Operational issues
* Product/catalogue issues
* Customer-driven returns

---

# 📊 Power BI Executive Dashboard

The reporting layer contains **4 interconnected Power BI pages**.

---

## 01 — Business Performance

### Executive Macro Health

Provides a high-level view of commercial performance.

**Primary KPIs:**

* **₹2.07B** Net Sales
* **₹329.94M** Gross Profit
* **15.94%** Gross Margin
* **₹22,028.42** AOV
* **93,987** Completed Orders

Designed for rapid executive monitoring of overall business health.

---

## 02 — Category & Profitability

### Margin Trade-Offs

Evaluates revenue and profitability across the product catalogue.

The dashboard highlights the contrast between:

**High revenue contribution**

and

**Lower realized margin**

with Electronics generating approximately **₹37.36 Cr** while recording a **14.76% realized margin**.

---

## 03 — Customer Value & RFM

### Customer Revenue Concentration

Uses RFM segmentation to identify high-value customer groups and revenue concentration.

The analysis shows that:

> **87.57% of customers contribute 95.11% of total enterprise sales.**

This makes customer retention and lifecycle management critical strategic priorities.

---

## 04 — Returns & Customer Experience

### Reverse Logistics

Analyzes return volumes and the causes behind returned products.

The dashboard highlights that:

> **86.03% of returned units are associated with controllable operational and catalogue-related issues.**

This creates an opportunity to reduce reverse-logistics costs by targeting operational and catalogue quality.

---

# 🛠️ Technology Stack

| Layer                 | Technology             |
| --------------------- | ---------------------- |
| Data Source           | **CSV**                |
| Data Ingestion        | **Python**             |
| Data Processing       | **Pandas**             |
| Database Connectivity | **SQLAlchemy**         |
| Database              | **MySQL 8.0**          |
| Data Modeling         | **SQL Views / CTEs**   |
| Business Analysis     | **MySQL SQL**          |
| Visualization         | **Microsoft Power BI** |
| Documentation         | **Markdown**           |

---

# 📁 Repository Structure

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
│   └── ShopSphere_Dashboard.pdf
│
├── docs/
│   ├── Shopsphere_Project_Documentation.txt
│   └── README.txt
│
├── Screenshots/
│
└── README.md
```

---

# ⚙️ How to Reproduce the Project

## Step 1 — Initialize MySQL

Run:

```sql
SQL/01_schema.sql
```

This creates the ShopSphere database, tables, relationships, and indexes.

---

## Step 2 — Load Raw Data

Open:

```text
Python/data_ingestion.ipynb
```

Configure the MySQL connection and execute the notebook.

The pipeline will:

1. Read the raw CSV files
2. Connect to MySQL through SQLAlchemy
3. Prepare the data
4. Remove duplicate customer records
5. Batch-insert datasets into MySQL

---

## Step 3 — Run Data Quality Checks

Execute:

```sql
SQL/02_data_quality.sql
```

This validates structural and logical consistency in the loaded data.

---

## Step 4 — Clean & Normalize Data

Execute:

```sql
SQL/03_cleaning.sql
```

This performs the required database-level cleaning and normalization.

---

## Step 5 — Run Business Analysis

Execute:

```sql
SQL/04_business_analysis.sql
```

This generates the core business KPIs, growth calculations, customer rankings, and analytical outputs.

---

## Step 6 — Build Analytical Views

Execute:

```sql
SQL/05_analytical_views.sql
```

This creates the **8 analytical reporting views** consumed by Power BI.

---

## Step 7 — Open Power BI

Open:

```text
PowerBI/ShopSphere_Dashboard.pbix
```

Update the MySQL connection credentials if required and refresh the model.

The dashboard will populate from the analytical SQL layer.

---

# 🎯 Business Questions Answered

## Sales Performance

* How much revenue is the business generating?
* How are sales trending over time?
* What is the current order run-rate?
* What is the average order value?

## Profitability

* Which categories generate the most revenue?
* Which categories generate the strongest margins?
* Which products have weak profitability?
* Where are the major revenue-versus-margin trade-offs?

## Customer Analytics

* Who are the highest-value customers?
* Which segments contribute the most revenue?
* How concentrated is enterprise revenue?
* Which customers should receive retention focus?

## Returns & Reverse Logistics

* What is the overall return rate?
* Which products generate the most returns?
* What are the major return reasons?
* How many returns are associated with controllable operational issues?

---

# 💡 Strategic Recommendations

Based on the analytical findings, the project identifies several areas for potential business action.

### 1. Improve Margin Performance

The **15.94% realized gross margin** indicates an opportunity to investigate:

* Supplier costs
* Pricing
* Discounting
* Product mix
* Return-related costs

### 2. Investigate Electronics Margin Pressure

Electronics combines strong revenue contribution with the lowest realized margin.

Management should investigate the underlying product-level economics rather than optimizing the category solely for revenue growth.

### 3. Protect High-Value Customers

With **95.11% of revenue concentrated among 87.57% of customers**, retention and lifecycle management should be important components of customer strategy.

Potential initiatives include:

* Loyalty programs
* Personalized offers
* Retention campaigns
* Churn prevention
* High-value customer experiences

### 4. Reduce Controllable Returns

Since **86.03% of returned units** are associated with controllable operational and catalogue-related issues, reducing these returns could improve:

* Gross profitability
* Customer satisfaction
* Inventory efficiency
* Reverse-logistics costs
* Operational performance

---

# 🧩 Skills Demonstrated

## SQL & Data Engineering

* MySQL 8.0
* Relational database design
* Primary & foreign keys
* B-tree indexing
* CTEs
* Window functions
* Aggregations
* Conditional aggregation
* Joins
* Subqueries
* Date functions
* String functions
* NULL handling
* Analytical views
* Data-quality testing

## Python

* Pandas
* SQLAlchemy
* Automated ingestion
* Batch database loading
* Data preparation
* Data cleaning
* Deduplication

## Power BI

* Executive dashboard development
* KPI design
* Business visualization
* Customer segmentation
* Profitability analysis
* Revenue analysis
* Executive reporting

## Business Intelligence

* Revenue optimization
* Margin analysis
* Customer lifetime value
* RFM segmentation
* Reverse-logistics analysis
* Operational performance
* Executive decision support

---

# 📌 Project Outcomes

This project demonstrates a complete analytics workflow:

```text
Raw Data
   ↓
Automated Ingestion
   ↓
Data Quality Engineering
   ↓
Data Cleaning
   ↓
SQL Business Analysis
   ↓
Customer & Product Analytics
   ↓
Analytical SQL Views
   ↓
Power BI Semantic Layer
   ↓
Executive Dashboard
   ↓
Business Recommendations
```

The architecture deliberately separates **data engineering, analytical modeling, and visualization**, allowing MySQL to handle core business logic while Power BI focuses on interactive analysis and decision support.

---

# 🏁 Conclusion

**ShopSphere E-Commerce Analytics Engine** transforms raw transactional data into a structured business intelligence platform connecting:

### **Revenue → Profitability → Customer Value → Operational Efficiency**

The project provides a unified analytical view of:

* Sales performance
* Margin health
* Customer value
* RFM segments
* Product profitability
* Returns
* Reverse logistics
* Strategic revenue opportunities

By moving data quality, transformation, business logic, and analytical modeling into **MySQL**, while using **Power BI as the interactive reporting layer**, the project demonstrates a practical end-to-end BI architecture designed for scalable analytical workflows.

---

## 👤 Author

**Arnav Singh Chauhan**

**Data Analyst | SQL | Python | Power BI | Business Intelligence**

---

⭐ **If you found this project useful, consider giving the repository a star.**
