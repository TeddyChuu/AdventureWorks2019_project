USE AdventureWorks2019;
GO

SELECT @@SERVERNAME
GO

CREATE VIEW Fact_Sales AS
SELECT SD.SalesOrderID,
	S.OrderDate,
	S.ShipDate,
	S.ShipMethodID,	
	S.CustomerID,
	S.SalesPersonID,
	ST.TerritoryID,
	SD.ProductID,
	SD.SpecialOfferID,
    ST.Name,
	ST.[Group],
	PC.ProductCategoryID,
	PSC.ProductSubcategoryID,
	SD.OrderQty,
	SD.UnitPrice,
	SD.UnitPriceDiscount,
	S.Freight,
	S.TaxAmt,
	PP.StandardCost,
	SD.LineTotal, 
	PP.StandardCost * OrderQty as TotalStandardCost, 
	SD.LineTotal - (PP.StandardCost * OrderQty) as GrossProfit
FROM Sales.SalesOrderHeader as S
INNER JOIN Sales.SalesTerritory as ST ON ST.TerritoryID = S.TerritoryID
INNER JOIN Sales.Customer AS SC ON SC.CustomerID = S.CustomerID 
INNER JOIN Sales.SalesOrderDetail as SD ON S.SalesOrderID = SD.SalesOrderID
INNER JOIN Production.Product AS PP ON PP.ProductID = SD.ProductID
INNER JOIN [Production].[ProductSubcategory] AS PSC ON PSC.ProductSubcategoryID = PP.ProductSubcategoryID
INNER JOIN [Production].[ProductCategory]  AS PC ON PC.ProductCategoryID = PSC.ProductCategoryID
GO

CREATE VIEW DimProduct AS
SELECT DISTINCT PP.ProductID,
	 PC.ProductCategoryID ,
	 PP.ProductSubcategoryID,
	 PP.Name AS Product_Name,
	 PP.StandardCost,
	 PP.DaysToManufacture,
	 PP.ProductLine, 
	 PP.Style, 
	 PP.Color, 
	 PP.Size, 
	 PP.Class,
	 PP.Weight
FROM Production.Product AS PP
FULL JOIN [Production].[ProductSubcategory] AS PSC  ON PSC.ProductSubcategoryID = PP.ProductSubcategoryID
FULL JOIN Sales.SalesOrderDetail AS SD ON SD.ProductID = PP.ProductID
FULL JOIN [Production].[ProductCategory]  AS PC ON PC.ProductCategoryID = PSC.ProductCategoryID
FULL JOIN Production.ProductModel AS PPM ON PPM.ProductModelID = PP.ProductModelID
WHERE PP.ProductID IS NOT NULL
GROUP BY PP.ProductID,
	PP.Name,
	PP.Color,
	PP.Size,
	PP.Weight,
	PP.Style,
	PP.StandardCost,
	PP.DaysToManufacture,
	PP.Class,
	PPM.ProductModelID,
	PP.ProductLine,
	PPM.Name,
	PC.ProductCategoryID,
	PC.ProductCategoryID ,
	PP.ProductSubcategoryID
GO

CREATE VIEW SubCate AS
SELECT PSC.Name AS SubcategoryName,
	   PSC.ProductSubcategoryID,
       PC.ProductCategoryID,
       PC.Name AS ProductCategoryName    
FROM [Production].[ProductCategory] AS PC 
LEFT JOIN [Production].[ProductSubcategory] as PSC
ON PSC.ProductCategoryID = PC.ProductCategoryID
GO

CREATE VIEW DimCustomer AS
SELECT DISTINCT PPER.BusinessEntityID,
	SC.CustomerID,
	SC.PersonID,
	SC.StoreID,
	SC.TerritoryID,
	PA.StateProvinceID,
	PPER.PersonType, 
	PPER.FirstName +' '+PPER.LastName AS Full_Name,
	PPER.Suffix,
	PPER.Title,		
	PA.AddressLine1,
	PA.AddressLine2,
	PA.PostalCode,
	PA.City
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Person.Address AS PA ON PA.AddressID = SOH.BillToAddressID
INNER JOIN Sales.Customer AS SC ON SOH.CustomerID = SC.CustomerID 
INNER JOIN Sales.SalesTerritory AS ST ON ST.TerritoryID = SC.TerritoryID 
INNER JOIN Person.CountryRegion AS PCR ON ST.CountryRegionCode =PCR.CountryRegionCode
INNER JOIN Person.StateProvince AS PSP ON PSP.CountryRegionCode = PCR.CountryRegionCode
LEFT JOIN Person.Person AS PPER ON SC.PersonID = PPER.BusinessEntityID
GO

