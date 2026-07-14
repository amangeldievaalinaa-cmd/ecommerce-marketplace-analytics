# Database Validation Report — E-Commerce Marketplace Analytics

Database file: `database/ecommerce.db`. This report is generated programmatically from `02_sqlite_database_setup.ipynb`'s own validation results.

## Database Overview

- Tables created: categories, customers, order_items, order_reviews, orders, products

## Tables Created and Rows Imported

| table         |   rows_in_csv |   rows_in_database | match   |
|:--------------|--------------:|-------------------:|:--------|
| categories    |            73 |                 73 | True    |
| customers     |         96096 |              96096 | True    |
| products      |         32951 |              32951 | True    |
| orders        |         99441 |              99441 | True    |
| order_items   |        112650 |             112650 | True    |
| order_reviews |         98127 |              98127 | True    |


## Final Row Counts (post-load)

| table         |   row_count |
|:--------------|------------:|
| categories    |          73 |
| customers     |       96096 |
| products      |       32951 |
| orders        |       99441 |
| order_items   |      112650 |
| order_reviews |       98127 |


## Integrity Checks — Primary Keys

| table         | key_column         |   duplicate_key_rows | passed   |
|:--------------|:-------------------|---------------------:|:---------|
| customers     | customer_unique_id |                    0 | True     |
| orders        | order_id           |                    0 | True     |
| products      | product_id         |                    0 | True     |
| categories    | category_id        |                    0 | True     |
| order_reviews | review_id          |                    0 | True     |


## Integrity Checks — Foreign Keys

| relationship                                              |   orphan_rows | passed   |
|:----------------------------------------------------------|--------------:|:---------|
| orders.customer_unique_id -> customers.customer_unique_id |             0 | True     |
| order_items.order_id -> orders.order_id                   |             0 | True     |
| order_items.product_id -> products.product_id             |             0 | True     |
| products.category_id -> categories.category_id            |             0 | True     |
| order_reviews.order_id -> orders.order_id                 |             0 | True     |


## Integrity Checks — NOT NULL Constraints

| table         | column                        |   unexpected_nulls | passed   |
|:--------------|:------------------------------|-------------------:|:---------|
| orders        | customer_unique_id            |                  0 | True     |
| orders        | order_status                  |                  0 | True     |
| orders        | order_estimated_delivery_date |                  0 | True     |
| order_items   | order_id                      |                  0 | True     |
| order_items   | product_id                    |                  0 | True     |
| order_items   | price                         |                  0 | True     |
| order_reviews | order_id                      |                  0 | True     |
| order_reviews | review_score                  |                  0 | True     |
| order_reviews | review_creation_date          |                  0 | True     |


## Constraint Validation Summary

- Composite key violations in `order_items`: 0
- Orders with more than one review: 0
- Products with an untranslated category (informational, not an error): 13

## Known Limitations

- A small number of products map to a category with no English translation. This is inherited directly from the raw Olist data (documented in `reports/data_quality_report.md`) and is preserved here rather than papered over.
- SQLite enforces foreign keys only when `PRAGMA foreign_keys = ON` is set per connection; any future script or tool connecting to this database file must set this pragma itself to get real-time enforcement.
- No indexes beyond the primary/foreign key columns have been created yet — see Section 9 for planned (not yet implemented) index recommendations.

## Ready for SQL Analysis

All structural integrity checks passed (or, for the one informational category-mapping check, returned the expected known limitation). The database is ready to be queried in `03_sql_analysis.ipynb`.
