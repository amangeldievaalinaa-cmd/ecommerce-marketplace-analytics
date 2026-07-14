# Data Quality Report — E-Commerce Marketplace Analytics

This report documents the data quality findings and cleaning decisions made in `01_data_cleaning.ipynb`. It is generated programmatically from the notebook's own validation checks so that it always reflects the actual data, not a hand-written estimate.

## Overall Dataset Summary

| dataset              |   rows |   columns |   memory_mb |   duplicate_rows |   total_missing_cells |
|:---------------------|-------:|----------:|------------:|-----------------:|----------------------:|
| orders               |  99441 |         8 |      52.937 |                0 |                  4908 |
| order_items          | 112650 |         7 |      35.99  |                0 |                     0 |
| customers            |  99441 |         5 |      26.586 |                0 |                     0 |
| products             |  32951 |         9 |       6.297 |                0 |                  2448 |
| category_translation |     71 |         2 |       0.009 |                0 |                     0 |
| reviews              |  99224 |         7 |      39.125 |                0 |                145903 |


## Missing Values

| dataset   | column                        |   missing_count |   missing_pct |
|:----------|:------------------------------|----------------:|--------------:|
| orders    | order_delivered_customer_date |            2965 |          2.98 |
| orders    | order_delivered_carrier_date  |            1783 |          1.79 |
| orders    | order_approved_at             |             160 |          0.16 |
| products  | product_category_name         |             610 |          1.85 |
| products  | product_name_lenght           |             610 |          1.85 |
| products  | product_description_lenght    |             610 |          1.85 |
| products  | product_photos_qty            |             610 |          1.85 |
| products  | product_weight_g              |               2 |          0.01 |
| products  | product_length_cm             |               2 |          0.01 |
| products  | product_height_cm             |               2 |          0.01 |
| products  | product_width_cm              |               2 |          0.01 |
| reviews   | review_comment_title          |           87656 |         88.34 |
| reviews   | review_comment_message        |           58247 |         58.7  |


## Primary Key Uniqueness

| dataset   | key_columns   |   total_rows |   unique_key_rows |   duplicate_key_rows | is_unique   |
|:----------|:--------------|-------------:|------------------:|---------------------:|:------------|
| orders    | order_id      |        99441 |             99441 |                    0 | True        |
| customers | customer_id   |        99441 |             99441 |                    0 | True        |
| products  | product_id    |        32951 |             32951 |                    0 | True        |
| reviews   | review_id     |        99224 |             98410 |                  814 | False       |


## Foreign Key Validation

| relationship                                  |   total_child_rows |   orphan_rows |   orphan_pct | sample_orphan_values   |
|:----------------------------------------------|-------------------:|--------------:|-------------:|:-----------------------|
| order_items.order_id -> orders.order_id       |             112650 |             0 |            0 | []                     |
| order_items.product_id -> products.product_id |             112650 |             0 |            0 | []                     |
| orders.customer_id -> customers.customer_id   |              99441 |             0 |            0 | []                     |
| reviews.order_id -> orders.order_id           |              99224 |             0 |            0 | []                     |


## Category Translation Coverage

- Total distinct categories: 73
- Translated: 71
- Untranslated: 2
- Untranslated category names: ['pc_gamer', 'portateis_cozinha_e_preparadores_de_alimentos']

## Exact Duplicate Rows (pre-cleaning)

| dataset              |   exact_duplicate_rows |
|:---------------------|-----------------------:|
| orders               |                      0 |
| order_items          |                      0 |
| customers            |                      0 |
| products             |                      0 |
| category_translation |                      0 |
| reviews              |                      0 |


## Logical Date Ordering Issues

No orders had a delivered date earlier than their purchase date.

## Review Cardinality Issues

547 order(s) had more than one review. The most recent review per order was kept in the cleaned data; earlier duplicates were removed.

## Cleaning Actions Summary

| dataset       | issues_found                                                                                       | cleaning_performed                                                                                                          | rows_removed         | remaining_issues                                                                                        |
|:--------------|:---------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------|:---------------------|:--------------------------------------------------------------------------------------------------------|
| orders        | Exact duplicate row(s); unparseable timestamp(s); logical date anomaly (delivered before purchase) | Removed exact duplicates; coerced unparseable timestamps to null; flagged (not removed) date anomalies via has_date_anomaly | see Section 6 output | Any row with has_date_anomaly=True should be excluded from delivery-time KPIs but kept for revenue KPIs |
| customers     | Duplicate customer_unique_id across multiple customer_id rows; inconsistent city name casing       | Deduplicated on customer_unique_id (kept first); standardized city to lowercase/stripped                                    | see Section 7 output | Any remaining null customer_city values are left as-is (documented, not imputed)                        |
| order_items   | Row(s) referencing a product_id absent from products (orphan foreign key)                          | Excluded orphaned rows from the analysis-ready export; logged the excluded order_id/product_id pairs                        | see Section 9 output | None known                                                                                              |
| products      | Untranslated categories; missing product_weight_g values                                           | Preserved untranslated categories with a null English name; left missing weight values as null (not imputed)                | 0                    | Categories with no English translation remain null by design                                            |
| categories    | N/A (derived table)                                                                                | Built from product_category_name_translation plus any untranslated categories found in products                             | 0                    | Categories with null English name are documented above                                                  |
| order_reviews | Order(s) with more than one review (cardinality violation)                                         | Kept the most recent review per order; removed earlier duplicates                                                           | see Section 9 output | None known                                                                                              |


## Known Limitations

- This dataset contains no cost, profit, margin, or discount data. No financial performance metric beyond revenue can be calculated from it.
- The `sellers`, `order_payments`, and `geolocation` files were not loaded into the core schema; they remain available in `data/raw/` for future optional extensions.
- Rows with unparseable timestamps were coerced to null rather than guessed at or dropped outright.

## Recommendations for the Next Notebook

- Build the SQLite schema exactly as defined in `sql/00_create_schema.sql`, using the six exported CSVs in `data/processed/` as the source for each table.
- Enforce foreign key constraints at the database level where possible, and re-run the foreign key checks above against the loaded database as a final confirmation.
- Treat `has_date_anomaly = True` rows as excluded from delivery-time KPIs but included in revenue KPIs in later SQL and Python analysis.
