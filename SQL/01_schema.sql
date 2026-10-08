-- =========================================================
-- ShopSphere
-- 01_schema.sql 
-- Database schema definition with unified types and indexes
-- =========================================================

CREATE DATABASE IF NOT EXISTS shopsphere;
USE shopsphere;

-- 1. Products Dimension
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    cost_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (product_id)
) ENGINE=InnoDB;

-- 2. Customers Dimension
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id BIGINT NOT NULL,
    customer_name VARCHAR(150),
    gender VARCHAR(20),
    age INT,
    city VARCHAR(100),
    state VARCHAR(100),
    signup_date DATE,
    PRIMARY KEY (customer_id)
) ENGINE=InnoDB;

-- 3. Orders Header Table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    payment_method VARCHAR(50),
    PRIMARY KEY (order_id),
    INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_date (order_date),
    INDEX idx_orders_status (order_status)
) ENGINE=InnoDB;

-- 4. Order Items (Fact Line Items)
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_item_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0.00,
    PRIMARY KEY (order_item_id),
    INDEX idx_oi_order (order_id),
    INDEX idx_oi_product (product_id)
) ENGINE=InnoDB;

-- 5. Payments
DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
    payment_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    payment_date DATE,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    PRIMARY KEY (payment_id),
    INDEX idx_payments_order (order_id),
    INDEX idx_payments_status (payment_status)
) ENGINE=InnoDB;

-- 6. Returns
DROP TABLE IF EXISTS returns;
CREATE TABLE returns (
    return_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    return_date DATE,
    return_reason VARCHAR(255),
    return_quantity INT NOT NULL,
    PRIMARY KEY (return_id),
    INDEX idx_returns_order (order_id),
    INDEX idx_returns_product (product_id)
) ENGINE=InnoDB;