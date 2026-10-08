-- =========================================================
-- ShopSphere
-- 04_business_analysis.sql
-- Exploratory Analysis, KPIs & CTEs
-- =========================================================

USE shopsphere;

-- 1. Core Financial Metrics
SELECT
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_sales,
    ROUND(SUM(oi.quantity * p.cost_price), 2) AS total_cogs,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) - SUM(oi.quantity * p.cost_price), 2) AS gross_profit,
    ROUND(100 * (SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) - SUM(oi.quantity * p.cost_price)) / SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS gross_profit_margin_pct,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM clean_orders o
JOIN clean_order_items oi ON o.order_id = oi.order_id
JOIN clean_products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';

-- 2. Category Performance & Margin Health
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_sales,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) - SUM(oi.quantity * p.cost_price), 2) AS gross_profit,
    ROUND(100 * (SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) - SUM(oi.quantity * p.cost_price)) / SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS gross_margin_pct
FROM clean_order_items oi
JOIN clean_orders o ON oi.order_id = o.order_id
JOIN clean_products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY gross_profit DESC;

-- 3. Modern Year-over-Year (YoY) Growth using LAG()
WITH annual_summary AS (
    SELECT
        YEAR(o.order_date) AS sales_year,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_sales
    FROM clean_orders o
    JOIN clean_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY YEAR(o.order_date)
)
SELECT
    sales_year,
    completed_orders,
    net_sales,
    LAG(net_sales) OVER (ORDER BY sales_year) AS prior_year_sales,
    ROUND(100 * (net_sales - LAG(net_sales) OVER (ORDER BY sales_year)) / LAG(net_sales) OVER (ORDER BY sales_year), 2) AS sales_growth_pct,
    ROUND(100 * (completed_orders - LAG(completed_orders) OVER (ORDER BY sales_year)) / LAG(completed_orders) OVER (ORDER BY sales_year), 2) AS order_growth_pct
FROM annual_summary
ORDER BY sales_year;

-- 4. Robust Return Rate by Category 
WITH category_sales AS (
    SELECT p.category, SUM(oi.quantity) AS purchased_qty
    FROM clean_order_items oi
    JOIN clean_orders o ON oi.order_id = o.order_id
    JOIN clean_products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category
),
category_returns AS (
    SELECT p.category, SUM(r.return_quantity) AS returned_qty
    FROM clean_returns r
    JOIN clean_orders o ON r.order_id = o.order_id
    JOIN clean_products p ON r.product_id = p.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category
)
SELECT
    s.category,
    s.purchased_qty,
    COALESCE(r.returned_qty, 0) AS returned_qty,
    ROUND(100.0 * COALESCE(r.returned_qty, 0) / s.purchased_qty, 2) AS return_rate_pct
FROM category_sales s
LEFT JOIN category_returns r ON s.category = r.category
ORDER BY return_rate_pct DESC;

-- 5. Customer Revenue Concentration (Pareto Distribution)
WITH customer_spend AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_spend
    FROM clean_orders o JOIN clean_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed' GROUP BY o.customer_id
),
ranked_customers AS (
    SELECT customer_id, total_spend, NTILE(10) OVER (ORDER BY total_spend DESC) AS spend_decile
    FROM customer_spend
)
SELECT
    spend_decile,
    COUNT(customer_id) AS customer_count,
    ROUND(SUM(total_spend), 2) AS decile_revenue,
    ROUND(100.0 * SUM(total_spend) / (SELECT SUM(total_spend) FROM customer_spend), 2) AS revenue_pct
FROM ranked_customers
GROUP BY spend_decile
ORDER BY spend_decile;