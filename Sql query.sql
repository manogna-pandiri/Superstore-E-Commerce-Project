create database superstore_db;
use superstore_db;
CREATE TABLE superstore (
    `Row ID`        INT,
    `Order ID`      VARCHAR(20),
    `Order Date`    VARCHAR(20),
    `Ship Date`     VARCHAR(20),
    `Ship Mode`     VARCHAR(30),
    `Customer ID`   VARCHAR(20),
    `Customer Name` VARCHAR(100),
    `Segment`       VARCHAR(20),
    `Country`       VARCHAR(50),
    `City`          VARCHAR(50),
    `State`         VARCHAR(50),
    `Postal Code`   INT,
    `Region`        VARCHAR(20),
    `Product ID`    VARCHAR(20),
    `Category`      VARCHAR(30),
    `Sub-Category`  VARCHAR(30),
    `Product Name`  VARCHAR(200),
    `Sales`         FLOAT,
    `Quantity`      INT,
    `Discount`      FLOAT,
    `Profit`        FLOAT
);

select * from superstore;
drop table superstore;

select count(*) from superstore;


####   Total Sales, Profit & Orders   ####

SELECT
    COUNT(DISTINCT `Order ID`)           AS Total_Orders,
    ROUND(SUM(`Sales`), 2)               AS Total_Sales,
    ROUND(SUM(`Profit`), 2)              AS Total_Profit,
    ROUND(SUM(`Profit`) / SUM(`Sales`) * 100, 2) AS Overall_Profit_Margin_Pct,
    ROUND(AVG(`Sales`), 2)               AS Avg_Order_Value
FROM superstore;


####   Sales & Profit by Category   ####

SELECT
    `Category`,
    COUNT(`Order ID`)                    AS Total_Orders,
    ROUND(SUM(`Sales`), 2)               AS Total_Sales,
    ROUND(SUM(`Profit`), 2)              AS Total_Profit,
    ROUND(SUM(`Profit`) / SUM(`Sales`) * 100, 2) AS Profit_Margin_Pct
FROM superstore
GROUP BY `Category`
ORDER BY Total_Sales DESC;


####   Sales & Profit by Region   ####

SELECT
    `Region`,
    ROUND(SUM(`Sales`), 2)               AS Total_Sales,
    ROUND(SUM(`Profit`), 2)              AS Total_Profit,
    ROUND(AVG(`Discount`) * 100, 2)      AS Avg_Discount_Pct,
    ROUND(SUM(`Profit`) / SUM(`Sales`) * 100, 2) AS Profit_Margin_Pct
FROM superstore
GROUP BY `Region`
ORDER BY Total_Profit DESC;


####   Top 10 Most Profitable Sub-Categories   ####

SELECT
    `Sub-Category`,
    `Category`,
    ROUND(SUM(`Sales`), 2)    AS Total_Sales,
    ROUND(SUM(`Profit`), 2)   AS Total_Profit,
    ROUND(SUM(`Profit`) / SUM(`Sales`) * 100, 2) AS Profit_Margin_Pct
FROM superstore
GROUP BY `Sub-Category`, `Category`
ORDER BY Total_Profit DESC
LIMIT 10;


####   Loss-Making Sub-Categories (Profit < 0)   ####

SELECT
    `Sub-Category`,
    `Category`,
    ROUND(SUM(`Sales`), 2)    AS Total_Sales,
    ROUND(SUM(`Profit`), 2)   AS Total_Profit,
    COUNT(`Order ID`)         AS Order_Count
FROM superstore
GROUP BY `Sub-Category`, `Category`
HAVING Total_Profit < 0
ORDER BY Total_Profit ASC;


####   Discount Impact on Profit (Window Function)   ####

SELECT
    CASE
        WHEN `Discount` = 0            THEN '0% Discount'
        WHEN `Discount` <= 0.1         THEN '1-10% Discount'
        WHEN `Discount` <= 0.2         THEN '11-20% Discount'
        WHEN `Discount` <= 0.3         THEN '21-30% Discount'
        ELSE 'Above 30% Discount'
    END AS Discount_Band,
    COUNT(`Order ID`)                        AS Orders,
    ROUND(SUM(`Sales`), 2)                   AS Total_Sales,
    ROUND(SUM(`Profit`), 2)                  AS Total_Profit,
    ROUND(AVG(`Profit`), 2)                  AS Avg_Profit_Per_Order
FROM superstore
GROUP BY Discount_Band
ORDER BY Avg_Profit_Per_Order DESC;


####   Monthly Sales Trend   ####

SELECT
    YEAR(`Order Date`)                      AS Order_Year,
    MONTH(`Order Date`)                     AS Order_Month,
    DATE_FORMAT(`Order Date`, '%Y-%m')      AS Yr_Month,
    ROUND(SUM(`Sales`), 2)                  AS Monthly_Sales,
    ROUND(SUM(`Profit`), 2)                 AS Monthly_Profit,
    COUNT(DISTINCT `Order ID`)              AS Monthly_Orders
FROM superstore
GROUP BY Order_Year, Order_Month, Yr_Month
ORDER BY Yr_Month;


####   Customer Segment Performance (CTE)   ####

WITH Segment_KPI AS (
    SELECT
        `Segment`,
        COUNT(DISTINCT `Customer ID`)           AS Unique_Customers,
        COUNT(DISTINCT `Order ID`)              AS Total_Orders,
        ROUND(SUM(`Sales`), 2)                  AS Total_Sales,
        ROUND(SUM(`Profit`), 2)                 AS Total_Profit
    FROM superstore
    GROUP BY `Segment`
)

SELECT
    Segment,
    Unique_Customers,
    Total_Orders,
    Total_Sales,
    Total_Profit,
    ROUND(Total_Sales / Unique_Customers, 2)    AS Revenue_Per_Customer,
    ROUND(Total_Profit / Total_Sales * 100, 2)  AS Profit_Margin_Pct
FROM Segment_KPI
ORDER BY Total_Sales DESC;


###    Top 10 Customers by Revenue (Window Function)   ####

SELECT
    `Customer Name`,
    `Segment`,
    ROUND(SUM(`Sales`), 2)      AS Total_Revenue,
    ROUND(SUM(`Profit`), 2)     AS Total_Profit,
    COUNT(DISTINCT `Order ID`)  AS Total_Orders,
    RANK() OVER (ORDER BY SUM(`Sales`) DESC) AS Revenue_Rank
FROM superstore
GROUP BY `Customer Name`, `Segment`
ORDER BY Revenue_Rank
LIMIT 10;


####   Shipping Days Analysis by Ship Mode   ####

SELECT
    `Ship Mode`,
    COUNT(`Order ID`)                              AS Orders,
    ROUND(AVG(DATEDIFF(`Ship Date`, `Order Date`)), 1) AS Avg_Shipping_Days,
    MIN(DATEDIFF(`Ship Date`, `Order Date`))      AS Min_Days,
    MAX(DATEDIFF(`Ship Date`, `Order Date`))      AS Max_Days
FROM superstore
GROUP BY `Ship Mode`
ORDER BY Avg_Shipping_Days;



