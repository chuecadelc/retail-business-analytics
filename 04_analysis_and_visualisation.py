

# ============================================================
# Script: Business Analytics Visualisations
# Project: MMR Retail Business Analytics Case Study
# Author: Dr. Cristina Chueca Del Cerro
# Date: March 2026
# Description: Imports SQL-exported CSV data and produces four 
#              visualisations analysing product sales trends,
#              bike revenue performance, and customer loyalty
#              patterns across six UK shop locations.
# Input:  CSV exports from MySQL (see sql/ folder)
# Output: Four JPEG figures saved to working directory
# ============================================================


# ============================================================
# 1. DEPENDENCIES
# ============================================================
# Note: squarify is not included in standard Anaconda/pip 
# installs — run: pip install squarify

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import squarify  # for treemap visualisation
import os


# ============================================================
# 2. WORKING DIRECTORY & DATA IMPORT
# ============================================================
# Update this path to match your local directory structure
# before running

#chage dir
import os
os.chdir("C:/Users/YOUR/DATA/PATH")

# Import CSV exports from MySQL query outputs
general_sales_df  = pd.read_csv('outputs/Sales_by_type.csv')
bike_sales_df     = pd.read_csv('outputs/Bike_sales.csv')
location_sales_df = pd.read_csv('outputs/Sales_by_location.csv')
loyalty_df        = pd.read_csv('outputs/Customer_loyalty_data.csv')

# Quick sanity checks — uncomment to inspect data on import
# general_sales_df.head()
# bike_sales_df.head()
# location_sales_df.head()
# loyalty_df.head()


# ============================================================
# 3. PRODUCT SALES TRENDS
# ============================================================
# Two chart/plot types explored for the same data:
# (a) Stacked bar chart — good for comparing totals across months
# (b) Area chart subplots — better for reading individual product
#     trends without visual overlap; used in the final report

# Pivot required to stack series — pandas plot() needs products
# as columns, not rows
sales_pivot_df = general_sales_df.pivot(
    index='SaleMonth',
    columns='ProductType',
    values='TotalSales'
).fillna(0)


# -- (a) Stacked bar chart (exploratory, not used in report) --

sales_pivot_df.plot(
    kind='bar',
    stacked=True,
    figsize=(12, 6)
)

plt.legend(
    bbox_to_anchor=(0.5, -0.2),
    loc='upper center',
    ncol=2
)
plt.xticks(rotation=45)
plt.tight_layout()
# plt.savefig("sale_trends_barplot.jpeg", dpi=300)


# -- (b) Area chart — one subplot per product type (final) --
# layout=(-1, 3) auto-calculates rows based on number of products
# sharey=False allows each subplot to use its own y-axis scale,
# which is important since sales volumes vary significantly 
# across product types

axes = sales_pivot_df.plot(
    kind='area',
    subplots=True,
    layout=(-1, 3),
    figsize=(15, 10),
    sharex=True,
    sharey=False,   
    alpha=0.4,
    legend=True
)

for ax in axes.flatten():
    ax.set_xlabel('Month')
    ax.set_ylabel('Sales')
    ax.tick_params(axis='x', rotation=45)

plt.suptitle('Sales Over Time by Product Type', y=0.98)
plt.tight_layout()
plt.savefig("sale_trends_areachart.jpeg", dpi=300)


# ============================================================
# 4. BIKE SALES REVENUE TRENDS
# ============================================================
# Filtered to mountain, road, and touring bikes only
# Revenue used instead of volume to capture price differences
# across bike types

# Convert SaleMonth to datetime for correct chronological plotting
bike_sales_df['SaleMonth'] = pd.to_datetime(bike_sales_df['SaleMonth'])

# Pivot by Revenue — fillna(0) required to connect lines across
# months with no sales (gaps would break the line otherwise)
bike_sales_pivot = bike_sales_df.pivot(
    index='SaleMonth',
    columns='ProductType',
    values='Revenue'
).fillna(0)

plt.figure(figsize=(12, 6))

##To ensure that the colors match the column order in case you change col order
colours = {
    'Mountain Bikes': 'steelblue',
    'Road Bikes': 'darkorange',
    'Touring Bikes': 'green'
}

for col in bike_sales_pivot.columns:
    plt.plot(
        bike_sales_pivot.index,
        bike_sales_pivot[col],
        marker='o',
        label=col,
        color=colours[col]
    )
    

plt.title('Revenue Trends for Bike Types')
plt.xlabel('Month')
plt.ylabel('Revenue (£)')
plt.legend()
plt.grid(False)
plt.tight_layout()
plt.savefig("bike_sale_trends.jpeg", dpi=300)


# ============================================================
# 5. CUSTOMER LOYALTY ANALYSIS
# ============================================================
# Two visualisations of the same loyalty data:
# (a) Heatmap — average purchases by loyalty tier and location
# (b) Treemap — market share by tier and location, sized by 
#     number of customers and labelled with avg purchases

# Aggregate: count customers and average purchases per location-tier combination
tier_counts_df = loyalty_df.groupby(
    ['Location', 'LoyaltyStatus'],
    dropna=False
).agg(
    TierCustomers=('NumCustomers', 'sum'),
    AvgPurchases=('AvgPurchases', 'mean')
).reset_index()

# Recode NaN loyalty status for plotting clarity
tier_counts_df['LoyaltyStatus'] = tier_counts_df['LoyaltyStatus'].fillna('No status')

# Set explicit category order so plots read Bronze → Silver → Gold
# rather than alphabetically
tier_counts_df['LoyaltyStatus'] = pd.Categorical(
    tier_counts_df['LoyaltyStatus'],
    categories=['No status', 'Bronze', 'Silver', 'Gold'],
    ordered=True
)


# -- (a) Heatmap: avg purchases by loyalty tier and location --

heatmap_data = tier_counts_df.pivot_table(
    index='Location',
    columns='LoyaltyStatus',
    values='AvgPurchases',
    fill_value=0
)

plt.figure(figsize=(10, 6))
sns.heatmap(
    heatmap_data,
    annot=True,
    fmt='.1f',       # one decimal place for readability
    cmap='BuPu'
)
plt.title('Average Customer Purchases by Loyalty Status and Location')
plt.ylabel('Location')
plt.xlabel('Loyalty Status')
plt.tight_layout()
plt.savefig("loyalty-location-purchases_heatmap.jpeg", dpi=300)


# -- (b) Treemap: market share by location and loyalty tier --
# plt.clf() required here — without it, the colour legend from 
# the heatmap persists as a ghost element on the treemap figure

plt.clf()

labels = (
    tier_counts_df['Location'] + "\n" +
    tier_counts_df['LoyaltyStatus'].astype(str)
)

squarify.plot(
    sizes=tier_counts_df['TierCustomers'],
    label=labels,
    color=sns.color_palette("YlGnBu", len(tier_counts_df)),
    alpha=0.8,
    value=round(tier_counts_df['AvgPurchases'], 2)  # rounded for legibility
)

plt.axis('off')
plt.title('Customer Market Share by Location and Loyalty Tier\n(Size = number of customers, Value = avg purchases)')
plt.tight_layout()
plt.savefig("loyalty-location-purchases_treemap.jpeg", dpi=300)
plt.show()