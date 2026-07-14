# SQL Analysis Report — E-Commerce Marketplace Analytics

This report is generated programmatically from `03_sql_analysis.ipynb`'s own query results, run against `database/ecommerce.db`. Every figure below reflects the actual database at the time this notebook was executed.

## Overview

20 business queries (6 basic, 8 intermediate, 6 advanced junior), 5 dedicated window function demonstrations, 5 reusable CTEs, and 4 persistent views were executed against database/ecommerce.db.

## Business Questions Answered

### Basic

**B1: Total revenue and total orders**

|   total_revenue |   total_orders |
|----------------:|---------------:|
|     1.35916e+07 |          98666 |


**B2: Average order value**

|   average_order_value |
|----------------------:|
|                137.75 |


**B3: Unique customers**

|   unique_customers |
|-------------------:|
|              96096 |


**B4: Top 10 products by revenue**

| product_id                       |   total_revenue |
|:---------------------------------|----------------:|
| bb50f2e236e5eea0100680137654686c |         63885   |
| 6cdd53843498f92890544667809f1595 |         54730.2 |
| d6160fb7873f184099d9bc95e30376af |         48899.3 |
| d1c427060a0f73f6b889a5c7c61f2ac4 |         47214.5 |
| 99a4788cb24856965c36a24e339b6058 |         43025.6 |
| 3dd2a17168ec895c781a9191c1e95ad7 |         41082.6 |
| 25c38557cf793876c5abdd5931f922db |         38907.3 |
| 5f504b3a1c75b73d6151be81eb05bdc9 |         37733.9 |
| 53b36df67ebb7c41585e8d54d6772e08 |         37683.4 |
| aca2eb7d00ea1a7b8ebd4e68314663af |         37608.9 |


**B5: Order status distribution**

| order_status   |   order_count |   pct_of_orders |
|:---------------|--------------:|----------------:|
| delivered      |         96478 |           97.02 |
| shipped        |          1107 |            1.11 |
| canceled       |           625 |            0.63 |
| unavailable    |           609 |            0.61 |
| invoiced       |           314 |            0.32 |
| processing     |           301 |            0.3  |
| created        |             5 |            0.01 |
| approved       |             2 |            0    |


**B6: Average review score**

|   average_review_score |
|-----------------------:|
|                   4.09 |


### Intermediate

**I1: Revenue by category**

| category              |    total_revenue |
|:----------------------|-----------------:|
| health_beauty         |      1.25868e+06 |
| watches_gifts         |      1.20501e+06 |
| bed_bath_table        |      1.03699e+06 |
| sports_leisure        | 988049           |
| computers_accessories | 911954           |
| furniture_decor       | 729762           |
| cool_stuff            | 635291           |
| housewares            | 632249           |
| auto                  | 592720           |
| garden_tools          | 485256           |


**I2: Revenue by state**

| customer_state   |    total_revenue |
|:-----------------|-----------------:|
| SP               |      5.20452e+06 |
| RJ               |      1.82319e+06 |
| MG               |      1.58532e+06 |
| RS               | 750524           |
| PR               | 683547           |
| SC               | 519618           |
| BA               | 511303           |
| DF               | 302003           |
| GO               | 295477           |
| ES               | 274927           |


**I3: Monthly revenue and order trend**

| order_month   |   monthly_revenue |   monthly_orders |
|:--------------|------------------:|-----------------:|
| 2016-09       |            267.36 |                3 |
| 2016-10       |          49507.7  |              308 |
| 2016-12       |             10.9  |                1 |
| 2017-01       |         120313    |              789 |
| 2017-02       |         247303    |             1733 |
| 2017-03       |         374344    |             2641 |
| 2017-04       |         359927    |             2391 |
| 2017-05       |         506071    |             3660 |
| 2017-06       |         433039    |             3217 |
| 2017-07       |         498031    |             3969 |


**I4: Repeat customer rate**

|   total_customers |   repeat_customers |   repeat_customer_rate_pct |
|------------------:|-------------------:|---------------------------:|
|             96096 |               2997 |                       3.12 |


**I5: Average delivery time**

|   average_delivery_days |
|------------------------:|
|                   12.56 |


**I6: Late delivery rate**

|   total_delivered |   late_deliveries |   late_delivery_rate_pct |
|------------------:|------------------:|-------------------------:|
|             96470 |              7826 |                     8.11 |


**I7: Orders by weekday**

| weekday   |   order_count |
|:----------|--------------:|
| Sunday    |         11960 |
| Monday    |         16196 |
| Tuesday   |         15963 |
| Wednesday |         15552 |
| Thursday  |         14761 |
| Friday    |         14122 |
| Saturday  |         10887 |


**I8: Review score by delivery outcome**

| delivery_outcome   |   average_review_score |   n_orders |
|:-------------------|-----------------------:|-----------:|
| late               |                   2.56 |       7618 |
| on_time            |                   4.3  |      87701 |


### Advanced Junior

**A1: Top product per category (ROW_NUMBER)**

| category              | top_product                      |   product_revenue |
|:----------------------|:---------------------------------|------------------:|
| health_beauty         | bb50f2e236e5eea0100680137654686c |           63885   |
| computers             | d6160fb7873f184099d9bc95e30376af |           48899.3 |
| computers_accessories | d1c427060a0f73f6b889a5c7c61f2ac4 |           47214.5 |
| bed_bath_table        | 99a4788cb24856965c36a24e339b6058 |           43025.6 |
| baby                  | 25c38557cf793876c5abdd5931f922db |           38907.3 |
| cool_stuff            | 5f504b3a1c75b73d6151be81eb05bdc9 |           37733.9 |
| watches_gifts         | 53b36df67ebb7c41585e8d54d6772e08 |           37683.4 |
| furniture_decor       | aca2eb7d00ea1a7b8ebd4e68314663af |           37608.9 |
| garden_tools          | 422879e10f46682990de24d770e7f83d |           26577.2 |
| musical_instruments   | 16c4e87b98a9370a9cbc3a4658a3f45b |           25034   |


**A2: State revenue ranking (RANK)**

| customer_state   |    total_revenue |   revenue_rank |
|:-----------------|-----------------:|---------------:|
| SP               |      5.20452e+06 |              1 |
| RJ               |      1.82319e+06 |              2 |
| MG               |      1.58532e+06 |              3 |
| RS               | 750524           |              4 |
| PR               | 683547           |              5 |
| SC               | 519618           |              6 |
| BA               | 511303           |              7 |
| DF               | 302003           |              8 |
| GO               | 295477           |              9 |
| ES               | 274927           |             10 |


**A3: Running monthly revenue total (SUM OVER)**

| order_month   |   monthly_revenue |   running_total_revenue |
|:--------------|------------------:|------------------------:|
| 2016-09       |            267.36 |           267.36        |
| 2016-10       |          49507.7  |         49775           |
| 2016-12       |             10.9  |         49785.9         |
| 2017-01       |         120313    |        170099           |
| 2017-02       |         247303    |        417402           |
| 2017-03       |         374344    |        791746           |
| 2017-04       |         359927    |             1.15167e+06 |
| 2017-05       |         506071    |             1.65774e+06 |
| 2017-06       |         433039    |             2.09078e+06 |
| 2017-07       |         498031    |             2.58881e+06 |


**A4: Month-over-month revenue growth (LAG)**

| order_month   |   monthly_revenue |   prior_month_revenue |   revenue_growth_pct |
|:--------------|------------------:|----------------------:|---------------------:|
| 2016-09       |            267.36 |                nan    |        nan           |
| 2016-10       |          49507.7  |                267.36 |      18417.2         |
| 2016-12       |             10.9  |              49507.7  |        -99.98        |
| 2017-01       |         120313    |                 10.9  |          1.10369e+06 |
| 2017-02       |         247303    |             120313    |        105.55        |
| 2017-03       |         374344    |             247303    |         51.37        |
| 2017-04       |         359927    |             374344    |         -3.85        |
| 2017-05       |         506071    |             359927    |         40.6         |
| 2017-06       |         433039    |             506071    |        -14.43        |
| 2017-07       |         498031    |             433039    |         15.01        |


**A5: Above-average-revenue customers**

| customer_unique_id               |   total_revenue |
|:---------------------------------|----------------:|
| 0a0a92112bd4c708ca5fde585afaa872 |         13440   |
| da122df9eeddfedc1dc1f5349a1a690c |          7388   |
| 763c8b1c9c68a0229c42c9fc6f662b93 |          7160   |
| dc4802a71eae9be1dd28f5d788ceb526 |          6735   |
| 459bef486812aa25204be022145caa62 |          6729   |
| ff4159b92c40ebe40454e3e6a7c35ed6 |          6499   |
| 4007669dec559734d6f53e029e360987 |          5934.6 |
| eebb5dda148d3893cdaf5b5ca3040ccb |          4690   |
| 5d0a2980b292d049061542014e8960bf |          4599.9 |
| 48e1ac109decbb87765a3eade6854098 |          4590   |


**A6: Top category per state (DENSE_RANK)**

| customer_state   | top_category   |   category_revenue |
|:-----------------|:---------------|-------------------:|
| SP               | bed_bath_table |           478669   |
| RJ               | watches_gifts  |           185380   |
| MG               | health_beauty  |           157625   |
| RS               | bed_bath_table |            60270.7 |
| PR               | watches_gifts  |            59967   |
| BA               | health_beauty  |            51367.9 |
| SC               | sports_leisure |            44116.9 |
| PE               | health_beauty  |            41604.8 |
| GO               | watches_gifts  |            34108.7 |
| CE               | health_beauty  |            32419.2 |


## SQL Techniques Used

- Basic: SELECT, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT, COUNT, SUM, AVG
- Intermediate: INNER JOIN, LEFT JOIN, CASE WHEN, date aggregation (STRFTIME), subqueries, multiple joins
- Advanced: CTEs, ROW_NUMBER(), RANK(), DENSE_RANK(), LAG(), SUM() OVER(), running totals, month-over-month growth, top-N-per-group patterns
- Views: 4 persistent views wrapping the most frequently reused aggregations

## Key Findings

Findings are summarized qualitatively here since specific figures are already shown in full above and will vary with the real dataset. Review the Basic and Intermediate sections above for exact revenue, order, delivery, and review-score figures, and the Advanced section for ranking and trend results.

## Database Coverage

All 6 core tables (`categories`, `customers`, `products`, `orders`, `order_items`, `order_reviews`) are used across this query set. The `sellers`, `order_payments`, and `geolocation` tables remain unused, consistent with the project's original scope decision.

## Limitations

- Two specification business questions (seller count and seller revenue concentration) are not implemented, since the `sellers` table was not loaded into the core schema.
- No profit, margin, or discount analysis is possible (no such data exists in this dataset).
- Delivery and review analyses exclude rows flagged with `has_date_anomaly = 1` during data cleaning, to avoid a small number of logically inconsistent timestamps distorting delivery-time calculations.

## Preparation for Python Analysis

The four views created here (`vw_customer_summary`, `vw_delivery_performance`, `vw_monthly_sales`, `vw_category_summary`) are designed to be queried directly from `04_python_eda.ipynb` via pandas' `read_sql_query`, avoiding the need to re-derive the same joins in Python.
