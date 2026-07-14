-- =============================================================================
-- 00_create_schema.sql
-- E-Commerce Marketplace Analytics — SQLite Schema Definition
--
-- Reproduces the six-table schema defined for this project exactly. SQLite-only
-- syntax is used throughout (no vendor-specific extensions). Foreign keys
-- are declared but SQLite requires PRAGMA foreign_keys = ON per connection
-- to actually enforce them at runtime (handled in the setup notebook).
--
-- Table creation order matters: parent tables (categories, customers,
-- products) are created before the child tables that reference them
-- (products, orders, order_items, order_reviews).
-- =============================================================================

PRAGMA foreign_keys = ON;

-- -----------------------------------------------------------------------------
-- categories: category reference table, English-labeled where available
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
    category_id             INTEGER PRIMARY KEY,
    category_name_portuguese TEXT    NOT NULL,
    category_name_english   TEXT,                 -- nullable: some categories have no translation
    UNIQUE (category_name_portuguese)
);

-- -----------------------------------------------------------------------------
-- customers: one row per deduplicated real customer (customer_unique_id)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_unique_id TEXT PRIMARY KEY,
    customer_city       TEXT,                     -- nullable: a small number of rows have no city
    customer_state      TEXT
);

-- -----------------------------------------------------------------------------
-- products: product catalog, linked to categories
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id       TEXT PRIMARY KEY,
    category_id       INTEGER,                    -- nullable: unmapped categories are rare but possible
    product_weight_g REAL,                        -- nullable: missing for a small number of products
    FOREIGN KEY (category_id) REFERENCES categories (category_id)
);

-- -----------------------------------------------------------------------------
-- orders: order header / lifecycle table
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id                        TEXT PRIMARY KEY,
    customer_unique_id              TEXT NOT NULL,
    order_status                    TEXT NOT NULL,
    order_purchase_timestamp        TEXT,          -- nullable: a small number of unparseable timestamps exist
    order_approved_at               TEXT,          -- nullable: null for some canceled orders
    order_delivered_carrier_date    TEXT,          -- nullable: null if not yet shipped
    order_delivered_customer_date   TEXT,          -- nullable: null if not yet delivered
    order_estimated_delivery_date   TEXT NOT NULL,
    has_date_anomaly                INTEGER NOT NULL DEFAULT 0,  -- 0/1 flag, see the data cleaning notebook
    FOREIGN KEY (customer_unique_id) REFERENCES customers (customer_unique_id)
);

-- -----------------------------------------------------------------------------
-- order_items: line-item fact table, composite primary key
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_id       TEXT    NOT NULL,
    order_item_id  INTEGER NOT NULL,
    product_id     TEXT    NOT NULL,
    price          REAL    NOT NULL,
    freight_value  REAL,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id)   REFERENCES orders (order_id),
    FOREIGN KEY (product_id) REFERENCES products (product_id)
);

-- -----------------------------------------------------------------------------
-- order_reviews: one row per order review (post-cleaning, one per order)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS order_reviews;
CREATE TABLE order_reviews (
    review_id             TEXT PRIMARY KEY,
    order_id              TEXT NOT NULL,
    review_score          INTEGER NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    review_creation_date  TEXT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
);
