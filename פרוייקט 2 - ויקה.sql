
GO 
--שאלה 1
WITH IncomePerYear
AS
(SELECT YEAR(I.InvoiceDate) AS InvoiceYear,
       Sum(IL.ExtendedPrice-IL.TaxAmount) AS IncomePerYear,
       COUNT(DISTINCT MONTH(I.InvoiceDate)) AS NumberOfDistinctmonths,
       Sum(IL.ExtendedPrice-IL.TaxAmount)/COUNT(DISTINCT MONTH(I.InvoiceDate))*12 AS YearlyLinearIncome
FROM sales.InvoiceLines IL JOIN sales.Invoices I
ON IL.InvoiceID=I.InvoiceID
GROUP BY YEAR(I.InvoiceDate))
SELECT IncomePerYear.invoiceyear,
       FORMAT(IncomePerYear.IncomePerYear,'N2'),
       IncomePerYear.NumberOfDistinctmonths,
       FORMAT(IncomePerYear.YearlyLinearIncome,'N2'),
       CAST(ROUND(((IncomePerYear.YearlyLinearIncome-InP2.YearlyLinearIncome)/InP2.YearlyLinearIncome)*100,2) AS FLOAT) AS GrowthRate
FROM IncomePerYear LEFT JOIN IncomePerYear InP2
ON IncomePerYear.InvoiceYear=InP2.[InvoiceYear]+1
ORDER BY IncomePerYear.[InvoiceYear]

GO 
--שאלה 2
WITH tbl1
AS
(SELECT YEAR(I.InvoiceDate) AS TheYear,
       DATEPART(QQ,I.InvoiceDate) AS TheQuarter,
       CAST(ROUND(Sum(IL.Quantity*IL.UnitPrice),2) AS FLOAT) AS IncomePerQuarterYear,
       c.CustomerName,
       ROW_NUMBER() OVER(PARTITION BY YEAR(I.InvoiceDate),DATEPART(QQ,I.InvoiceDate)
                        ORDER BY CAST(ROUND(Sum(IL.Quantity*IL.UnitPrice),2) AS FLOAT) DESC) AS DNR
FROM sales.InvoiceLines IL JOIN sales.Invoices I
ON IL.InvoiceID=I.InvoiceID
JOIN sales.Customers C
On I.CustomerID=c.CustomerID
GROUP BY  YEAR(I.InvoiceDate),DATEPART(QQ,I.InvoiceDate),  c.CustomerName)
SELECT TheYear, TheQuarter, CustomerName, IncomePerQuarterYear, DNR
FROM tbl1
WHERE DNR<=5
ORDER BY  TheYear, TheQuarter, IncomePerQuarterYear DESC

GO

--שאלה 3
WITH TopProfitItems
AS
(SELECT IL.StockItemID AS StockItemID, 
       SI.StockItemName AS StockItemName,
       SUM(IL.ExtendedPrice-IL.TaxAmount) AS TotalProfit,
       ROW_NUMBER() OVER ( ORDER BY SUM(IL.ExtendedPrice-IL.TaxAmount) DESC) AS LineNum
FROM Sales.InvoiceLines IL JOIN Warehouse.StockItems SI
ON IL.StockItemID=SI.StockItemID
GROUP BY IL.StockItemID, SI.StockItemName)
SELECT StockItemID, StockItemName, TotalProfit
FROM TopProfitItems
WHERE LineNum<=10

--שאלה 4
SELECT SI.StockItemID AS StockItemID, 
       SI.StockItemName AS StockItemName,
       SI.UnitPrice AS UnitPrice,
       SI.RecommendedRetailPrice AS RecommendedRetailPrice,
       SI.RecommendedRetailPrice-SI.UnitPrice AS NominalProductProfit,
       DENSE_RANK() OVER(ORDER BY (SI.RecommendedRetailPrice-SI.UnitPrice) DESC) AS DNR
FROM Warehouse.StockItems SI
WHERE SI.ValidTo>GETDATE()
ORDER BY (SI.RecommendedRetailPrice-SI.UnitPrice) DESC

--שאלה 5
SELECT CONCAT_WS('-',s.SupplierID,s.SupplierName) AS SupplierDetails,
       STRING_AGG(CONCAT(SI.StockItemID,' ',SI.StockItemName),'/') AS ProductDetails
FROM Purchasing.Suppliers S JOIN Warehouse.StockItems SI 
ON S.SupplierID=SI.SupplierID
GROUP BY S.SupplierID,S.SupplierName

GO
--שאלה 6
WITH InvoicesSum
AS(
SELECT I.InvoiceID,I.CustomerID, SUM(IL.ExtendedPrice) AS TotalExtendedPrice
FROM Sales.InvoiceLines IL JOIN Sales.Invoices I
ON IL.InvoiceID=I.InvoiceID 
GROUP BY  I.CustomerID, I.InvoiceID),
CusSum
AS(
SELECT sum(Ins.TotalExtendedPrice) AS TotalExtendedPrice, c.CustomerID, CT.CityName, Country.CountryName,
       Country.Continent, Country.Region,
       DENSE_RANK() OVER(ORDER BY sum(Ins.TotalExtendedPrice) DESC) AS DNR
FROM InvoicesSum InS JOIN Sales.Customers C
ON Ins.CustomerID=c.CustomerID
JOIN Application.Cities CT 
ON c.PostalCityID=ct.CityID
JOIN Application.StateProvinces SP
ON ct.StateProvinceID=SP.StateProvinceID
JOIN Application.Countries Country
ON SP.CountryID=Country.CountryID
GROUP BY c.CustomerID, CT.CityName, Country.CountryName,
       Country.Continent, Country.Region)

SELECT CustomerID, CityName, CountryName, Continent, Region,TotalExtendedPrice
FROM CusSum
WHERE DNR<=5

--שאלה 7

WITH MonthlySum AS(
SELECT YEAR(I.InvoiceDate) AS InvoiceYear,
       MONTH(I.InvoiceDate) AS InvoiceMonth,
       sum(IL.Quantity*IL.UnitPrice) AS MonthlyTotal
FROM Sales.InvoiceLines IL JOIN Sales.Invoices I
ON IL.InvoiceID=I.InvoiceID
GROUP BY ROLLUP (YEAR(I.InvoiceDate), MONTH(I.InvoiceDate))
),

CumulativeSum AS (    
SELECT MS.InvoiceYear,
       MS.InvoiceMonth,
       MS.MonthlyTotal,
      SUM(CASE WHEN MS.InvoiceMonth IS NOT NULL 
                THEN MS.MonthlyTotal 
                ELSE 0 
          END) OVER (
                    PARTITION BY MS.InvoiceYear
                    ORDER BY CASE 
                               WHEN MS.InvoiceMonth IS NULL 
                               THEN 13 
                               ELSE MS.InvoiceMonth 
                             END
                    ROWS UNBOUNDED PRECEDING
                )
     AS CumulativeTotal
    FROM MonthlySum MS
)

SELECT CS.InvoiceYear,
       CASE WHEN CS.InvoiceYear IS NOT NULL 
                 AND CS.InvoiceMonth IS NULL
            THEN 'Grand Total'
            WHEN CS.InvoiceYear IS NULL
            THEN 'Grand Total All Years'
            ELSE CAST (CS.InvoiceMonth AS VarCHAR(2)) 
        END AS InvoiceMonth,
       CS.MonthlyTotal,
       CS.CumulativeTotal
FROM CumulativeSum CS
ORDER BY 
        CASE WHEN CS.InvoiceYear IS NULL THEN 1 ELSE 0 END,
        CS.InvoiceYear,
        CASE WHEN CS.InvoiceMonth IS NULL THEN 13 ELSE CS.InvoiceMonth END,
        CS.InvoiceMonth

--שאלה 8
SELECT OrderMonth,
        ISNULL([2013], 0) AS [2013],
        ISNULL([2014], 0) AS [2014],
        ISNULL([2015], 0) AS [2015],
        ISNULL([2016], 0) AS [2016]
FROM (SELECT MONTH(O.OrderDate) AS OrderMonth, YEAR(O.OrderDate) AS OrderYear, COUNT(O.OrderID) AS SumOfOrders
      FROM Sales.Orders O
      GROUP BY MONTH(O.OrderDate), YEAR(O.OrderDate)) AS Source_table
PIVOT (Sum(SumOfOrders) FOR OrderYear IN ([2013], [2014], [2015], [2016])) AS Pvt



--שאלה 9
WITH CustOrder
AS(
SELECT c.CustomerID, c.CustomerName, o.OrderDate,
       ROW_NUMBER() OVER(PARTITION BY C.CustomerID ORDER BY o.OrderDate DESC) AS rnum,
       RANK() OVER(ORDER BY o.OrderDate DESC) AS rnumAll
FROM Sales.Customers C JOIN Sales.Orders O
On c.CustomerID=O.CustomerID),

LastCustOrder
AS(
SELECT *
FROM CustOrder CO
WHERE rnum=1)

SELECT  CO.CustomerID, CO.CustomerName, CO.OrderDate, BO.OrderDate AS PreviousOrderDate,
        AVG(DATEDIFF(DD,BO.OrderDate,CO.OrderDate)) OVER(PARTITION BY CO.CustomerID) AS AvgDaysBetweenOrders,
        LCO.OrderDate AS LastCustOrderDate,
        (SELECT MAX(OrderDate) FROM Sales.Orders) AS LastOrderDateAll,
        DATEDIFF(DD,LCO.OrderDate,(SELECT MAX(OrderDate) FROM Sales.Orders)) AS DaysSinceLastOrder,
        CASE 
          WHEN DATEDIFF(DD,LCO.OrderDate,(SELECT MAX(OrderDate) FROM Sales.Orders))> 2*AVG(DATEDIFF(DD,BO.OrderDate,CO.OrderDate)) OVER(PARTITION BY CO.CustomerID)
          THEN 'Potential Churn'
          ELSE 'Active'
        END AS CustomerStatus

FROM CustOrder BO RIGHT JOIN CustOrder CO
   ON BO.CustomerID=CO.CustomerID ANd BO.rnum=CO.rnum+1
JOIN LastCustOrder LCO 
    ON LCO.CustomerID=CO.CustomerID
ORDER BY CO.CustomerID, CO.OrderDate

--שאלה 10
WITH 
CustomersNames
AS(
SELECT CASE
         WHEN c.CustomerName LIKE 'Tailspin%'
         THEN 'Tailspin'
         WHEN c.CustomerName LIKE 'Wingtip%'
         THEN 'Wingtip'
         ELSE c.CustomerName
        END AS CustomerName,
        c.CustomerCategoryID
FROM Sales.Customers C ),

GroupingCust
AS(
SELECT CN.CustomerName,CN.CustomerCategoryID, CC.CustomerCategoryName
FROM CustomersNames CN JOIN Sales.CustomerCategories CC 
ON CN.CustomerCategoryID=CC.CustomerCategoryID
GROUP BY CN.CustomerName,CN.CustomerCategoryID, CC.CustomerCategoryName)

SELECT GC.CustomerCategoryName, COUNT(GC.CustomerName) AS CustomerCount,
       SUM(COUNT(*)) OVER() AS TotalCustCount,
       CAST(
        CAST(
            (100.0*COUNT(GC.CustomerName) )/NULLIF(SUM(COUNT(*)) OVER(),0) 
            AS DECIMAL(4,2)
         ) AS VARCHAR(6)
        )+'%' AS DistributionFactor
FROM GroupingCust GC 
GROUP BY GC.CustomerCategoryName

