--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_VenezaT')
	 Begin 
	  Alter Database [Assignment06DB_VenezaT] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_VenezaT;
	 End
	Create Database Assignment06DB_VenezaT;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_VenezaT;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Categories Table:
--Go
--Create View vCategories
-- As
--  Select CategoryID, CategoryName From Northwind.dbo.Categories;
--Go

--Select * from vCategories;
--GO

Go
Create View vCategories
With SchemaBinding
 As
  Select CategoryID, CategoryName 
   From dbo.Categories;
Go

--Select * From Categories;
--Select * From vCategories;
--Go

--Products Table:
Go
Create View vProducts
With SchemaBinding
 As
  Select ProductID, ProductName, CategoryID, UnitPrice 
   From dbo.Products;
Go

--Select * From Products;
--Select * From vProducts;
--GO

--Employees Table:
Go
Create View vEmployees
With SchemaBinding
 As
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID 
    From dbo.Employees;
Go

--Select * From Employees;
--Select * From vEmployees;
--GO

--Inventories Table: 
Go
Create View vInventories
With SchemaBinding
 As
  Select InventoryID, InventoryDate, EmployeeID, ProductID, Count 
   From dbo.Inventories;
Go

--Select * From Inventories;
--Select * From vInventories;
--GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Categories Table:
--Select * From Categories;
--Select * From vCategories;
--Go

--Deny access for Public to Categories table and Grant access for Public to vCategories table:
Deny Select On Categories to Public;
Go
Grant Select On vCategories to Public;
Go

--Products Table: 
--Select * From Products;
--Select * From vProducts;
--Go

--Deny access for Public to Products table and Grant access for Public to vProducts table:
Deny Select On Products to Public;
Go
Grant Select On vProducts to Public;
Go

--Employees Table: 
--Select * From Employees;
--Select * From vEmployees;
--GO

--Deny access for Public to Employees table and Grant access for Public to vEmployees table:
Deny Select On Employees to Public;
Go
Grant Select On vEmployees to Public;
Go

--Inventories Table:
--Select * From Inventories;
--Select * From vInventories;
--GO

--Deny access for Public to Inventories table and Grant access for Public to vInventories table:
Deny Select On Inventories to Public;
Go
Grant Select On vInventories to Public;
Go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Select * From vCategories;
--GO
--Select * From vProducts;
--GO

--Select CategoryName, ProductName, UnitPrice
  --From dbo.Products Inner Join dbo.Categories
   --On Products.CategoryID = Categories.CategoryID
  --Order By CategoryName, ProductName;
--Go

Go
Create View vProductsByCategories
AS
  Select Top 1000000
  CategoryName, 
  ProductName, 
  UnitPrice
  From vProducts Inner Join vCategories
   On vProducts.CategoryID = vCategories.CategoryID
  Order By CategoryName, ProductName;
Go

--Select * From vProductsByCategories Order By CategoryName, ProductName; 


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--Select * From vProducts;
--GO
--Select * From vInventories;
--GO

--Select ProductName, InventoryDate, (Count)
  --From dbo.Products Inner Join dbo.Inventories
   --On Products.ProductID = Inventories.ProductID
  --Order By ProductName, InventoryDate, Count;
--Go

Go
Create View vInventoriesByProductsByDates
AS
  Select Top 1000000
  ProductName, 
  InventoryDate, 
  (Count)
  From vProducts Inner Join vInventories
   On vProducts.ProductID = vInventories.ProductID
  Order By ProductName, InventoryDate, [Count];
Go

--Select * From vInventoriesByProductsByDates Order By ProductName, InventoryDate, Count;


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

--Select * From vEmployees;
--GO
--Select * From vInventories;
--GO

--Select [InventoryDate] = InventoryDate,
  --[Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
  --From Employees Join Inventories
   --On Employees.EmployeeID = Inventories.EmployeeID
  --Group BY InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName; 
--Go

Go
Create View vInventoriesByEmployeesByDates
As
 Select Top 1000000
 [InventoryDate] = InventoryDate,
 [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
  From vEmployees Join vInventories
   On vEmployees.EmployeeID = vInventories.EmployeeID
  Group BY InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName; 
Go

--Select * From vInventoriesByEmployeesByDates Order By InventoryDate; 


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Select * From vCategories;
--GO
--Select * From vProducts;
--GO
--Select * From vInventories;
--GO

--Select CategoryName, ProductName, InventoryDate, (Count)
 --From Categories
 --Inner Join Products
  --On Categories.CategoryID = Products.CategoryID
 --Inner Join Inventories
  --On Products.ProductID = Inventories.ProductID
 --Order By CategoryName, ProductName, InventoryDate, Count;
--Go

Go
Create View vInventoriesByProductsByCategories
AS
 Select Top 1000000
 CategoryName, 
 ProductName, 
 InventoryDate, 
 (Count)
  From vCategories Inner Join vProducts
   On vCategories.CategoryID = vProducts.CategoryID
  Inner Join vInventories
   On vProducts.ProductID = vInventories.ProductID
  Order By CategoryName, ProductName, InventoryDate, Count;
Go

--Select * From vInventoriesByProductsByCategories Order By CategoryName, ProductName, InventoryDate, [Count];


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Select * From vCategories;
--GO
--Select * From vProducts;
--GO
--Select * From vInventories;
--GO
--Select * From vEmployees;
--GO

--Select CategoryName, ProductName, InventoryDate, (Count), [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
 --From Categories
 --Inner Join Products
  --On Categories.CategoryID = Products.CategoryID
 --Inner Join Inventories
  --On Products.ProductID = Inventories.ProductID
 --Inner Join Employees
  --On Inventories.EmployeeID = Employees.EmployeeID
 --Order By InventoryDate, CategoryName, ProductName, EmployeeFirstName + ' ' + EmployeeLastName; 
--Go

Go
Create View vInventoriesByProductsByEmployees
AS
 Select Top 1000000
 CategoryName, 
 ProductName, 
 InventoryDate, 
 (Count), 
 [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
 From vCategories Inner Join vProducts
  On vCategories.CategoryID = vProducts.CategoryID
 Inner Join vInventories
  On vProducts.ProductID = vInventories.ProductID
 Inner Join vEmployees
  On vInventories.EmployeeID = vEmployees.EmployeeID
 Order By InventoryDate, CategoryName, ProductName, EmployeeFirstName + ' ' + EmployeeLastName; 
Go

--Select * From vInventoriesByProductsByEmployees Order By InventoryDate, CategoryName, ProductName, [Employee Name];


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Select * From vCategories;
--GO
--Select * From vProducts;
--GO
--Select * From vInventories;
--GO
--Select * From vEmployees;
--GO

--Select CategoryName, ProductName, InventoryDate, Count, [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
  --From Categories
  --Inner Join Products
    --On Categories.CategoryID = Products.CategoryID
  --Inner Join Inventories
    --On Products.ProductID = Inventories.ProductID
  --Inner Join Employees
    --On Inventories.EmployeeID = Employees.EmployeeID
  --Where ProductName IN (Select ProductName From Products Where ProductID BETWEEN 1 And 2)
  --Order By InventoryDate, CategoryName, ProductName;
--Go

Go
Create View vInventoriesForChaiAndChangByEmployees
AS
 Select Top 1000000
 CategoryName, 
 ProductName, 
 InventoryDate, 
 Count, 
 [Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
  From vCategories Inner Join vProducts
    On vCategories.CategoryID = vProducts.CategoryID
  Inner Join vInventories
    On vProducts.ProductID = vInventories.ProductID
  Inner Join vEmployees
    On vInventories.EmployeeID = vEmployees.EmployeeID
  Where ProductName IN (Select ProductName From Products Where ProductID BETWEEN 1 And 2)
  Order By InventoryDate, CategoryName, ProductName;
Go

--Select * From vInventoriesForChaiAndChangByEmployees Order By InventoryDate, CategoryName, ProductName;


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Select * From vEmployees;
--GO

--Select 
  --[Manager] = IIF(IsNull(Mgr.EmployeeID, 0) = 0, 'General Manager', Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName),
  --[Employee] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
--From Employees as Emp Left Join Employees Mgr
  --On Emp.ManagerID = Mgr.EmployeeID
--Order By Manager, Employee;
--GO

Go
Create View vEmployeesByManager
AS
 Select Top 1000000
  [Manager] = IIF(IsNull(Mgr.EmployeeID, 0) = 0, 'General Manager', Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName),
  [Employee] = vEmp.EmployeeFirstName + ' ' + vEmp.EmployeeLastName
 From vEmployees as vEmp Left Join vEmployees Mgr
  On vEmp.ManagerID = Mgr.EmployeeID
 Order By Manager, Employee;
GO

--Select * From vEmployeesByManager Order By Manager, Employee;


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--Select * From vCategories;
--GO
--Select * From vProducts;
--GO
--Select * From vInventories;
--GO
--Select * From vEmployees;
--GO
--Select * From vEmployeesByManager;
--GO

--Select  
--CategoryID,
--CategoryName,
--ProductID,
--ProductName, 
--UnitPrice, 
--InventoryID, 
--InventoryDate, 
--[Count], 
--EmployeeID, 
--[Employee] = EmployeeFirstName + ' ' + EmployeeLastName, 
--[Manager] = IIF(IsNull(EmployeeID, 0), 'General Manager', EmployeeFirstName + ' ' + EmployeeLastName)
--From dbo.vProducts Inner Join dbo.vCategories
  --On vCategories.CategoryID = vProducts.CategoryID
  --Inner Join vInventories
  --On vProducts.ProductID = vInventories.ProductID
  --Inner Join vEmployees
  --On vInventories.EmployeeID = vEmployees.EmployeeID
  --Right Join vEmployeesByManager
  --On vEmployees.EmployeeID = vEmployeesByManager.Employee
  --Order By CategoryName, ProductName, InventoryID, [Employee];
--GO

GO
Create View vInventoriesByProductsByCategoriesByEmployees
AS
   Select Top 1000000
   C.CategoryID,
   C.CategoryName,
   P.ProductID,
   P.ProductName,
   P.UnitPrice,
   I.InventoryID,
   I.InventoryDate,
   I.Count,
   E.EmployeeID,
   E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee,
   M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
  From vCategories as C Inner Join vProducts as P
   On P.CategoryID = C.CategoryID
  Inner Join vInventories as I
   On P.ProductID = I.ProductID
  Inner Join vEmployees as E
   On I.EmployeeID = E.EmployeeID
  Inner Join vEmployees as M 
   On E.ManagerID = M.EmployeeID
  Order By CategoryName, ProductName, InventoryID, [Employee];
GO

--Select * From vInventoriesByProductsByCategoriesByEmployees Order By CategoryName, ProductName, InventoryID, [Employee]; 



-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/