SELECT * FROM wallmart.`walmartsales dataset - walmartsales`;

## Task 1: Identifying the Top Branch by Sales Growth Rate

WITH MonthlySales AS (
    SELECT 
        Branch,
        DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS Sales_Month,
        SUM(Total) AS Monthly_Sales
    FROM `wallmart`.`walmartsales dataset - walmartsales`
    GROUP BY Branch, Sales_Month
),

GrowthCalc AS (
    SELECT 
        Branch,
        Sales_Month,
        Monthly_Sales,
        LAG(Monthly_Sales) OVER (PARTITION BY Branch ORDER BY Sales_Month) AS Prev_Month_Sales,
        ROUND(
            (Monthly_Sales - LAG(Monthly_Sales) OVER (PARTITION BY Branch ORDER BY Sales_Month)) /
            LAG(Monthly_Sales) OVER (PARTITION BY Branch ORDER BY Sales_Month) * 100, 2
        ) AS Growth_Rate
    FROM MonthlySales
)

SELECT 
    Branch, 
    ROUND(AVG(Growth_Rate), 2) AS Avg_Monthly_Growth_Rate
FROM GrowthCalc
WHERE Growth_Rate IS NOT NULL
GROUP BY Branch
ORDER BY Avg_Monthly_Growth_Rate DESC
LIMIT 1;





## Task 2: Finding the Most Profitable Product Line for Each Branch

WITH ProfitPerProduct AS (
    SELECT 
        Branch,
        `Product line`,
        ROUND(SUM(`gross income`), 2) AS Total_Profit
    FROM `wallmart`.`walmartsales dataset - walmartsales`
    GROUP BY Branch, `Product line`
),
RankedProfit AS (
    SELECT *,
        RANK() OVER (PARTITION BY Branch ORDER BY Total_Profit DESC) AS Profit_Rank
    FROM ProfitPerProduct
)
SELECT Branch, `Product line`, Total_Profit
FROM RankedProfit
WHERE Profit_Rank = 1;


## Task 3: Customer Segmentation Based on Spending

SELECT 
    `Customer ID`,
    ROUND(SUM(Total), 2) AS Total_Spent,
    CASE
        WHEN SUM(Total) > 500 THEN 'High'
        WHEN SUM(Total) BETWEEN 200 AND 500 THEN 'Medium'
        ELSE 'Low'
    END AS Spending_Tier
FROM `wallmart`.`walmartsales dataset - walmartsales`
GROUP BY `Customer ID`;








## Task 4: Detecting Anomalies in Sales Transactions

WITH AvgSales AS (
    SELECT 
        `Product line`, 
        AVG(Total) AS Avg_Total
    FROM `wallmart`.`walmartsales dataset - walmartsales`
    GROUP BY `Product line`
)

SELECT 
    w.`Invoice ID`,
    w.Branch,
    w.`Product line`,
    w.Total,
    a.Avg_Total,
    CASE 
        WHEN w.Total > a.Avg_Total * 2 THEN 'High Anomaly'
        WHEN w.Total < a.Avg_Total * 0.5 THEN 'Low Anomaly'
        ELSE 'Normal'
    END AS Anomaly_Flag
FROM `wallmart`.`walmartsales dataset - walmartsales` w
JOIN AvgSales a ON w.`Product line` = a.`Product line`
WHERE w.Total > a.Avg_Total * 2 OR w.Total < a.Avg_Total * 0.5;






## Task 5: Most Popular Payment Method by City

WITH PaymentRank AS (
    SELECT 
        City,
        Payment,
        COUNT(*) AS Payment_Count,
        RANK() OVER (PARTITION BY City ORDER BY COUNT(*) DESC) AS Payment_Rank
    FROM `wallmart`.`walmartsales dataset - walmartsales`
    GROUP BY City, Payment
)

SELECT City, Payment AS Most_Popular_Payment_Method, Payment_Count
FROM PaymentRank
WHERE Payment_Rank = 1;





## Task 6: Monthly Sales Distribution by Gender

SELECT 
    DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS Sales_Month,
    Gender,
    ROUND(SUM(Total), 2) AS Total_Sales
FROM `wallmart`.`walmartsales dataset - walmartsales`
GROUP BY Sales_Month, Gender
ORDER BY Sales_Month, Gender;


## Task 7: Best Product Line by Customer Type

WITH ProductRank AS (
    SELECT 
        `Customer type`,
        `Product line`,
        COUNT(*) AS Purchase_Count,
        RANK() OVER (PARTITION BY `Customer type` ORDER BY COUNT(*) DESC) AS Rank_Order
    FROM `wallmart`.`walmartsales dataset - walmartsales`
    GROUP BY `Customer type`, `Product line`
)

SELECT `Customer type`, `Product line` AS Best_Product_Line, Purchase_Count
FROM ProductRank
WHERE Rank_Order = 1;





## Task 8: Identifying Repeat Customers Within 30 Days

SELECT DISTINCT a.`Customer ID`
FROM `wallmart`.`walmartsales dataset - walmartsales` a
JOIN `wallmart`.`walmartsales dataset - walmartsales` b
  ON a.`Customer ID` = b.`Customer ID`
WHERE 
  a.`Invoice ID` <> b.`Invoice ID`
  AND ABS(DATEDIFF(STR_TO_DATE(a.Date, '%d-%m-%Y'), STR_TO_DATE(b.Date, '%d-%m-%Y'))) <= 30;

## Task 9: Finding Top 5 Customers by Sales Volume

SELECT 
    `Customer ID`,
    ROUND(SUM(Total), 2) AS Total_Revenue
FROM `wallmart`.`walmartsales dataset - walmartsales`
GROUP BY `Customer ID`
ORDER BY Total_Revenue DESC
LIMIT 5;

## Task 10: Analyzing Sales Trends by Day of the Week

SELECT 
    DAYNAME(STR_TO_DATE(Date, '%d-%m-%Y')) AS Day_of_Week,
    ROUND(SUM(Total), 2) AS Total_Sales
FROM `wallmart`.`walmartsales dataset - walmartsales`
GROUP BY Day_of_Week
ORDER BY Total_Sales DESC;



