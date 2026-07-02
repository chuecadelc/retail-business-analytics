-- ============================================================
-- Script: Database Creation and Population
-- Project: MMR Retail Business Analytics Case Study
-- Author: Dr. Cristina Chueca Del Cerro
-- Date: March 2026 (updated July 2026)
-- Description: Creates and populates three synthetic tables 
--              (customers, employees, products, sales) in MySQL
--              with custom variables added beyond the original 
--              bootcamp dataset to enable business analytics.
-- Output: salesdatabase tables ready for normalisation 
--         and extraction
-- ============================================================

-- ============================================================
-- SETUP: Before running this script, create and select your 
-- schema in MySQL Workbench:
--   CREATE SCHEMA mmr_retail;
--   USE mmr_retail;
-- Or select your schema from the dropdown before executing.
--
-- IMPORTANT: If you need to drop and recreate any table, drop 
-- tblsales FIRST — it holds foreign keys referencing all other  
-- tables, so MySQL will not allow you to drop a parent table 
-- while tblsales exists.
-- ============================================================


-- ============================================================
-- TABLE 1: CUSTOMERS
-- ============================================================

-- Create base table with core fields from source data
CREATE TABLE IF NOT EXISTS tblcustomers (
    CustomerID    INT          AUTO_INCREMENT PRIMARY KEY,
    FirstName     TEXT         NOT NULL,        -- required field
    MiddleInitial TEXT         DEFAULT NULL,    -- optional: allows missing values
    LastName      VARCHAR(40)  NOT NULL         -- VARCHAR required: TEXT type 
                                                -- cannot be used as a key
);

-- Populate base table before adding custom columns:
-- Run Customers_data.sql here

-- Add custom analytical variables not present in source data
ALTER TABLE tblcustomers
    ADD COLUMN Location       VARCHAR(100),
    ADD COLUMN NumPurchases   INT          DEFAULT 0,
    ADD COLUMN LoyaltyStatus  VARCHAR(20),
    ADD COLUMN LoyaltyJoinDate DATE;

-- Disable safe update mode to allow updates without a KEY condition
-- (could not be changed via Preferences, so set inline instead)
SET SQL_SAFE_UPDATES = 0;

-- Populate custom columns in a single UPDATE statement
-- Note: Location must come last in the SET clause — ELT() requires 
-- the WHERE clause and primary key reference to execute correctly
-- when combined with other column assignments
UPDATE tblcustomers
SET 
    NumPurchases = FLOOR(1 + RAND() * 50),
    LoyaltyStatus = CASE
        WHEN NumPurchases >= 40 THEN 'Gold'
        WHEN NumPurchases >= 20 THEN 'Silver'
        WHEN NumPurchases >= 10 THEN 'Bronze'
        ELSE 'None'
    END,
    LoyaltyJoinDate = DATE_ADD(
        '2026-01-01', 
        INTERVAL FLOOR(RAND() * DATEDIFF(CURDATE(), '2026-01-01')) DAY
    ),
    Location = ELT(FLOOR(1 + RAND() * 6),
        'London',
        'Manchester',
        'Birmingham',
        'Leeds',
        'Glasgow',
        'Newcastle'
    )
WHERE CustomerID IS NOT NULL;
-- WHERE clause ensures LoyaltyJoinDate is only assigned to 
-- customers who exist in the loyalty programme


-- ============================================================
-- TABLE 2: EMPLOYEES
-- ============================================================

CREATE TABLE IF NOT EXISTS tblemployees (
    EmployeeID    INT         AUTO_INCREMENT PRIMARY KEY,
    FirstName     TEXT        NOT NULL,
    MiddleInitial TEXT        DEFAULT NULL,
    LastName      VARCHAR(40) NOT NULL
);

-- Populate base table before adding custom columns:
-- Run Employee_data.sql here

-- Add custom variables: working pattern and shop location
ALTER TABLE tblemployees
    ADD COLUMN WorkingPattern VARCHAR(50),
    ADD COLUMN Location       VARCHAR(100);

UPDATE tblemployees
SET 
    WorkingPattern = ELT(FLOOR(1 + RAND() * 3),
        'Full-Time',
        'Part-Time',
        'Shift-based'
    ),
    Location = ELT(FLOOR(1 + RAND() * 6),
        'London',
        'Manchester',
        'Birmingham',
        'Leeds',
        'Glasgow',
        'Newcastle'
    )
WHERE EmployeeID IS NOT NULL;


-- ============================================================
-- TABLE 3: PRODUCTS
-- ============================================================

CREATE TABLE IF NOT EXISTS tblproducts (
    ProductID INT  AUTO_INCREMENT PRIMARY KEY,
    PName     TEXT NOT NULL,
    Price     INT  NOT NULL
);

-- Populate base table before adding custom columns:
-- Run Product_data.sql here

-- Add custom variables: product type, inventory, sales volume,
-- and retail price
ALTER TABLE tblproducts
    ADD COLUMN ProductType   VARCHAR(50),
    ADD COLUMN Inventory     INT,
    ADD COLUMN NumberOfSales INT          DEFAULT 0,
    ADD COLUMN RetailPrice   DECIMAL(10,2);

-- Classify products into analytical categories using pattern 
-- matching on PName. LOWER() applied throughout for 
-- case-insensitive matching — source data uses title case.
--
-- Uncomment the query below to inspect distinct product names
-- before modifying category assignments:
-- SELECT DISTINCT PName FROM tblproducts;

UPDATE tblproducts
SET ProductType = CASE
    WHEN LOWER(PName) LIKE '%road-%'     THEN 'Road Bikes'
    WHEN LOWER(PName) LIKE '%mountain-%' THEN 'Mountain Bikes'
    WHEN LOWER(PName) LIKE '%touring-%'  THEN 'Touring Bikes'
    WHEN LOWER(PName) LIKE '%frame%'     THEN 'Frame'
    WHEN LOWER(PName) LIKE '%brake%'     THEN 'Brakes'
    WHEN LOWER(PName) LIKE '%lock nut%'  
      OR LOWER(PName) LIKE '%nut%'       THEN 'Nuts'
    WHEN LOWER(PName) LIKE '%wheel%'     
      OR LOWER(PName) LIKE '%tire%'      THEN 'Wheels/Tires'
    WHEN LOWER(PName) LIKE '%jersey%'    
      OR LOWER(PName) LIKE '%socks%'     
      OR LOWER(PName) LIKE '%shorts%'    
      OR LOWER(PName) LIKE '%vest%'      THEN 'Clothing'
    WHEN LOWER(PName) LIKE '%helmet%'    
      OR LOWER(PName) LIKE '%gloves%'    
      OR LOWER(PName) LIKE '%lights%'    
      OR LOWER(PName) LIKE '%pedal%'     THEN 'Accessories'
    ELSE 'Other'
END
WHERE ProductID IS NOT NULL;

-- Assign inventory, retail price, and sales volume based on 
-- product type. Sales rates are weighted to reflect realistic 
-- demand patterns — road bikes sell more than touring bikes,
-- popular clothing items (jerseys, vests) outperform basics.
UPDATE tblproducts
SET 
    Inventory    = FLOOR(1 + RAND() * 15050),
    RetailPrice  = FLOOR(1 + RAND() * 2550),
    NumberOfSales = CASE
        WHEN ProductType = 'Road Bikes'     
            THEN FLOOR(Inventory * (0.6 + RAND() * 0.4))
        WHEN ProductType = 'Mountain Bikes' 
            THEN FLOOR(Inventory * (0.3 + RAND() * 0.4))
        WHEN ProductType = 'Touring Bikes'  
            THEN FLOOR(Inventory * (0.2 + RAND() * 0.3))
        WHEN ProductType = 'Clothing' 
          AND (LOWER(PName) LIKE '%jersey%' 
            OR LOWER(PName) LIKE '%vest%')
            THEN FLOOR(Inventory * (0.5 + RAND() * 0.3))
        WHEN ProductType = 'Clothing'       
            THEN FLOOR(Inventory * (0.2 + RAND() * 0.3))
        ELSE FLOOR(Inventory * (0.1 + RAND() * 0.4))
    END
WHERE ProductID IS NOT NULL;


-- ============================================================
-- TABLE 4: SALES
-- ============================================================
-- Junction table linking customers, employees, and products.
-- No custom variables added — this table derives its analytical
-- value from JOIN queries across the other three tables.
--
-- Foreign key constraints enforce referential integrity:
-- tblsales must be dropped before any parent table can be 
-- dropped or recreated.
-- ============================================================

CREATE TABLE IF NOT EXISTS tblsales (
    SaleID       INT  AUTO_INCREMENT NOT NULL,
    SalesDate    DATE NOT NULL,
    EmployeeID   INT  NOT NULL,
    CustomerID   INT  NOT NULL,
    ProductID    INT  NOT NULL,
    NumberOfSales INT NOT NULL,
    PRIMARY KEY (SaleID),
    FOREIGN KEY (CustomerID)  REFERENCES tblcustomers(CustomerID),
    FOREIGN KEY (ProductID)   REFERENCES tblproducts(ProductID),
    FOREIGN KEY (EmployeeID)  REFERENCES tblemployees(EmployeeID)
);

-- Populate table before querying:
-- Run Sales_data.sql here