-- ============================================================
-- Script: Business Analytics Queries
-- Project: MMR Retail Business Analytics Case Study
-- Author: Dr. Cristina Chueca Del Cerro
-- Date: March 2026 (updated July 2026)
-- Description: Four analytical SQL queries extracting customer 
--              loyalty, product sales, bike sales performance,
--              and location-based marketing insights from the 
--              MMR synthetic retail database.
-- Prerequisites: Run 01_database_creation.sql first
-- ============================================================

USE salesdatabase;

-- --------------------------------------------------------
-- Query 1: Customer Loyalty by Location
-- Purpose: Understand loyalty programme performance across
--          UK shop locations, including average purchases
--          per loyalty tier to identify retention patterns
-- --------------------------------------------------------

SELECT 
    Location,
    LoyaltyStatus,
    LoyaltyJoinDate,
    COUNT(*) AS NumCustomers,
    AVG(NumPurchases) AS AvgPurchases
FROM tblcustomers
GROUP BY Location, LoyaltyStatus, LoyaltyJoinDate
ORDER BY Location, LoyaltyStatus;


-- --------------------------------------------------------
-- Query 2: Monthly Sales by Product Type
-- Purpose: Track sales volume and unique customer counts
--          across all 10 product categories over 2022 to
--          identify seasonal trends and performance gaps
-- --------------------------------------------------------

SELECT 
    DATE_FORMAT(SalesDate, '%Y-%m') AS SaleMonth,
    ProductType,
    SUM(s.NumberOfSales) AS TotalSales,
    COUNT(DISTINCT s.CustomerID) AS UniqueCustomers
FROM tblsales s
JOIN tblproducts p ON s.ProductID = p.ProductID
GROUP BY SaleMonth, ProductType
ORDER BY SaleMonth, ProductType;


-- --------------------------------------------------------
-- Query 3: Bike Sales Performance by Type
-- Purpose: Isolate mountain, road, and touring bike sales
--          to examine revenue and volume trends across 2022,
--          informing stock and marketing decisions
-- Note: LOWER() applied for case-insensitive matching
-- --------------------------------------------------------

SELECT 
    DATE_FORMAT(s.SalesDate, '%Y-%m') AS SaleMonth,
    p.ProductType,
    SUM(s.NumberOfSales) AS TotalSales,
    SUM(s.NumberOfSales * p.Price) AS Revenue
FROM tblsales s
JOIN tblproducts p ON s.ProductID = p.ProductID
WHERE LOWER(p.ProductType) IN ('road bikes', 'mountain bikes', 'touring bikes')
GROUP BY SaleMonth, p.ProductType
ORDER BY SaleMonth;


-- --------------------------------------------------------
-- Query 4: Location-Based Marketing Opportunities
-- Purpose: Identify which product types are selling well
--          in which locations (>20 sales threshold) to 
--          inform targeted marketing and promotion strategy
-- --------------------------------------------------------

SELECT 
    c.Location,
    p.ProductType,
    SUM(s.NumberOfSales) AS TotalSales
FROM tblsales s
JOIN tblcustomers c ON s.CustomerID = c.CustomerID
JOIN tblproducts p ON s.ProductID = p.ProductID
GROUP BY c.Location, p.ProductType
HAVING TotalSales > 20
ORDER BY TotalSales DESC;