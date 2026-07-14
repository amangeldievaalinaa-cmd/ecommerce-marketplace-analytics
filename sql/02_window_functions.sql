-- =============================================================================
-- 02_window_functions.sql
-- E-Commerce Marketplace Analytics — Window Function Reference
--
-- Five standalone, technique-focused demonstrations of the window
-- functions used throughout this project. Each solves a distinct,
-- realistic business problem rather than being a toy example. These
-- overlap conceptually with a few Advanced queries in
-- 01_business_queries.sql by design — that file frames them as business
-- cases; this file is a clean technique reference for interview
-- preparation.
-- =============================================================================

PRAGMA foreign_keys = ON;


-- -----------------------------------------------------------------------------
-- 1. ROW_NUMBER() — assign a unique rank per group, breaking ties by an
--    explicit tiebreaker column so results are always deterministic.
--
-- Business use: identify the single most recent review for each order,
-- guarding against any future data load that might reintroduce the
-- multi-review-per-order issue documented in the data quality report.
-- -----------------------------------------------------------------------------
SELECT
    order_id,
    review_id,
    review_score,
    review_creation_date,
    ROW_NUMBER() OVER (
        PARTITION BY order_id
        ORDER BY review_creation_date DESC, review_id DESC
    ) AS recency_rank
FROM order_reviews;


-- -----------------------------------------------------------------------------
-- 2. RANK() — rank items with ties sharing the same rank and a gap left
--    afterward (e.g., two items tied for 1st means the next is rank 3).
--
-- Business use: rank product categories by total revenue, making tied
-- categories explicitly visible rather than arbitrarily broken.
-- -----------------------------------------------------------------------------
SELECT
    COALESCE(c.category_name_english, c.category_name_portuguese) AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM order_items AS oi
INNER JOIN products AS p ON oi.product_id = p.product_id
INNER JOIN categories AS c ON p.category_id = c.category_id
GROUP BY category
ORDER BY revenue_rank;


-- -----------------------------------------------------------------------------
-- 3. DENSE_RANK() — like RANK(), but leaves no gap after ties (two items
--    tied for 1st means the next is rank 2, not rank 3).
--
-- Business use: rank states by average review score, where DENSE_RANK()
-- gives a cleaner "top N states" list when several states tie on score.
-- -----------------------------------------------------------------------------
SELECT
    cu.customer_state,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    DENSE_RANK() OVER (ORDER BY AVG(r.review_score) DESC) AS satisfaction_rank
FROM order_reviews AS r
INNER JOIN orders AS o ON r.order_id = o.order_id
INNER JOIN customers AS cu ON o.customer_unique_id = cu.customer_unique_id
GROUP BY cu.customer_state
ORDER BY satisfaction_rank;


-- -----------------------------------------------------------------------------
-- 4. SUM() OVER() — running/cumulative total across an ordered window.
--
-- Business use: cumulative revenue over time, the figure most commonly
-- used in "revenue to date" executive reporting.
-- -----------------------------------------------------------------------------
SELECT
    STRFTIME('%Y-%m', o.order_purchase_timestamp) AS order_month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue,
    ROUND(
        SUM(SUM(oi.price)) OVER (
            ORDER BY STRFTIME('%Y-%m', o.order_purchase_timestamp)
        ), 2
    ) AS cumulative_revenue
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;


-- -----------------------------------------------------------------------------
-- 5. LAG() — look back at the previous row within an ordered window,
--    the standard building block for period-over-period comparisons.
--
-- Business use: month-over-month change in delivered order volume
-- (distinct from the revenue growth version in Query A4, to show LAG()
-- applied to a different metric).
-- -----------------------------------------------------------------------------
WITH monthly_delivered_orders AS (
    SELECT
        STRFTIME('%Y-%m', order_purchase_timestamp) AS order_month,
        COUNT(*) AS delivered_order_count
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY order_month
)
SELECT
    order_month,
    delivered_order_count,
    LAG(delivered_order_count) OVER (ORDER BY order_month) AS prior_month_delivered_orders,
    delivered_order_count - LAG(delivered_order_count) OVER (ORDER BY order_month) AS change_vs_prior_month
FROM monthly_delivered_orders
ORDER BY order_month;
