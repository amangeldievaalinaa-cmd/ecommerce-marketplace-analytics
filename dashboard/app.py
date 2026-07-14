"""
E-Commerce Marketplace Analytics — Interactive Dashboard
==========================================================
Streamlit dashboard on top of the SQLite database built by
`notebooks/02_sqlite_database_setup.ipynb`.

Run locally:
    streamlit run dashboard/app.py

The app expects `database/ecommerce.db` to exist one level up from this
file. Build it by running the notebooks in `notebooks/` in order (01 -> 04),
or download the pre-built database if you saved a copy.
"""

from pathlib import Path
import sqlite3

import pandas as pd
import plotly.express as px
import streamlit as st

# --------------------------------------------------------------------------
# Page config
# --------------------------------------------------------------------------
st.set_page_config(
    page_title="E-Commerce Marketplace Analytics",
    page_icon="📦",
    layout="wide",
)

DB_PATH = Path(__file__).resolve().parent.parent / "database" / "ecommerce.db"


# --------------------------------------------------------------------------
# Data loading (cached — the whole dataset is small enough to hold in memory)
# --------------------------------------------------------------------------
@st.cache_data(show_spinner="Loading data from database/ecommerce.db ...")
def load_data(db_path: str):
    if not Path(db_path).exists():
        return None, None

    conn = sqlite3.connect(db_path)

    orders = pd.read_sql_query(
        """
        SELECT
            o.order_id,
            o.customer_unique_id,
            c.customer_state,
            c.customer_city,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date,
            o.has_date_anomaly,
            r.review_score
        FROM orders o
        JOIN customers c ON o.customer_unique_id = c.customer_unique_id
        LEFT JOIN order_reviews r ON r.order_id = o.order_id
        """,
        conn,
    )

    items = pd.read_sql_query(
        """
        SELECT
            oi.order_id,
            oi.price,
            oi.freight_value,
            COALESCE(cat.category_name_english, cat.category_name_portuguese, 'unknown') AS category_name
        FROM order_items oi
        LEFT JOIN products p ON oi.product_id = p.product_id
        LEFT JOIN categories cat ON p.category_id = cat.category_id
        """,
        conn,
    )
    conn.close()

    # --- order-level table: one row per order ---
    order_revenue = items.groupby("order_id", as_index=False)["price"].sum()
    order_revenue.columns = ["order_id", "order_revenue"]
    orders = orders.merge(order_revenue, on="order_id", how="inner")  # drop orders with no items (canceled/unavailable)

    orders["order_purchase_timestamp"] = pd.to_datetime(orders["order_purchase_timestamp"])
    orders["order_delivered_customer_date"] = pd.to_datetime(orders["order_delivered_customer_date"])
    orders["order_estimated_delivery_date"] = pd.to_datetime(orders["order_estimated_delivery_date"])
    orders["order_month"] = orders["order_purchase_timestamp"].dt.to_period("M").astype(str)

    orders["delivery_days"] = (
        orders["order_delivered_customer_date"] - orders["order_purchase_timestamp"]
    ).dt.days
    orders["is_late"] = (
        orders["order_delivered_customer_date"] > orders["order_estimated_delivery_date"]
    ).astype("boolean")
    # Match the cleaning notebook's methodology: delivery-time KPIs exclude orders
    # with no delivery date yet and rows flagged as logical-date anomalies during
    # cleaning (see reports/data_quality_report.md). Revenue KPIs are unaffected.
    undelivered_or_anomalous = (
        orders["order_delivered_customer_date"].isna() | (orders["has_date_anomaly"] == 1)
    )
    orders.loc[undelivered_or_anomalous, "delivery_days"] = pd.NA
    orders.loc[undelivered_or_anomalous, "is_late"] = pd.NA

    # --- item-level table: carries order_month / state / order_revenue for filtering ---
    items = items.merge(
        orders[["order_id", "order_month", "customer_state"]], on="order_id", how="left"
    )

    return orders, items


orders_df, items_df = load_data(str(DB_PATH))

if orders_df is None:
    st.error(
        "Couldn't find `database/ecommerce.db`. Run the notebooks in `notebooks/` "
        "(01 through 04) first to build the database, then restart this app."
    )
    st.stop()


# --------------------------------------------------------------------------
# Sidebar filters
# --------------------------------------------------------------------------
st.sidebar.header("Filters")

months = sorted(orders_df["order_month"].dropna().unique())
month_range = st.sidebar.select_slider(
    "Order month range",
    options=months,
    value=(months[0], months[-1]),
)

states = sorted(orders_df["customer_state"].dropna().unique())
selected_states = st.sidebar.multiselect("Customer state", options=states, default=[])

categories = sorted(items_df["category_name"].dropna().unique())
selected_categories = st.sidebar.multiselect("Product category", options=categories, default=[])

st.sidebar.caption(
    "Leave state / category empty to include all. Data covers "
    f"{months[0]} through {months[-1]}."
)

# --------------------------------------------------------------------------
# Apply filters
# --------------------------------------------------------------------------
o = orders_df[
    (orders_df["order_month"] >= month_range[0]) & (orders_df["order_month"] <= month_range[1])
].copy()
if selected_states:
    o = o[o["customer_state"].isin(selected_states)]

i = items_df[
    (items_df["order_month"] >= month_range[0]) & (items_df["order_month"] <= month_range[1])
].copy()
if selected_states:
    i = i[i["customer_state"].isin(selected_states)]
if selected_categories:
    i = i[i["category_name"].isin(selected_categories)]
    # keep only orders that still have at least one matching item
    o = o[o["order_id"].isin(i["order_id"])]

# --------------------------------------------------------------------------
# Header + KPIs
# --------------------------------------------------------------------------
st.title("📦 E-Commerce Marketplace Analytics")
st.caption(
    "Brazilian E-Commerce Public Dataset (Olist), 2016–2018 — "
    "interactive companion to the notebooks in this repository."
)

total_revenue = o["order_revenue"].sum()
total_orders = o["order_id"].nunique()
unique_customers = o["customer_unique_id"].nunique()
aov = total_revenue / total_orders if total_orders else 0
repeat_rate = (
    (o.groupby("customer_unique_id")["order_id"].nunique() > 1).mean() * 100
    if unique_customers
    else 0
)
avg_delivery_days = o["delivery_days"].mean()
late_rate = o["is_late"].mean() * 100 if len(o) else 0
avg_review = o["review_score"].mean()

k1, k2, k3, k4 = st.columns(4)
k1.metric("Total Revenue", f"R${total_revenue:,.0f}")
k2.metric("Orders", f"{total_orders:,}")
k3.metric("Unique Customers", f"{unique_customers:,}")
k4.metric("Avg Order Value", f"R${aov:,.2f}")

k5, k6, k7, k8 = st.columns(4)
k5.metric("Repeat Customer Rate", f"{repeat_rate:.1f}%")
k6.metric("Avg Delivery Time", f"{avg_delivery_days:.1f} days" if pd.notna(avg_delivery_days) else "—")
k7.metric("Late Delivery Rate", f"{late_rate:.1f}%")
k8.metric("Avg Review Score", f"{avg_review:.2f} / 5" if pd.notna(avg_review) else "—")

st.divider()

# --------------------------------------------------------------------------
# Tabs
# --------------------------------------------------------------------------
tab_sales, tab_customers, tab_categories, tab_delivery = st.tabs(
    ["📈 Sales", "👥 Customers", "🏷️ Categories & Regions", "🚚 Delivery & Reviews"]
)

with tab_sales:
    monthly = (
        o.groupby("order_month")
        .agg(revenue=("order_revenue", "sum"), orders=("order_id", "nunique"))
        .reset_index()
        .sort_values("order_month")
    )
    c1, c2 = st.columns(2)
    with c1:
        fig = px.line(monthly, x="order_month", y="revenue", markers=True, title="Monthly Revenue")
        fig.update_layout(xaxis_title="Month", yaxis_title="Revenue (R$)")
        st.plotly_chart(fig, use_container_width=True)
    with c2:
        fig = px.bar(monthly, x="order_month", y="orders", title="Monthly Order Volume")
        fig.update_layout(xaxis_title="Month", yaxis_title="Orders")
        st.plotly_chart(fig, use_container_width=True)

    fig = px.histogram(
        o.dropna(subset=["order_revenue"]),
        x="order_revenue",
        nbins=60,
        title="Order Value Distribution",
        range_x=[0, o["order_revenue"].quantile(0.99)],
    )
    fig.update_layout(xaxis_title="Order value (R$)", yaxis_title="Number of orders")
    st.plotly_chart(fig, use_container_width=True)

with tab_customers:
    cust = (
        o.groupby("customer_unique_id")
        .agg(orders=("order_id", "nunique"), revenue=("order_revenue", "sum"))
        .reset_index()
        .sort_values("revenue", ascending=False)
    )
    cust["segment"] = cust["orders"].apply(lambda n: "Repeat" if n > 1 else "One-time")

    c1, c2 = st.columns(2)
    with c1:
        seg_counts = cust["segment"].value_counts().reset_index()
        seg_counts.columns = ["segment", "customers"]
        fig = px.pie(seg_counts, names="segment", values="customers", title="Repeat vs One-Time Customers")
        st.plotly_chart(fig, use_container_width=True)
    with c2:
        fig = px.histogram(
            cust,
            x="revenue",
            nbins=60,
            title="Customer Revenue Distribution",
            range_x=[0, cust["revenue"].quantile(0.99)],
        )
        fig.update_layout(xaxis_title="Revenue per customer (R$)", yaxis_title="Number of customers")
        st.plotly_chart(fig, use_container_width=True)

    st.subheader("Top 20 Customers by Revenue")
    st.dataframe(
        cust.head(20).rename(
            columns={"customer_unique_id": "Customer", "orders": "Orders", "revenue": "Revenue (R$)", "segment": "Segment"}
        ),
        use_container_width=True,
        hide_index=True,
    )

with tab_categories:
    cat_rev = (
        i.groupby("category_name")["price"].sum().reset_index().sort_values("price", ascending=False).head(15)
    )
    fig = px.bar(
        cat_rev, x="price", y="category_name", orientation="h", title="Top 15 Categories by Revenue"
    )
    fig.update_layout(xaxis_title="Revenue (R$)", yaxis_title="", yaxis={"categoryorder": "total ascending"})
    st.plotly_chart(fig, use_container_width=True)

    c1, c2 = st.columns(2)
    with c1:
        state_rev = o.groupby("customer_state")["order_revenue"].sum().reset_index().sort_values(
            "order_revenue", ascending=False
        )
        fig = px.bar(state_rev, x="customer_state", y="order_revenue", title="Revenue by State")
        fig.update_layout(xaxis_title="State", yaxis_title="Revenue (R$)")
        st.plotly_chart(fig, use_container_width=True)
    with c2:
        state_orders = o.groupby("customer_state")["order_id"].nunique().reset_index().sort_values(
            "order_id", ascending=False
        )
        fig = px.bar(state_orders, x="customer_state", y="order_id", title="Orders by State")
        fig.update_layout(xaxis_title="State", yaxis_title="Orders")
        st.plotly_chart(fig, use_container_width=True)

with tab_delivery:
    c1, c2 = st.columns(2)
    with c1:
        fig = px.histogram(
            o.dropna(subset=["delivery_days"]),
            x="delivery_days",
            nbins=40,
            title="Delivery Time Distribution (days)",
            range_x=[0, o["delivery_days"].quantile(0.99)],
        )
        fig.update_layout(xaxis_title="Delivery time (days)", yaxis_title="Number of orders")
        st.plotly_chart(fig, use_container_width=True)
    with c2:
        fig = px.histogram(
            o.dropna(subset=["review_score"]),
            x="review_score",
            nbins=5,
            title="Review Score Distribution",
        )
        fig.update_layout(xaxis_title="Review score", yaxis_title="Number of orders")
        st.plotly_chart(fig, use_container_width=True)

    review_vs_delivery = (
        o.dropna(subset=["review_score"])
        .assign(delivery_outcome=lambda d: d["is_late"].map({True: "Late", False: "On time"}))
        .groupby("delivery_outcome")["review_score"]
        .mean()
        .reset_index()
    )
    fig = px.bar(
        review_vs_delivery,
        x="delivery_outcome",
        y="review_score",
        title="Average Review Score: Late vs On-Time Delivery",
        range_y=[0, 5],
    )
    fig.update_layout(xaxis_title="", yaxis_title="Average review score")
    st.plotly_chart(fig, use_container_width=True)

st.divider()
st.caption(
    "Data: Brazilian E-Commerce Public Dataset by Olist (CC BY-NC-SA 4.0), via Kaggle. "
    "No profit/margin data exists in this dataset — figures shown are revenue, not profit."
)
