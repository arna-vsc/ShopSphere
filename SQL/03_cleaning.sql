-- =========================================================
-- ShopSphere
-- 03_cleaning.sql
-- Cleaned Staging Layer with Preserved Indexes & Views
-- =========================================================

USE shopsphere;

-- 1. Clean Order Items (Null discount handling & indexing)
DROP VIEW IF EXISTS clean_order_items;
DROP TABLE IF EXISTS clean_order_items;

CREATE TABLE clean_order_items (
    order_item_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (order_item_id),
    INDEX idx_coi_order (order_id),
    INDEX idx_coi_product (product_id)
) ENGINE=InnoDB;

INSERT INTO clean_order_items (order_item_id, order_id, product_id, quantity, unit_price, discount)
SELECT 
    order_item_id, 
    order_id, 
    product_id, 
    quantity, 
    unit_price, 
    COALESCE(discount, 0.00) AS discount
FROM order_items;

-- 2. Clean Customers (Trim whitespace & handle null locations)
DROP VIEW IF EXISTS clean_customers;
DROP TABLE IF EXISTS clean_customers;

CREATE TABLE clean_customers (
    customer_id BIGINT NOT NULL,
    customer_name VARCHAR(150),
    gender VARCHAR(20),
    age INT,
    city VARCHAR(100),
    state VARCHAR(100),
    signup_date DATE,
    PRIMARY KEY (customer_id),
    INDEX idx_cc_city (city),
    INDEX idx_cc_state (state)
) ENGINE=InnoDB;

INSERT INTO clean_customers (customer_id, customer_name, gender, age, city, state, signup_date)
SELECT 
    customer_id, 
    TRIM(customer_name) AS customer_name, 
    TRIM(gender) AS gender, 
    age, 
    COALESCE(NULLIF(TRIM(city), ''), 'Unknown') AS city, 
    COALESCE(NULLIF(TRIM(state), ''), 'Unknown') AS state, 
    signup_date
FROM customers;

-- 3. Clean Passthrough Views
-- (Explicitly dropping the old physical tables so MySQL allows view creation)

DROP TABLE IF EXISTS clean_orders;
CREATE OR REPLACE VIEW clean_orders AS
SELECT 
    order_id, 
    customer_id, 
    order_date, 
    TRIM(order_status) AS order_status, 
    TRIM(payment_method) AS payment_method
FROM orders;

DROP TABLE IF EXISTS clean_products;
CREATE OR REPLACE VIEW clean_products AS
SELECT 
    product_id, 
    TRIM(product_name) AS product_name, 
    -- Normalizing typographical errors in the raw CSV to prevent Power BI chart splits
    CASE 
        WHEN TRIM(category) = 'Home and Kitchen' THEN 'Home & Kitchen'
        WHEN TRIM(category) = 'electronics' THEN 'Electronics'
        ELSE TRIM(category) 
    END AS category,
    TRIM(subcategory) AS subcategory, 
    cost_price, 
    selling_price
FROM products;

DROP TABLE IF EXISTS clean_payments;
CREATE OR REPLACE VIEW clean_payments AS
SELECT 
    payment_id, 
    order_id, 
    payment_date, 
    payment_amount, 
    TRIM(payment_status) AS payment_status
FROM payments;

DROP TABLE IF EXISTS clean_returns;
CREATE OR REPLACE VIEW clean_returns AS
SELECT 
    return_id, 
    order_id, 
    product_id, 
    return_date, 
    TRIM(return_reason) AS return_reason, 
    return_quantity
FROM returns;