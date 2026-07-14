-- =============================================================================
-- 01_business_queries.sql
-- E-Commerce Marketplace Analytics — Business Query Library
--
-- 20 queries organized Basic (6) -> Intermediate (8) -> Advanced Junior (6),
-- each answering one specific business question,
-- run against the schema built in
-- against the core database (categories, customers, products, orders, order_items,
-- order_reviews) and use SQLite-only syntax.
--
-- NOTE ON "Expected Output" and "Business Interpretation" below: these
-- describe the *shape* of the result and *how* to read whatever numbers
-- your real database produces — they are analysis guidance, not numbers
-- fabricated from this dataset. Run each query against your own
-- database/ecommerce.db to get the real figures.
-- =============================================================================

PRAGMA foreign_keys = ON;


-- #############################################################################
-- SECTION 1 — BASIC QUERIES (6)
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Query B1
-- Business Question: What is total revenue and total order volume?
-- Business Context: The single most fundamental executive-level number —
--     everything else in this project is a breakdown of this total.
-- Why This Matters: Without a baseline, no category, region, or trend
--     comparison has context.
-- Expected Output: One row with total_revenue and total_orders.
-- Business Interpretation: This is the headline figure for any executive
--     summary; every other query in this file explains a slice of it.
-- Possible Business Action: Use as the denominator for every "share of
--     revenue" calculation elsewhere in this analysis.
-- -----------------------------------------------------------------------------
SELECT
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items AS oi;


-- -----------------------------------------------------------------------------
-- Query B2
-- Business Question: What is the average order value (AOV)?
-- Business Context: AOV indicates typical basket size and is a standard
--     retail/marketplace benchmark metric.
-- Why This Matters: Rising AOV with flat order volume can still grow
--     revenue; management needs to know which lever is moving.
-- Expected Output: One row with average_order_value.
-- Business Interpretation: Compare this figure over time or against
--     competitor benchmarks to judge whether customers are buying more
--     per order or simply ordering more often.
-- Possible Business Action: If AOV is low, consider bundling or
--     cross-sell strategies; if high, consider whether checkout friction
--     is suppressing order frequency.
-- -----------------------------------------------------------------------------
SELECT
    ROUND(SUM(oi.price) * 1.0 / COUNT(DISTINCT oi.order_id), 2) AS average_order_value
FROM order_items AS oi;


-- -----------------------------------------------------------------------------
-- Query B3
-- Business Question: How many unique customers made purchases?
-- Business Context: Establishes the size of the active customer base.
-- Why This Matters: Revenue per customer and repeat-rate KPIs both need
--     this denominator.
-- Expected Output: One row with unique_customers.
-- Business Interpretation: A small unique-customer count relative to
--     order volume would suggest heavy reliance on a few repeat buyers;
--     a large count relative to orders suggests broad, shallow reach.
-- Possible Business Action: Feed directly into acquisition-vs-retention
--     strategy discussions.
-- -----------------------------------------------------------------------------
SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM orders;


-- -----------------------------------------------------------------------------
-- Query B4
-- Business Question: What are the top 10 products by revenue?
-- Business Context: Identifies which individual SKUs matter most to the
--     business, independent of category grouping.
-- Why This Matters: Product-level performance can highlight standout
--     items that category-level aggregation would hide.
-- Expected Output: Up to 10 rows: product_id, total_revenue, ordered
--     highest to lowest.
-- Business Interpretation: These are the products the business can least
--     afford to go out of stock on, or to lose the supplying seller of.
-- Possible Business Action: Prioritize inventory/availability monitoring
--     for these specific products.
-- -----------------------------------------------------------------------------
SELECT
    oi.product_id,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items AS oi
GROUP BY oi.product_id
ORDER BY total_revenue DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Query B5
-- Business Question: What is the distribution of order statuses?
-- Business Context: Shows operational health — how many orders complete
--     normally versus getting canceled or marked unavailable.
-- Why This Matters: A high non-delivered rate signals fulfillment
--     problems that could be quietly eroding revenue and satisfaction.
-- Expected Output: One row per distinct order_status with its count and
--     percentage share.
-- Business Interpretation: Compare the "delivered" share against
--     "canceled"/"unavailable" to gauge overall fulfillment reliability.
-- Possible Business Action: If cancellations concentrate in specific
--     periods or categories, investigate the operational cause.
-- -----------------------------------------------------------------------------
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- -----------------------------------------------------------------------------
-- Query B6
-- Business Question: What is the average customer review score?
-- Business Context: A single-number proxy for overall customer
--     satisfaction across the whole marketplace.
-- Why This Matters: Satisfaction trends are an early warning system for
--     churn and reputation risk.
-- Expected Output: One row with average_review_score.
-- Business Interpretation: A score comfortably above the midpoint (3)
--     suggests broad satisfaction; a score near or below it warrants
--     deeper investigation (see Query I8).
-- Possible Business Action: Track this figure over time as a leading
--     health indicator, independent of revenue trends.
-- -----------------------------------------------------------------------------
SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM order_reviews;


-- #############################################################################
-- SECTION 2 — INTERMEDIATE QUERIES (8)
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Query I1
-- Business Question: Which product categories generate the most revenue?
-- Business Context: Category-level revenue is the natural unit for
--     merchandising and marketing prioritization decisions.
-- Why This Matters: Category performance guides where to invest in
--     supplier relationships and promotional spend.
-- Expected Output: One row per category (English name where available)
--     with total revenue, ordered highest to lowest.
-- Business Interpretation: The top categories are the marketplace's
--     current core strength; categories far down the list may be niche
--     or underperforming.
-- Possible Business Action: Consider expanding seller/product variety in
--     top categories and re-evaluating investment in the weakest ones.
-- -----------------------------------------------------------------------------
SELECT
    COALESCE(c.category_name_english, c.category_name_portuguese) AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items AS oi
INNER JOIN products AS p ON oi.product_id = p.product_id
INNER JOIN categories AS c ON p.category_id = c.category_id
GROUP BY category
ORDER BY total_revenue DESC;


-- -----------------------------------------------------------------------------
-- Query I2
-- Business Question: Which Brazilian states generate the most revenue?
-- Business Context: Regional revenue distribution informs logistics and
--     marketing geography decisions.
-- Why This Matters: A marketplace with heavy regional concentration has
--     different logistics needs than one spread evenly nationwide.
-- Expected Output: One row per state with total revenue, ordered highest
--     to lowest.
-- Business Interpretation: States at the top are the current core
--     market; states far down the list may represent expansion
--     opportunity or genuinely low demand.
-- Possible Business Action: Prioritize regional fulfillment/logistics
--     investment toward the states driving the most revenue.
-- -----------------------------------------------------------------------------
SELECT
    cu.customer_state,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items AS oi
INNER JOIN orders AS o ON oi.order_id = o.order_id
INNER JOIN customers AS cu ON o.customer_unique_id = cu.customer_unique_id
GROUP BY cu.customer_state
ORDER BY total_revenue DESC;


-- -----------------------------------------------------------------------------
-- Query I3
-- Business Question: How has monthly revenue and order volume trended?
-- Business Context: The primary time-series view management needs to
--     assess overall business momentum.
-- Why This Matters: Distinguishes genuine growth from one-off spikes,
--     and reveals seasonality.
-- Expected Output: One row per calendar month with revenue and order
--     count, ordered chronologically.
-- Business Interpretation: Consistent upward movement suggests healthy
--     growth; volatility or plateaus warrant a closer look at what
--     changed in those months.
-- Possible Business Action: Align marketing and inventory planning with
--     any observed seasonal pattern.
-- -----------------------------------------------------------------------------
SELECT
    STRFTIME('%Y-%m', o.order_purchase_timestamp) AS order_month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS monthly_orders
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;


-- -----------------------------------------------------------------------------
-- Query I4
-- Business Question: What percentage of customers are repeat purchasers?
-- Business Context: Repeat-purchase rate is a foundational loyalty and
--     retention signal for any marketplace.
-- Why This Matters: Acquiring a new customer is typically more expensive
--     than retaining one; this metric shows how much the business
--     currently relies on each.
-- Expected Output: One row with total_customers, repeat_customers, and
--     repeat_customer_rate_pct.
-- Business Interpretation: A low repeat rate suggests the business is
--     acquisition-driven rather than loyalty-driven — worth knowing
--     before investing in retention programs.
-- Possible Business Action: If the rate is low, evaluate whether
--     post-purchase engagement (reviews, follow-up offers) could improve
--     it.
-- -----------------------------------------------------------------------------
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS repeat_customer_rate_pct
FROM (
    SELECT customer_unique_id, COUNT(DISTINCT order_id) AS order_count
    FROM orders
    GROUP BY customer_unique_id
) AS customer_order_counts;


-- -----------------------------------------------------------------------------
-- Query I5
-- Business Question: What is the average delivery time for delivered
--     orders?
-- Business Context: Delivery speed is a core driver of customer
--     experience in any e-commerce marketplace.
-- Why This Matters: Slow delivery is one of the most common causes of
--     customer dissatisfaction and negative reviews.
-- Expected Output: One row with average_delivery_days.
-- Business Interpretation: Compare this figure against the average
--     estimated delivery window (Query I6) to judge whether Olist's own
--     promises are realistic.
-- Possible Business Action: If delivery time is high, investigate
--     whether specific states or categories are driving the average up.
-- -----------------------------------------------------------------------------
SELECT
    ROUND(AVG(
        JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_purchase_timestamp)
    ), 2) AS average_delivery_days
FROM orders
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND has_date_anomaly = 0;


-- -----------------------------------------------------------------------------
-- Query I6
-- Business Question: What percentage of orders are delivered later than
--     Olist's own estimated delivery date?
-- Business Context: Measures reliability against the company's own
--     promise to the customer, not an arbitrary external benchmark.
-- Why This Matters: A broken delivery promise is arguably worse for
--     satisfaction than a merely slow delivery that was expected.
-- Expected Output: One row with total_delivered, late_deliveries, and
--     late_delivery_rate_pct.
-- Business Interpretation: A high late rate directly threatens customer
--     trust and is a natural companion metric to the review-score
--     analysis in Query I8.
-- Possible Business Action: If the rate is high, review whether
--     estimated delivery dates are being set unrealistically optimistic
--     in the first place.
-- -----------------------------------------------------------------------------
SELECT
    COUNT(*) AS total_delivered,
    SUM(CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
        ELSE 0
    END) AS late_deliveries,
    ROUND(
        SUM(CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS late_delivery_rate_pct
FROM orders
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND has_date_anomaly = 0;


-- -----------------------------------------------------------------------------
-- Query I7
-- Business Question: How does order volume vary by day of the week?
-- Business Context: Reveals customer shopping-day patterns.
-- Why This Matters: Staffing, promotions, and marketing timing can all
--     be aligned to genuine demand patterns rather than assumptions.
-- Expected Output: One row per weekday with order count, ordered by
--     weekday.
-- Business Interpretation: Clear peaks on specific days suggest natural
--     "shopping days" worth reinforcing with targeted promotions.
-- Possible Business Action: Schedule marketing pushes just ahead of the
--     highest-volume days.
-- -----------------------------------------------------------------------------
SELECT
    CASE CAST(STRFTIME('%w', order_purchase_timestamp) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS weekday,
    COUNT(*) AS order_count
FROM orders
GROUP BY STRFTIME('%w', order_purchase_timestamp)
ORDER BY STRFTIME('%w', order_purchase_timestamp);


-- -----------------------------------------------------------------------------
-- Query I8
-- Business Question: Is there a relationship between late delivery and
--     review score?
-- Business Context: Tests whether operational delivery performance
--     actually connects to customer-reported satisfaction, rather than
--     assuming it does.
-- Why This Matters: If the relationship is strong, delivery investment
--     directly protects reputation; if weak, satisfaction drivers lie
--     elsewhere.
-- Expected Output: Two rows — "on_time" and "late" — each with an
--     average review score.
-- Business Interpretation: A materially lower average score for "late"
--     orders is direct evidence that delivery reliability drives
--     satisfaction, supporting further investment in logistics.
-- Possible Business Action: If confirmed, treat on-time delivery as a
--     satisfaction lever, not just an operational metric.
-- -----------------------------------------------------------------------------
SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'late'
        ELSE 'on_time'
    END AS delivery_outcome,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(*) AS n_orders
FROM orders AS o
INNER JOIN order_reviews AS r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.has_date_anomaly = 0
GROUP BY delivery_outcome;


-- #############################################################################
-- SECTION 3 — ADVANCED JUNIOR QUERIES (6)
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Query A1
-- Business Question: What is the single top-selling product within each
--     category?
-- Business Context: A "top-N per group" problem — identifying category
--     leaders rather than just overall top sellers.
-- Why This Matters: A product might not crack the overall top 10 (Query
--     B4) but still be the clear leader of its own category, which
--     matters for category-specific merchandising decisions.
-- Expected Output: One row per category with its top product_id and
--     that product's revenue.
-- Business Interpretation: These are the products each category's
--     merchandising strategy should be built around.
-- Possible Business Action: Ensure category landing pages and
--     promotions feature these specific products prominently.
-- -----------------------------------------------------------------------------
WITH product_revenue AS (
    SELECT
        p.category_id,
        oi.product_id,
        SUM(oi.price) AS total_revenue
    FROM order_items AS oi
    INNER JOIN products AS p ON oi.product_id = p.product_id
    GROUP BY p.category_id, oi.product_id
),
ranked_products AS (
    SELECT
        category_id,
        product_id,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category_id ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT
    COALESCE(c.category_name_english, c.category_name_portuguese) AS category,
    rp.product_id AS top_product,
    ROUND(rp.total_revenue, 2) AS product_revenue
FROM ranked_products AS rp
INNER JOIN categories AS c ON rp.category_id = c.category_id
WHERE rp.revenue_rank = 1
ORDER BY product_revenue DESC;


-- -----------------------------------------------------------------------------
-- Query A2
-- Business Question: How do Brazilian states rank against each other by
--     total revenue, including tie handling?
-- Business Context: A ranked view (rather than just sorted) makes ties
--     and relative standing explicit, which a plain ORDER BY does not.
-- Why This Matters: RANK() correctly shows tied states sharing a
--     position, which matters when presenting standings to
--     stakeholders.
-- Expected Output: One row per state with total revenue and its rank.
-- Business Interpretation: The relative gap between rank 1 and rank 2
--     (etc.) shows how concentrated or evenly spread regional revenue
--     really is.
-- Possible Business Action: A large gap between the top state and the
--     rest signals over-reliance on one region worth diversifying away
--     from.
-- -----------------------------------------------------------------------------
SELECT
    cu.customer_state,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM order_items AS oi
INNER JOIN orders AS o ON oi.order_id = o.order_id
INNER JOIN customers AS cu ON o.customer_unique_id = cu.customer_unique_id
GROUP BY cu.customer_state
ORDER BY revenue_rank;


-- -----------------------------------------------------------------------------
-- Query A3
-- Business Question: What does the running (cumulative) total of monthly
--     revenue look like over time?
-- Business Context: A running total shows cumulative growth trajectory,
--     which a plain monthly breakdown (Query I3) does not directly
--     convey.
-- Why This Matters: Cumulative revenue is often the figure used in
--     investor or leadership progress reporting.
-- Expected Output: One row per month with monthly revenue and a running
--     cumulative total.
-- Business Interpretation: A running total that curves upward
--     increasingly steeply indicates accelerating growth; a
--     straight-line total indicates steady, linear growth.
-- Possible Business Action: Use the running total as the basis for any
--     "revenue to date" reporting to leadership.
-- -----------------------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS order_month,
        SUM(oi.price) AS monthly_revenue
    FROM orders AS o
    INNER JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY order_month
)
SELECT
    order_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY order_month), 2) AS running_total_revenue
FROM monthly_revenue
ORDER BY order_month;


-- -----------------------------------------------------------------------------
-- Query A4
-- Business Question: What is the month-over-month revenue growth rate?
-- Business Context: Growth rate (not just absolute revenue) is what
--     leadership typically tracks month to month.
-- Why This Matters: A raw revenue figure alone hides whether the
--     business is accelerating, decelerating, or flat.
-- Expected Output: One row per month with monthly revenue, prior month's
--     revenue, and percentage growth.
-- Business Interpretation: Consecutive months of negative growth would
--     be an early warning sign worth investigating before it shows up
--     in the annual numbers.
-- Possible Business Action: Set a recurring review of this metric as
--     part of a monthly business review cadence.
-- -----------------------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS order_month,
        SUM(oi.price) AS monthly_revenue
    FROM orders AS o
    INNER JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY order_month
)
SELECT
    order_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(LAG(monthly_revenue) OVER (ORDER BY order_month), 2) AS prior_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month))
        * 100.0 / LAG(monthly_revenue) OVER (ORDER BY order_month),
        2
    ) AS revenue_growth_pct
FROM monthly_revenue
ORDER BY order_month;


-- -----------------------------------------------------------------------------
-- Query A5
-- Business Question: Which customers generate above-average revenue per
--     customer?
-- Business Context: Identifies a high-value customer segment worth
--     understanding separately from the general customer base.
-- Why This Matters: A small group of above-average customers often
--     represents a disproportionate share of total revenue.
-- Expected Output: One row per above-average customer with their total
--     revenue, ordered highest to lowest.
-- Business Interpretation: The size of this group relative to the total
--     customer base (Query B3) indicates how concentrated the customer
--     base's value really is.
-- Possible Business Action: Consider a loyalty or VIP outreach program
--     targeted specifically at this segment.
-- -----------------------------------------------------------------------------
WITH customer_revenue AS (
    SELECT
        o.customer_unique_id,
        SUM(oi.price) AS total_revenue
    FROM orders AS o
    INNER JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY o.customer_unique_id
),
overall_average AS (
    SELECT AVG(total_revenue) AS avg_revenue FROM customer_revenue
)
SELECT
    cr.customer_unique_id,
    ROUND(cr.total_revenue, 2) AS total_revenue
FROM customer_revenue AS cr
CROSS JOIN overall_average AS oa
WHERE cr.total_revenue > oa.avg_revenue
ORDER BY cr.total_revenue DESC;


-- -----------------------------------------------------------------------------
-- Query A6
-- Business Question: Within each state, which product category
--     generates the most revenue?
-- Business Context: A "top-N per group" marketplace-performance
--     question — do the same categories dominate everywhere, or does
--     regional taste vary?
-- Why This Matters: If category preference varies by region, a single
--     nationwide merchandising strategy may be leaving revenue on the
--     table in specific states.
-- Expected Output: One row per state with its top category and that
--     category's revenue in that state.
-- Business Interpretation: If the same 1-2 categories dominate every
--     state, national strategy is likely fine; if leaders vary widely,
--     regional customization may help.
-- Possible Business Action: Tailor regional marketing/inventory toward
--     each state's actual top category rather than a single national
--     assumption.
-- -----------------------------------------------------------------------------
WITH state_category_revenue AS (
    SELECT
        cu.customer_state,
        COALESCE(c.category_name_english, c.category_name_portuguese) AS category,
        SUM(oi.price) AS category_revenue
    FROM order_items AS oi
    INNER JOIN orders AS o ON oi.order_id = o.order_id
    INNER JOIN customers AS cu ON o.customer_unique_id = cu.customer_unique_id
    INNER JOIN products AS p ON oi.product_id = p.product_id
    INNER JOIN categories AS c ON p.category_id = c.category_id
    GROUP BY cu.customer_state, category
),
ranked_state_categories AS (
    SELECT
        customer_state,
        category,
        category_revenue,
        DENSE_RANK() OVER (
            PARTITION BY customer_state ORDER BY category_revenue DESC
        ) AS category_rank
    FROM state_category_revenue
)
SELECT
    customer_state,
    category AS top_category,
    ROUND(category_revenue, 2) AS category_revenue
FROM ranked_state_categories
WHERE category_rank = 1
ORDER BY category_revenue DESC;


-- =============================================================================
-- NOTE: The following two business questions
-- specification are NOT implemented above because they require the
-- `sellers` table, which was intentionally excluded from the core
-- six-table schema (marked optional/bonus, not loaded in
--   - "How many distinct sellers are represented, and how concentrated
--      is revenue among top sellers?"
--   - "Do certain categories show a consistent pattern of slower
--      delivery tied to specific sellers?"
-- These can be added later if the sellers table is loaded
-- as an extension per the original scope notes on "Future
-- Extensions" section.
-- =============================================================================
