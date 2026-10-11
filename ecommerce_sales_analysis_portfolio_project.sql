--------------------------------------------------------------------------------
-- E-COMMERCE SALES ANALYSIS PORTFOLIO PROJECT
-- Database: PostgreSQL / MySQL Compatible
-- Description: Complete SQL script containing schema creation, sample data seeding, 
--              15 core business analytical queries, and advanced window functions.
--------------------------------------------------------------------------------

-- =============================================================================
-- 1. DATABASE SCHEMA CREATION
-- =============================================================================

DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    signup_date DATE NOT NULL,
    country VARCHAR(50) NOT NULL
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT NOT NULL
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    payment_date TIMESTAMP NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
);

-- =============================================================================
-- 2. SAMPLE DATA INSERTION (Optional Mock Data for Testing)
-- =============================================================================

INSERT INTO customers (signup_date, country) VALUES
('2025-01-10', 'USA'),
('2025-01-15', 'Canada'),
('2025-02-01', 'UK'),
('2025-02-20', 'USA'),
('2025-03-05', 'Germany');

INSERT INTO products (category, price) VALUES
('Electronics', 799.99),
('Electronics', 49.99),
('Apparel', 29.99),
('Apparel', 89.99),
('Home & Garden', 120.00),
('Home & Garden', 15.00);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2025-01-12 10:30:00', 'Completed'),
(1, '2025-02-14 14:20:00', 'Completed'),
(2, '2025-01-18 09:15:00', 'Cancelled'),
(3, '2025-02-05 16:45:00', 'Completed'),
(4, '2025-02-22 11:10:00', 'Completed'),
(5, '2025-03-08 13:00:00', 'Completed');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 3),
(3, 4, 1),
(4, 5, 2),
(5, 6, 4),
(6, 1, 1);

INSERT INTO payments (order_id, payment_date, amount) VALUES
(1, '2025-01-12 10:35:00', 899.97),
(2, '2025-02-14 14:25:00', 89.97),
(3, '2025-01-18 09:20:00', 89.99),
(4, '2025-02-05 16:50:00', 240.00),
(5, '2025-02-22 11:15:00', 60.00),
(6, '2025-03-08 13:05:00', 799.99);


-- =============================================================================
-- 3. CORE BUSINESS QUESTIONS (1 TO 15)
-- =============================================================================

-- --- Sales & Revenue Performance ---

-- Q1: Total Revenue Generated
SELECT SUM(amount) AS total_revenue 
FROM payments;

-- Q2: Monthly Revenue Trend
SELECT 
    DATE_TRUNC('month', o.order_date) AS sales_month, 
    SUM(p.amount) AS monthly_revenue
FROM orders o 
JOIN payments p ON o.order_id = p.order_id
GROUP BY 1 
ORDER BY 1;

-- Q3: Average Order Value (AOV)
SELECT AVG(amount) AS average_order_value 
FROM payments;

-- Q4: Top 3 Countries by Revenue
SELECT 
    c.country, 
    SUM(p.amount) AS total_revenue
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
JOIN payments p ON o.order_id = p.order_id
GROUP BY 1 
ORDER BY total_revenue DESC 
LIMIT 3;

-- Q5: High-Value Orders (Above $500)
SELECT order_id, amount 
FROM payments 
WHERE amount > 500 
ORDER BY amount DESC;


-- --- Product & Category Analysis ---

-- Q6: Top 5 Best-Selling Products by Quantity
SELECT 
    p.product_id, 
    p.category, 
    SUM(oi.quantity) AS total_sold
FROM order_items oi 
JOIN products p ON oi.product_id = p.product_id
GROUP BY 1, 2 
ORDER BY total_sold DESC 
LIMIT 5;

-- Q7: Revenue by Product Category
SELECT 
    pr.category, 
    SUM(oi.quantity * pr.price) AS category_revenue
FROM order_items oi 
JOIN products pr ON oi.product_id = pr.product_id
GROUP BY 1 
ORDER BY category_revenue DESC;

-- Q8: Products with Zero Sales
SELECT product_id, category 
FROM products 
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM order_items);

-- Q9: Average Items per Order
SELECT AVG(total_qty) AS avg_items_per_order 
FROM (
    SELECT order_id, SUM(quantity) AS total_qty 
    FROM order_items 
    GROUP BY 1
) sub;


-- --- Customer Insights & Retention ---

-- Q10: Customer Lifetime Value (LTV)
SELECT 
    c.customer_id, 
    SUM(p.amount) AS lifetime_value
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
JOIN payments p ON o.order_id = p.order_id
GROUP BY 1 
ORDER BY lifetime_value DESC;

-- Q11: Repeat Customer Rate (%)
SELECT 
    (COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) * 100.0) / COUNT(DISTINCT customer_id) AS repeat_rate
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count 
    FROM orders 
    GROUP BY 1
) sub;

-- Q12: Monthly Customer Acquisition
SELECT 
    DATE_TRUNC('month', signup_date) AS signup_month, 
    COUNT(customer_id) AS new_customers
FROM customers 
GROUP BY 1 
ORDER BY 1;

-- Q13: Inactive Customers (No purchase in 6+ months)
SELECT customer_id 
FROM customers 
WHERE customer_id NOT IN (
    SELECT customer_id 
    FROM orders 
    WHERE order_date >= NOW() - INTERVAL '6 month'
);


-- --- Operations & Order Status ---

-- Q14: Daily Order Volume
SELECT 
    order_date::date AS order_day, 
    COUNT(order_id) AS daily_orders
FROM orders 
GROUP BY 1 
ORDER BY 1;

-- Q15: Cancelled Order Rate (%)
SELECT 
    (COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) * 100.0) / COUNT(*) AS cancellation_rate
FROM orders;


-- =============================================================================
-- 4. ADVANCED SQL EXTENSIONS
-- =============================================================================

-- Extension A: 3-Month Moving Average of Revenue
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS sales_month, 
        SUM(p.amount) AS monthly_revenue
    FROM orders o 
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY 1
)
SELECT 
    sales_month,
    monthly_revenue,
    AVG(monthly_revenue) OVER (
        ORDER BY sales_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_revenue_3m
FROM monthly_sales
ORDER BY sales_month;

-- Extension B: Cohort Retention Analysis
WITH customer_cohorts AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', signup_date) AS cohort_month
    FROM customers
),
customer_activity AS (
    SELECT DISTINCT
        c.customer_id,
        cc.cohort_month,
        DATE_TRUNC('month', o.order_date) AS order_month
    FROM orders o
    JOIN customer_cohorts cc ON o.customer_id = cc.customer_id
)
SELECT 
    cohort_month,
    order_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM customer_activity
GROUP BY 1, 2
ORDER BY 1, 2;