-- ============================================================
-- Script: Sales Data Exploration & Aggregation
-- Project: MMR Retail Business Analytics Case Study
-- Author: Dr. Cristina Chueca Del Cerro
-- Date: March 2026 (updated July 2026)
-- Description: Exploratory queries examining sales volume,
--              quantity totals, and salesperson performance
--              within a defined date range.
-- Note: Adapted from SQL Server syntax — TO_DATE() replaced
--       with direct date string comparison for MySQL
-- Prerequisites: Run 01_database_creation.sql first
-- ============================================================

USE salesdatabase;

-- --------------------------------------------------------
-- Query 1: Sales Within Date Range
-- Purpose: Filter sales records to H2 2022 for 
--          period-specific performance analysis
-- --------------------------------------------------------

SELECT * 
FROM tblsales
WHERE SalesDate BETWEEN '2022-08-11' AND '2022-12-30';


-- --------------------------------------------------------
-- Query 2: Overall Sales Volume and Quantity
-- Purpose: Compute total record count and quantity sold
--          across all transactions as a baseline summary
-- --------------------------------------------------------

SELECT 
    COUNT(*) AS record_count,
    SUM(Quantity) AS total_quantity
FROM tblsales;


-- --------------------------------------------------------
-- Query 3: Sales Performance by Salesperson
-- Purpose: Break down record count and total quantity by
--          salesperson within the H2 2022 date range to
--          identify individual performance patterns
-- --------------------------------------------------------

SELECT
    SalesPersonID,
    COUNT(*) AS record_count,
    SUM(Quantity) AS total_quantity
FROM tblsales
WHERE SalesDate BETWEEN '2022-08-11' AND '2022-12-30'
GROUP BY SalesPersonID
ORDER BY SalesPersonID DESC;