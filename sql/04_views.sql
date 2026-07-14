-- =============================================================================
-- 04_views.sql
-- E-Commerce Marketplace Analytics — Reusable Views
--
-- Four views that persist the most commonly needed aggregations directly
-- in the database, so the Python EDA notebook (and any future SQL work)
-- can query a simple, stable view instead of re-deriving the same joins
-- and GROUP BY logic every time.
-- =============================================================================

PRAGMA foreign_keys = ON;


-- -----------------------------------------------------------------------------
-- vw_customer_summary
--
-- Why this view exists: customer-level revenue, order count, and average
-- order value are needed by repeat-purchase analysis, customer-value
-- segmentation, and the Python EDA KPI calculations. Rather than repeating
-- this join/aggregation in every future query, it is defined once here.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_customer_summary;
CREATE VIEW vw_customer_summary AS
SELECT
    o.customer_unique_id,
    cu.customer_state,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(oi.price) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
INNER JOIN customers AS cu ON o.customer_unique_id = cu.customer_unique_id
GROUP BY o.customer_unique_id, cu.customer_state;


-- -----------------------------------------------------------------------------
-- vw_delivery_performance
--
-- Why this view exists: delivery days and the late-delivery flag are
-- needed by both delivery KPIs and the review-score correlation
-- analysis. Persisting this as a view keeps every future consumer
-- consistent with the same delivery-time and lateness definition.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_delivery_performance;
CREATE VIEW vw_delivery_performance AS
SELECT
    order_id,
    customer_unique_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp) AS delivery_days,
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
        ELSE 0
    END AS is_late
FROM orders
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND has_date_anomaly = 0;


-- -----------------------------------------------------------------------------
-- vw_monthly_sales
--
-- Why this view exists: the monthly revenue/order aggregation is the
-- base for trend charts, running totals, and growth-rate calculations
-- throughout this project. A single view means every later query builds
-- on exactly the same monthly definition.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_monthly_sales;
CREATE VIEW vw_monthly_sales AS
SELECT
    STRFTIME('%Y-%m', o.order_purchase_timestamp) AS order_month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS monthly_orders
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
GROUP BY order_month;


-- -----------------------------------------------------------------------------
-- vw_category_summary
--
-- Why this view exists: category-level revenue is the natural unit for
-- merchandising decisions and is queried repeatedly (overall ranking,
-- per-state breakdowns, top-product-per-category). This view gives a
-- single, stable source for "revenue by category."
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_category_summary;
CREATE VIEW vw_category_summary AS
SELECT
    c.category_id,
    COALESCE(c.category_name_english, c.category_name_portuguese) AS category_name,
    COUNT(DISTINCT oi.order_id) AS order_count,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items AS oi
INNER JOIN products AS p ON oi.product_id = p.product_id
INNER JOIN categories AS c ON p.category_id = c.category_id
GROUP BY c.category_id, category_name;


-- -----------------------------------------------------------------------------
-- Quick confirmation queries (not part of the views themselves — run
-- these after creating the views above to confirm each one works).
-- -----------------------------------------------------------------------------
SELECT * FROM vw_customer_summary ORDER BY total_revenue DESC LIMIT 5;
SELECT * FROM vw_delivery_performance LIMIT 5;
SELECT * FROM vw_monthly_sales ORDER BY order_month;
SELECT * FROM vw_category_summary ORDER BY total_revenue DESC;
