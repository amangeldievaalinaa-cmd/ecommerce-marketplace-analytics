-- =============================================================================
-- 00_load_data.sql
-- E-Commerce Marketplace Analytics — Data Loading Reference
--
-- NOTE ON USAGE:
-- SQLite has no native "LOAD DATA" statement in standard SQL. The two
-- supported ways to bulk-load CSVs into SQLite are:
--   (1) the sqlite3 command-line shell's `.import` meta-command (shown below), or
--   (2) a Python driver (pandas.DataFrame.to_sql), which is what
--       02_sqlite_database_setup.ipynb actually uses, since it can also
--       validate row counts and dtypes as part of the same step.
--
-- This file documents the CLI-equivalent commands for reproducibility and
-- for anyone who prefers to load the database outside of Python. Run these
-- from the sqlite3 shell after 00_create_schema.sql has already been
-- executed against the same database file.
--
-- Table load order matters and mirrors the schema's dependency order:
-- categories and customers first (no dependencies), then products (depends
-- on categories), then orders (depends on customers), then order_items and
-- order_reviews (depend on orders/products).
-- =============================================================================

.mode csv
.headers on

-- categories
.import --skip 1 data/processed/categories.csv categories

-- customers
.import --skip 1 data/processed/customers.csv customers

-- products
.import --skip 1 data/processed/products.csv products

-- orders
.import --skip 1 data/processed/orders.csv orders

-- order_items
.import --skip 1 data/processed/order_items.csv order_items

-- order_reviews
.import --skip 1 data/processed/order_reviews.csv order_reviews

-- Quick post-load sanity check: row counts per table.
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
