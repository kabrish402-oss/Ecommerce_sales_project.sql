# E-commerce Sales & Customer Analytics Project (SQL)

📌 Project Overview

This portfolio project focuses on performing end-to-end data analysis for an E-commerce business using standard SQL (PostgreSQL / MySQL compatible). The objective is to extract actionable insights on revenue performance, product demand trends, customer retention, and operational efficiency to drive data-informed business decisions.

🗄️ Database Schema & Architecture

The database consists of 5 primary relational tables:

customers: Unique identifiers, signup dates, and customer geographical details.

products: Product catalogue with categories and individual pricing.

orders: High-level transaction logs including dates and fulfillment statuses.

order_items: Line-item level details mapping products to orders with quantities.

payments: Payment confirmation logs linked directly to customer orders.

+---------------+        +------------+        +-----------------+
|   customers   |        |   orders   |        |   order_items   |
+---------------+        +------------+        +-----------------+
| customer_id   |<------>| order_id   |<------>| order_item_id   |
| signup_date   |        | customer_id|        | order_id        |
| country       |        | order_date |        | product_id      |
+---------------+        | status     |        | quantity        |
                         +------------+        +-----------------+
                               |                        |
                               v                        v
                         +------------+        +-----------------+
                         |  payments  |        |    products     |
                         +------------+        +-----------------+
                         | payment_id |        | product_id      |
                         | order_id   |        | category        |
                         | amount     |        | price           |
                         +------------+        +-----------------+


🎯 Key Business Questions & SQL Coverage

The project answers 15 fundamental business questions across 4 key operational pillars, along with advanced SQL techniques:

1. Sales & Revenue Performance

Total Revenue (SUM)

Monthly Sales Trends (DATE_TRUNC, GROUP BY)

Average Order Value (AOV)

Top Revenue-Generating Countries

High-Value Order Identification

2. Product & Category Analytics

Top 5 Best-Selling Products

Category-Level Revenue Performance

Dead Stock / Zero Sales Analysis (NOT IN subqueries)

Average Basket Size (Items per Order)

3. Customer Insights & Lifecycle

Customer Lifetime Value (LTV)

Repeat Purchase Rate (%)

New Customer Acquisition Trends

Customer Churn & Inactivity Identification (6+ Month Threshold)

4. Operations & Fulfillment

Daily Order Volume

Cancellation Rate (%) (CASE WHEN conditional aggregates)

🚀 Advanced Analytics Showcase

In addition to standard queries, this project highlights advanced SQL capabilities:

🔹 3-Month Moving Average Revenue

Uses Window Functions (OVER, ROWS BETWEEN) inside a Common Table Expression (CTE) to smooth out seasonality and highlight revenue trajectories.

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
FROM monthly_sales;


🔹 Cohort Retention Analysis

Tracks user retention month-over-month by linking customer signup cohorts to subsequent transaction activity.

🛠️ How to Run

Clone this repository:

git clone https://github.com/your-username/ecommerce-sql-analysis.git


Open your PostgreSQL or MySQL database client (e.g., pgAdmin, DBeaver, VS Code SQL extensions).

Execute ecommerce_sales_project.sql to build tables, insert seed data, and run analytical queries.

📈 Next Steps

Connect PostgreSQL query outputs to Power BI / Tableau for visual reporting.

Implement RFM (Recency, Frequency, Monetary) segmentation via SQL NTILE functions.
