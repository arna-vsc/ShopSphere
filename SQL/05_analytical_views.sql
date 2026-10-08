-- =========================================================
-- ShopSphere
-- 05_analytical_views.sql 
-- High-Performance Power BI Analytical Views
-- =========================================================

USE shopsphere;

-- 01. Sales Summary View 
CREATE OR REPLACE VIEW vw_sales_summary AS
SELECT
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_sales,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) - SUM(oi.quantity * p.cost_price), 2) AS gross_profit,
    ROUND(100 * (SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) - SUM(oi.quantity * p.cost_price)) / SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS gross_margin_pct,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM clean_orders o
JOIN clean_order_items oi ON o.order_id = oi.order_id
JOIN clean_products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';

-- 02. Monthly Sales View
CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT
    YEAR(o.order_date) AS sales_year,
    MONTH(o.order_date) AS sales_month,
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month_label,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_sales
FROM clean_orders o
JOIN clean_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY YEAR(o.order_date), MONTH(o.order_date), DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_year, sales_month;

-- 03. Category Performance View 
CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_sales,
    ROUND(SUM(oi.quantity * p.cost_price), 2) AS product_cost,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) - SUM(oi.quantity * p.cost_price), 2) AS gross_profit,
    ROUND(100 * (SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) - SUM(oi.quantity * p.cost_price)) / SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS gross_margin_pct
FROM clean_orders o
JOIN clean_order_items oi ON o.order_id = oi.order_id
JOIN clean_products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category;

-- 04. Customer Summary View
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_sales
FROM clean_orders o
JOIN clean_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.customer_id;

-- 05. Return Summary View 
CREATE OR REPLACE VIEW vw_return_summary AS
SELECT
    r.return_reason,
    SUM(r.return_quantity) AS returned_units
FROM clean_returns r
JOIN clean_orders o ON r.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY r.return_reason;

-- 06. Dynamic Customer RFM & Segmentation View
CREATE OR REPLACE VIEW vw_customer_rfm AS
WITH max_date_lookup AS (
    SELECT MAX(order_date) AS max_date FROM clean_orders WHERE order_status = 'Completed'
),
customer_metrics AS (
    SELECT
        c.customer_id, c.customer_name, c.city, c.state, c.signup_date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(COALESCE(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 0), 2) AS monetary_value,
        DATEDIFF((SELECT max_date FROM max_date_lookup), MAX(o.order_date)) AS recency_days
    FROM clean_customers c
    LEFT JOIN clean_orders o ON c.customer_id = o.customer_id AND o.order_status = 'Completed'
    LEFT JOIN clean_order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.city, c.state, c.signup_date
),
rfm_scores AS (
    SELECT
        m.*,
        CASE WHEN recency_days <= 30 THEN 5 WHEN recency_days <= 90 THEN 4 WHEN recency_days <= 180 THEN 3 WHEN recency_days <= 365 THEN 2 ELSE 1 END AS r_score,
        CASE WHEN total_orders >= 10 THEN 5 WHEN total_orders >= 7 THEN 4 WHEN total_orders >= 4 THEN 3 WHEN total_orders >= 2 THEN 2 ELSE 1 END AS f_score,
        CASE WHEN monetary_value >= 25000 THEN 5 WHEN monetary_value >= 15000 THEN 4 WHEN monetary_value >= 8000 THEN 3 WHEN monetary_value >= 3000 THEN 2 ELSE 1 END AS m_score
    FROM customer_metrics m
)
SELECT
    customer_id, customer_name, city, state, signup_date, total_orders, monetary_value, recency_days, r_score, f_score, m_score,
    ROUND((r_score + f_score + m_score) / 3.0, 2) AS avg_rfm,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Buyers / Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk / Need Attention'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Hibernating / Lost'
        ELSE 'Promising / Standard'
    END AS customer_segment
FROM rfm_scores;

-- 07. SKU Product Performance View 
CREATE OR REPLACE VIEW vw_product_performance AS
WITH product_sales AS (
    SELECT oi.product_id, COUNT(DISTINCT oi.order_id) AS total_orders, SUM(oi.quantity) AS total_units_sold, SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_net_revenue
    FROM clean_order_items oi JOIN clean_orders o ON oi.order_id = o.order_id WHERE o.order_status = 'Completed' GROUP BY oi.product_id
),
product_returns AS (
    SELECT r.product_id, SUM(r.return_quantity) AS total_units_returned
    FROM clean_returns r JOIN clean_orders o ON r.order_id = o.order_id WHERE o.order_status = 'Completed' GROUP BY r.product_id
)
SELECT
    p.product_id, p.product_name, p.category, p.subcategory, p.cost_price, p.selling_price,
    ROUND(p.selling_price - p.cost_price, 2) AS unit_margin,
    ROUND(((p.selling_price - p.cost_price) / NULLIF(p.selling_price, 0)) * 100, 2) AS margin_percentage,
    COALESCE(s.total_orders, 0) AS total_orders_containing_product,
    COALESCE(s.total_units_sold, 0) AS total_units_sold,
    ROUND(COALESCE(s.total_net_revenue, 0), 2) AS total_net_revenue,
    COALESCE(r.total_units_returned, 0) AS total_units_returned,
    ROUND(COALESCE(r.total_units_returned, 0) / NULLIF(s.total_units_sold, 0) * 100, 2) AS return_rate_pct
FROM clean_products p
LEFT JOIN product_sales s ON p.product_id = s.product_id
LEFT JOIN product_returns r ON p.product_id = r.product_id;

-- 08. RFM Segment Summary View
CREATE OR REPLACE VIEW vw_rfm_segment_summary AS
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM vw_customer_rfm), 2) AS pct_of_customer_base,
    ROUND(SUM(monetary_value), 2) AS total_revenue_contribution,
    ROUND(AVG(monetary_value), 2) AS avg_customer_value
FROM vw_customer_rfm
GROUP BY customer_segment;