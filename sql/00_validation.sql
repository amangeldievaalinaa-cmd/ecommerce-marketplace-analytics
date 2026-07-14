-- =============================================================================
-- 00_validation.sql
-- E-Commerce Marketplace Analytics — Database Integrity Validation
--
-- Every query here can be run standalone in the sqlite3 shell (or via the
-- setup notebook) against the loaded database to confirm the schema and
-- data behave exactly as designed in the schema. All queries use SQLite-only
-- syntax and return zero rows when everything is healthy, unless noted.
-- =============================================================================

PRAGMA foreign_keys = ON;

-- -----------------------------------------------------------------------------
-- 1. Row counts per table (informational — compare against the cleaned CSV counts)
-- -----------------------------------------------------------------------------
SELECT 'categories' AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews;

-- -----------------------------------------------------------------------------
-- 2. Primary key uniqueness (should return zero rows for every table)
-- -----------------------------------------------------------------------------
SELECT 'customers' AS table_name, customer_unique_id AS key_value, COUNT(*) AS n
FROM customers GROUP BY customer_unique_id HAVING COUNT(*) > 1;

SELECT 'orders' AS table_name, order_id AS key_value, COUNT(*) AS n
FROM orders GROUP BY order_id HAVING COUNT(*) > 1;

SELECT 'products' AS table_name, product_id AS key_value, COUNT(*) AS n
FROM products GROUP BY product_id HAVING COUNT(*) > 1;

SELECT 'categories' AS table_name, category_id AS key_value, COUNT(*) AS n
FROM categories GROUP BY category_id HAVING COUNT(*) > 1;

SELECT 'order_reviews' AS table_name, review_id AS key_value, COUNT(*) AS n
FROM order_reviews GROUP BY review_id HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- 3. Composite key uniqueness for order_items (should return zero rows)
-- -----------------------------------------------------------------------------
SELECT order_id, order_item_id, COUNT(*) AS n
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- 4. Foreign key integrity (should all return zero rows)
-- -----------------------------------------------------------------------------

-- orders.customer_unique_id -> customers.customer_unique_id
SELECT o.order_id, o.customer_unique_id
FROM orders o
LEFT JOIN customers c ON o.customer_unique_id = c.customer_unique_id
WHERE c.customer_unique_id IS NULL;

-- order_items.order_id -> orders.order_id
SELECT oi.order_id, oi.order_item_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- order_items.product_id -> products.product_id
SELECT oi.order_id, oi.order_item_id, oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- products.category_id -> categories.category_id (nullable FK: only checks non-null values)
SELECT p.product_id, p.category_id
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE p.category_id IS NOT NULL AND c.category_id IS NULL;

-- order_reviews.order_id -> orders.order_id
SELECT r.review_id, r.order_id
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- -----------------------------------------------------------------------------
-- 5. NOT NULL constraint spot-check (should all return zero rows)
-- -----------------------------------------------------------------------------
SELECT * FROM orders WHERE customer_unique_id IS NULL OR order_status IS NULL
    OR order_estimated_delivery_date IS NULL;

SELECT * FROM order_items WHERE order_id IS NULL OR product_id IS NULL OR price IS NULL;

SELECT * FROM order_reviews WHERE order_id IS NULL OR review_score IS NULL
    OR review_creation_date IS NULL;

-- -----------------------------------------------------------------------------
-- 6. Review linkage cardinality (should return zero rows — one review per order)
-- -----------------------------------------------------------------------------
SELECT order_id, COUNT(*) AS n_reviews
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- 7. Category mapping integrity (informational — count of products with a
--    category that has no English translation, expected to be small or zero)
-- -----------------------------------------------------------------------------
SELECT p.product_id, c.category_name_portuguese
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE c.category_name_english IS NULL;

-- -----------------------------------------------------------------------------
-- 8. review_score domain check (should return zero rows; CHECK constraint
--    should already prevent this, this is a defense-in-depth confirmation)
-- -----------------------------------------------------------------------------
SELECT * FROM order_reviews WHERE review_score < 1 OR review_score > 5;
