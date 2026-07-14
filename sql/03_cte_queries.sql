-- =============================================================================
-- 03_cte_queries.sql
-- E-Commerce Marketplace Analytics — Common Table Expression Reference
--
-- Five reusable CTE building blocks. Each is written to stand on its own
-- (usable directly, or as a starting point pasted into a larger query),
-- and each is used because it genuinely simplifies a multi-step
-- calculation — not used for its own sake.
-- =============================================================================

PRAGMA foreign_keys = ON;


-- -----------------------------------------------------------------------------
-- 1. Clean order-level revenue table
--
-- Why a CTE: every query that needs "revenue per order" would otherwise
-- repeat this same order_items -> SUM(price) aggregation. Defining it
-- once keeps later logic focused on the actual business question.
-- -----------------------------------------------------------------------------
WITH order_level_revenue AS (
    SELECT
        o.order_id,
        o.customer_unique_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.has_date_anomaly,
        SUM(oi.price) AS order_revenue
    FROM orders AS o
    INNER JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_unique_id, o.order_status,
             o.order_purchase_timestamp, o.has_date_anomaly
)
SELECT * FROM order_level_revenue
ORDER BY order_revenue DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- 2. Customer revenue summary
--
-- Why a CTE: customer-level revenue, order count, and average order
-- value are used together in several places (repeat-rate analysis,
-- above-average customer identification); this consolidates them once.
-- -----------------------------------------------------------------------------
WITH customer_revenue_summary AS (
    SELECT
        o.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        ROUND(SUM(oi.price), 2) AS total_revenue,
        ROUND(SUM(oi.price) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
    FROM orders AS o
    INNER JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY o.customer_unique_id
)
SELECT * FROM customer_revenue_summary
ORDER BY total_revenue DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- 3. Monthly revenue table
--
-- Why a CTE: the monthly revenue aggregation is the base for the
-- running-total, growth-rate, and trend-chart queries elsewhere in this
-- project; defining it once avoids three slightly-different copies of
-- the same GROUP BY existing across the codebase.
-- -----------------------------------------------------------------------------
WITH monthly_revenue_table AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS order_month,
        ROUND(SUM(oi.price), 2) AS monthly_revenue,
        COUNT(DISTINCT o.order_id) AS monthly_orders
    FROM orders AS o
    INNER JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY order_month
)
SELECT * FROM monthly_revenue_table
ORDER BY order_month;


-- -----------------------------------------------------------------------------
-- 4. Delivery performance table
--
-- Why a CTE: delivery days and the late-delivery flag are needed by both
-- the delivery KPIs and the review-score correlation analysis; computing
-- them once here keeps both consumers consistent with each other.
-- -----------------------------------------------------------------------------
WITH delivery_performance AS (
    SELECT
        order_id,
        customer_unique_id,
        JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp) AS delivery_days,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
            ELSE 0
        END AS is_late
    FROM orders
    WHERE order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
        AND has_date_anomaly = 0
)
SELECT
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    SUM(is_late) AS late_orders,
    COUNT(*) AS total_delivered,
    ROUND(SUM(is_late) * 100.0 / COUNT(*), 2) AS late_rate_pct
FROM delivery_performance;


-- -----------------------------------------------------------------------------
-- 5. Review summary table
--
-- Why a CTE: joining reviews back to orders and bucketing scores is
-- reused by both the plain review-score KPI and the delivery-correlation
-- analysis; this keeps the bucketing logic defined in exactly one place.
-- -----------------------------------------------------------------------------
WITH review_summary AS (
    SELECT
        r.order_id,
        r.review_score,
        CASE
            WHEN r.review_score <= 2 THEN 'negative'
            WHEN r.review_score = 3 THEN 'neutral'
            ELSE 'positive'
        END AS review_category
    FROM order_reviews AS r
)
SELECT
    review_category,
    COUNT(*) AS n_reviews,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM review_summary), 2) AS pct_of_reviews
FROM review_summary
GROUP BY review_category
ORDER BY n_reviews DESC;
