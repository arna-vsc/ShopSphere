-- =========================================================
-- ShopSphere
-- 02_data_quality.sql
-- Automated Data Quality & Anomaly Detection Framework
-- =========================================================

USE shopsphere;

-- Section A: Primary Key Uniqueness & Row Completeness
SELECT 'Duplicate Products' AS check_name, COUNT(*) AS anomaly_count, CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM (SELECT product_id FROM products GROUP BY product_id HAVING COUNT(*) > 1) t
UNION ALL
SELECT 'Duplicate Customers', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (SELECT customer_id FROM customers GROUP BY customer_id HAVING COUNT(*) > 1) t
UNION ALL
SELECT 'Duplicate Orders', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (SELECT order_id FROM orders GROUP BY order_id HAVING COUNT(*) > 1) t
UNION ALL
SELECT 'Duplicate Order Items', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (SELECT order_item_id FROM order_items GROUP BY order_item_id HAVING COUNT(*) > 1) t
UNION ALL
SELECT 'Duplicate Payments', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (SELECT payment_id FROM payments GROUP BY payment_id HAVING COUNT(*) > 1) t
UNION ALL
SELECT 'Duplicate Returns', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (SELECT return_id FROM returns GROUP BY return_id HAVING COUNT(*) > 1) t;

-- Section B: Relational Integrity (Orphan Foreign Keys)
SELECT 'Orphan Orders (No Customer)' AS check_name, COUNT(*) AS anomaly_count, CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id WHERE c.customer_id IS NULL
UNION ALL
SELECT 'Orphan Items (No Order)', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id WHERE o.order_id IS NULL
UNION ALL
SELECT 'Orphan Items (No Product)', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id WHERE p.product_id IS NULL
UNION ALL
SELECT 'Orphan Payments (No Order)', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM payments p LEFT JOIN orders o ON p.order_id = o.order_id WHERE o.order_id IS NULL
UNION ALL
SELECT 'Orphan Returns (No Order)', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM returns r LEFT JOIN orders o ON r.order_id = o.order_id WHERE o.order_id IS NULL
UNION ALL
SELECT 'Orphan Returns (No Product)', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM returns r LEFT JOIN products p ON r.product_id = p.product_id WHERE p.product_id IS NULL;

-- Section C: Business Logic, Pricing & Temporal Rules
SELECT 'Negative / Zero Quantity' AS check_name, COUNT(*) AS anomaly_count, CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM order_items WHERE quantity <= 0
UNION ALL
SELECT 'Negative / Zero Return Quantity', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM returns WHERE return_quantity <= 0
UNION ALL
SELECT 'Negative / Zero Unit Price', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM order_items WHERE unit_price <= 0
UNION ALL
SELECT 'Negative Selling / Cost Price', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM products WHERE cost_price <= 0 OR selling_price <= 0
UNION ALL
SELECT 'Selling Price Below Cost Price', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'ALERT: Review Loss-Leaders' END
FROM products WHERE selling_price < cost_price
UNION ALL
SELECT 'Negative Discounts', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM order_items WHERE discount < 0
UNION ALL
SELECT 'Missing / Null Discounts', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'ALERT: Requires Coalesce' END
FROM order_items WHERE discount IS NULL
UNION ALL
SELECT 'Payment Date Precedes Order Date', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM payments p JOIN orders o ON p.order_id = o.order_id WHERE p.payment_date < o.order_date
UNION ALL
SELECT 'Return Date Precedes Order Date', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM returns r JOIN orders o ON r.order_id = o.order_id WHERE r.return_date < o.order_date
UNION ALL
SELECT 'Return Quantity Exceeds Order Quantity', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT r.order_id, r.product_id, SUM(r.return_quantity) AS returned_qty, SUM(oi.quantity) AS purchased_qty
    FROM returns r JOIN order_items oi ON r.order_id = oi.order_id AND r.product_id = oi.product_id
    GROUP BY r.order_id, r.product_id HAVING SUM(r.return_quantity) > SUM(oi.quantity)
) excess_returns
UNION ALL
SELECT 'Orders Placed Before Account Signup', COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'ALERT: Guest Checkout' END
FROM orders o JOIN customers c ON o.customer_id = c.customer_id WHERE o.order_date < c.signup_date;