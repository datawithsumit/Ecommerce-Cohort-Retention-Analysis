-- Analysis for Amazon/Retail Customer Retention
-- Steps: 1. Clean Data, 2. Define Cohorts, 3. Calculate Retention

USE ecommerce_project;

-- =======================================================
-- STEP 1: Cleaning the Raw Data
-- =======================================================
-- The date column came in as text, so I need to convert it to a proper date format.
-- Also removing spaces from column names to make querying easier later.

DROP TABLE IF EXISTS retail_main;

CREATE TABLE retail_main AS
SELECT 
    Invoice,
    StockCode,
    Description,
    Quantity,
    -- Convert format from '12/1/2010 8:26' to Standard SQL Date
    STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i') AS Invoice_Date,
    Price,
    `Customer ID` as Customer_ID, -- handling the space in the raw column name
    Country,
    `Total Sales` as Total_Sale   -- renaming for easier access
FROM retail_clean;

-- =======================================================
-- STEP 2: Creating the Cohort (The "Start Date")
-- =======================================================
-- I need to find the very first month a customer purchased something.
-- This "Cohort Month" will stick with them forever so we can track them.

DROP TABLE IF EXISTS cohort_items;

CREATE TABLE cohort_items AS
SELECT 
    Customer_ID,
    MIN(Invoice_Date) as First_Purchase_Date,
    -- Standardize the date to the 1st of the month (e.g., 2010-12-05 becomes 2010-12-01)
    DATE_FORMAT(MIN(Invoice_Date), '%Y-%m-01') as Cohort_Month
FROM retail_main
GROUP BY Customer_ID;

-- =======================================================
-- STEP 3: Retention Analysis (The "Comeback" Rate)
-- =======================================================
-- Now I'll join the transaction data with the cohort data.
-- Goal: Calculate the gap (in months) between their first purchase and current purchase.

DROP TABLE IF EXISTS retention_matrix;

CREATE TABLE retention_matrix AS
SELECT 
    c.Cohort_Month,
    -- Month_Index 0 means they bought in the same month they joined.
    -- Month_Index 1 means they came back the next month, etc.
    TIMESTAMPDIFF(MONTH, STR_TO_DATE(c.Cohort_Month, '%Y-%m-%d'), m.Invoice_Date) as Month_Index,
    COUNT(DISTINCT m.Customer_ID) as Customer_Count
FROM retail_main m
JOIN cohort_items c ON m.Customer_ID = c.Customer_ID
GROUP BY c.Cohort_Month, Month_Index
ORDER BY c.Cohort_Month, Month_Index;

-- Final check to see the data structure
SELECT * FROM retention_matrix;