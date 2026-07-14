# Analysis Summary

This project analyzes ~98,700 historical orders from the Olist marketplace (Brazil, 2016–2018) using Python, SQL, and SQLite.

## Main areas of analysis

- monthly sales and order trends
- customer activity and repeat purchases
- product category performance
- regional sales distribution
- delivery speed and late deliveries
- customer review scores

## Key results

- **Sales:** Total revenue of R$13.6M across 98,666 orders, for an average order value of R$137.75. See `visuals/01_monthly_revenue_trend.png` for the month-by-month trend.
- **Customers:** 95,420 unique customers, with a repeat-purchase rate of only 3.05% — the large majority of customers place a single order, which is typical for this kind of marketplace dataset.
- **Categories:** The highest-revenue product categories are detailed in `visuals/08_revenue_by_category.png` and `visuals/09_top_products_by_revenue.png`.
- **Delivery:** Average delivery time is 12.56 days, with 8.11% of orders arriving after their estimated delivery date.
- **Reviews:** Average review score is 4.09 / 5. Late deliveries are associated with lower review scores — see `visuals/17_review_score_by_delivery_outcome.png`.

Full figures, all 17 charts, and section-by-section commentary are in `reports/eda_report.md` and `notebooks/04_python_eda.ipynb`.

## Important limitation

The dataset contains order values but does not contain product costs. Therefore, the project reports revenue and order value, not profit or margin.

## Conclusion

The project demonstrates a complete junior-level analytics workflow: preparing raw data, creating a relational database, writing SQL queries, exploring results in Python, and communicating findings clearly.
