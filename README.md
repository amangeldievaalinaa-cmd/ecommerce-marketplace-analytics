# E-Commerce Marketplace Analysis

## About the project

This is a junior data analytics portfolio project based on the Brazilian E-Commerce Public Dataset by Olist. The goal is to practice the full basic analytics workflow: cleaning data in Python, storing it in SQLite, writing SQL queries, creating visualizations, and summarizing business findings.

## Questions explored

- How did sales and order volume change over time?
- Which product categories generated the most revenue?
- Which states had the most customers and orders?
- How often were orders delivered late?
- Is delivery performance related to customer review scores?
- How many customers placed repeat orders?

## Tools

- Python: pandas, NumPy, matplotlib
- SQL and SQLite
- Jupyter Notebook
- Streamlit and Plotly (interactive dashboard)
- Git and GitHub

## Dataset

The project uses the public Olist e-commerce dataset from Kaggle. It contains anonymized information about orders placed in Brazil between 2016 and 2018.

Main tables used:

- orders
- order items
- customers
- products
- product category translations
- order reviews

The raw CSV files are not included in the repository because of their size. Download the dataset from Kaggle and place the required files in `data/raw/`.

## Interactive Dashboard

A Streamlit dashboard (`dashboard/app.py`) sits on top of `database/ecommerce.db` and lets you filter by month, state, and category, with live-updating KPIs and charts for sales, customers, categories/regions, and delivery/reviews.

Run it locally (after building the database via the notebooks below):

```bash
streamlit run dashboard/app.py
```

It opens at `http://localhost:8501`. To share it publicly, push this repo to GitHub and deploy it for free on [Streamlit Community Cloud](https://streamlit.io/cloud), pointing it at `dashboard/app.py`.

## Project structure

```text
ecommerce-marketplace-analytics/
├── dashboard/
│   └── app.py                # Streamlit dashboard
├── data/
│   ├── raw/                 # Original CSV files
│   └── processed/           # Cleaned CSV files
├── database/                # SQLite database created by the project
├── notebooks/
│   ├── 01_data_cleaning.ipynb
│   ├── 02_sqlite_database_setup.ipynb
│   ├── 03_sql_analysis.ipynb
│   └── 04_python_eda.ipynb
├── sql/                     # SQL schema and analysis queries
├── visuals/                 # Charts created by the EDA notebook
├── reports/                 # Generated analysis reports
├── README.md
└── requirements.txt
```

## Analysis workflow

1. Clean and validate the raw data with pandas.
2. Save the cleaned tables to `data/processed/`.
3. Create a SQLite database.
4. Run SQL queries using joins, aggregations, CTEs, and window functions.
5. Explore sales, customers, categories, delivery, and reviews in Python.
6. Save charts and summarize the main findings.

## SQL skills demonstrated

- `SELECT`, `WHERE`, `GROUP BY`, and `HAVING`
- joins between several tables
- `CASE WHEN`
- common table expressions
- window functions such as `ROW_NUMBER`, `RANK`, `LAG`, and running totals
- reusable SQL views

## Python skills demonstrated

- loading and inspecting CSV files
- handling missing values and duplicates
- working with dates
- merging DataFrames
- calculating business metrics
- grouping and aggregating data
- creating charts with matplotlib

## How to run

```bash
git clone <repository-url>
cd ecommerce-marketplace-analytics
python -m venv venv
```

Activate the environment:

```bash
# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

Install the libraries:

```bash
pip install -r requirements.txt
```

Then run the notebooks in order:

1. `01_data_cleaning.ipynb`
2. `02_sqlite_database_setup.ipynb`
3. `03_sql_analysis.ipynb`
4. `04_python_eda.ipynb`

## Limitations

- The dataset does not contain product cost or profit data, so the project analyzes revenue rather than profit.
- The data covers one marketplace and a historical period from 2016 to 2018.
- Seller, payment, and geolocation tables were not included in the main analysis.
- The analysis describes relationships in the data and does not prove causation.

## Possible improvements

- Add seller and payment analysis.
- Create an interactive dashboard in Power BI or Looker Studio.
- Add a map of orders by location.
- Compare delivery performance across sellers.
