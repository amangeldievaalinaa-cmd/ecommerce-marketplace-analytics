# E-Commerce Marketplace Analytics

## Project Overview

This is a junior data analytics portfolio project based on the Brazilian E-Commerce Public Dataset by Olist.

The project demonstrates a complete beginner-friendly analytics workflow:

- data cleaning and validation with Python
- database creation with SQLite
- SQL analysis
- exploratory data analysis
- data visualization
- business insights
- interactive dashboard development with Streamlit

The main goal of the project is to analyze marketplace sales, customers, product categories, delivery performance, and customer reviews.

---

## Business Questions

The analysis answers the following questions:

- How did revenue and order volume change over time?
- Which product categories generated the most revenue?
- Which Brazilian states had the highest number of customers and orders?
- How often were orders delivered late?
- Is delivery performance related to customer review scores?
- How many customers placed repeat orders?
- Which products and categories performed best?
- What customer and delivery patterns can be identified?

---

## Tools and Technologies

- Python
- pandas
- NumPy
- matplotlib
- Plotly
- SQL
- SQLite
- Jupyter Notebook
- Streamlit
- Git and GitHub

---

## Dataset

The project uses the Brazilian E-Commerce Public Dataset by Olist.

The dataset contains anonymized information about marketplace orders placed in Brazil between 2016 and 2018.

Main datasets used:

- orders
- order items
- customers
- products
- product category translations
- order reviews

The original CSV files are not included in this repository because of their size. They can be downloaded from Kaggle and placed in:

```text
data/raw/
```

The repository includes the prepared SQLite database used by the Streamlit dashboard:

```text
database/ecommerce.db
```

This allows the dashboard to run without rebuilding the database first.

---

## Project Structure

```text
ecommerce-marketplace-analytics/
├── dashboard/
│   └── app.py
├── data/
│   ├── raw/
│   └── processed/
├── database/
│   └── ecommerce.db
├── notebooks/
│   ├── 01_data_cleaning.ipynb
│   ├── 02_sqlite_database_setup.ipynb
│   ├── 03_sql_analysis.ipynb
│   └── 04_python_eda.ipynb
├── reports/
│   ├── analysis_summary.md
│   ├── data_quality_report.md
│   ├── database_validation_report.md
│   ├── eda_report.md
│   └── sql_analysis_report.md
├── sql/
│   ├── 00_create_schema.sql
│   ├── 00_load_data.sql
│   ├── 00_validation.sql
│   ├── 01_business_queries.sql
│   ├── 02_window_functions.sql
│   ├── 03_cte_queries.sql
│   └── 04_views.sql
├── visuals/
├── README.md
├── requirements.txt
└── LICENSE
```

---

## Analysis Workflow

The project follows these main steps:

1. Load and inspect the raw CSV files.
2. Clean missing values and duplicate records.
3. Convert date columns into the correct format.
4. Validate relationships between tables.
5. Save cleaned datasets.
6. Create a SQLite database.
7. Run SQL business queries.
8. Perform exploratory data analysis in Python.
9. Create and save visualizations.
10. Build an interactive Streamlit dashboard.
11. Summarize the main findings in reports.

---

## SQL Skills Demonstrated

The SQL part of the project includes:

- SELECT
- WHERE
- GROUP BY
- HAVING
- ORDER BY
- inner and left joins
- aggregations
- CASE WHEN
- common table expressions
- window functions
- ROW_NUMBER
- RANK
- LAG
- running totals
- reusable SQL views

---

## Python Skills Demonstrated

The Python notebooks demonstrate:

- loading CSV files with pandas
- inspecting datasets
- cleaning missing values
- removing duplicates
- working with date and time columns
- merging DataFrames
- grouping and aggregating data
- calculating business metrics
- creating visualizations
- exporting processed data and reports

---

## Key Analysis Areas

The project focuses on five main areas:

**Sales**
- monthly revenue
- monthly order volume
- average order value
- revenue trends

**Customers**
- unique customers
- repeat customers
- customer revenue distribution
- customer segmentation

**Products and Categories**
- top categories by revenue
- top products by revenue
- product performance comparisons

**Geography**
- revenue by state
- orders by state
- delivery time by state

**Delivery and Reviews**
- delivery time distribution
- late delivery rate
- review score distribution
- relationship between delivery performance and review scores

---

## Interactive Dashboard

The project includes a Streamlit dashboard located at:

```text
dashboard/app.py
```

The dashboard uses:

```text
database/ecommerce.db
```

It includes interactive filters for:

- month
- customer state
- product category

The dashboard displays:

- revenue
- number of orders
- average order value
- unique customers
- sales trends
- customer analysis
- category performance
- regional performance
- delivery metrics
- review metrics

---

## How to Run the Project

**1. Clone the repository**

```bash
git clone https://github.com/amangeldievaalinaa-cmd/ecommerce-marketplace-analytics.git
```

**2. Open the project folder**

```bash
cd ecommerce-marketplace-analytics
```

**3. Create a virtual environment**

```bash
python3 -m venv .venv
```

**4. Activate the virtual environment**

macOS or Linux:

```bash
source .venv/bin/activate
```

Windows:

```bash
.venv\Scripts\activate
```

**5. Install the required libraries**

```bash
pip install -r requirements.txt
```

---

## Run the Streamlit Dashboard

Because the prepared SQLite database is included in the repository, the dashboard can be started directly:

```bash
streamlit run dashboard/app.py
```

The application will normally open at:

```text
http://localhost:8501
```

For better package compatibility, Python 3.11 or Python 3.12 is recommended.

---

## Run the Full Analytics Pipeline

To rebuild the project from the original CSV files:

1. Download the Olist dataset.
2. Place the required files in:

```text
data/raw/
```

3. Start Jupyter Notebook:

```bash
jupyter notebook
```

4. Run the notebooks in this order:

```text
01_data_cleaning.ipynb
02_sqlite_database_setup.ipynb
03_sql_analysis.ipynb
04_python_eda.ipynb
```

The notebooks create:

- cleaned datasets
- the SQLite database
- SQL analysis results
- visualizations
- analysis reports

---

## Visualizations

The project includes charts covering:

- monthly revenue trends
- monthly order trends
- order value distribution
- customer revenue distribution
- repeat and one-time customers
- revenue by category
- top products
- revenue and orders by state
- delivery time
- late delivery rate
- review score distribution
- review scores by delivery outcome

The generated charts are stored in:

```text
visuals/
```

---

## Limitations

- The dataset covers historical marketplace activity from 2016 to 2018.
- Product cost data is not available, so the project analyzes revenue rather than profit.
- The project does not include causal analysis.
- Seller, payment, and geolocation datasets are outside the main project scope.
- The results describe one marketplace and should not be generalized to all e-commerce businesses.

---

## Possible Improvements

Future improvements may include:

- seller performance analysis
- payment method analysis
- geographic maps
- customer cohort analysis
- RFM customer segmentation
- Power BI or Looker Studio dashboard
- Streamlit Community Cloud deployment
- automated data pipeline
- additional delivery and review analysis

---

## Author

**Alina Amangeldiyeva**

Junior Data Analyst portfolio project.

GitHub: [amangeldievaalinaa-cmd](https://github.com/amangeldievaalinaa-cmd)
