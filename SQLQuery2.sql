CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Password NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Address NVARCHAR(255),
    MobileNo NVARCHAR(15),
    IsAdmin BIT DEFAULT 0,
    DateCreated DATETIME DEFAULT GETDATE()
);


CREATE TABLE Categories(
    CategoryID INT PRIMARY KEY IDENTITY,
    CategoryName NVARCHAR(50) NOT NULL,
    ImageUrl NVARCHAR(255),
    DateCreated DATETIME DEFAULT GETDATE()
);


CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Price DECIMAL(10, 2) NOT NULL,
    ImageUrl NVARCHAR(255)
);

select * from Products

ALTER TABLE Products
ADD Quantity INT NOT NULL DEFAULT 0;



USE RESTURANT;
GO
CREATE PROCEDURE RegisterUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(50),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @MobileNo NVARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = @Username OR Email = @Email)
    BEGIN
        INSERT INTO Users (Username, Password, Email, Address, MobileNo)
        VALUES (@Username, @Password, @Email, @Address, @MobileNo)
    END
    ELSE
    BEGIN
        DECLARE @ErrorMessage NVARCHAR(255) = 'Username or Email already exists';
        THROW 50000, @ErrorMessage, 1;
    END
END;
GO

-- LoginUser stored procedure
CREATE PROCEDURE LoginUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserID, Username, Email, Address, MobileNo, IsAdmin
    FROM Users
    WHERE Username = @Username AND Password = @Password;

    IF @@ROWCOUNT = 0
    BEGIN
        DECLARE @ErrorMessage NVARCHAR(255) = 'Invalid username or password';
        THROW 50001, @ErrorMessage, 1;
    END
END;
GO

CREATE PROCEDURE GetAllCategories
AS
BEGIN
    SELECT CategoryID, CategoryName, ImageUrl, DateCreated FROM Categories;
END


CREATE PROCEDURE InsertCategory
    @CategoryName NVARCHAR(50),
    @ImageUrl NVARCHAR(255)
AS
BEGIN
    INSERT INTO Categories (CategoryName, ImageUrl)
    VALUES (@CategoryName, @ImageUrl)
END
GO

-- Stored procedure for updating a category
CREATE PROCEDURE UpdateCategory
    @CategoryID INT,
    @CategoryName NVARCHAR(50),
    @ImageUrl NVARCHAR(255)
AS
BEGIN
    UPDATE Categories
    SET CategoryName = @CategoryName, ImageUrl = @ImageUrl
    WHERE CategoryID = @CategoryID
END
GO

-- Stored procedure for deleting a category
CREATE PROCEDURE DeleteCategory
    @CategoryID INT
AS
BEGIN
    DELETE FROM Categories
    WHERE CategoryID = @CategoryID
END
GO







-- Stored Procedure to Get All Products
CREATE PROCEDURE GetAllProducts
AS
BEGIN
    SELECT ProductID, CategoryID, ProductName, Description, Price, ImageUrl
    FROM Products;
END
GO

-- Stored Procedure to Insert a New Product
CREATE PROCEDURE InsertProduct
    @CategoryID INT,
    @ProductName NVARCHAR(100),
    @Description NVARCHAR(255),
    @Price DECIMAL(10, 2),
    @ImageUrl NVARCHAR(255)
AS
BEGIN
    INSERT INTO Products (CategoryID, ProductName, Description, Price, ImageUrl)
    VALUES (@CategoryID, @ProductName, @Description, @Price, @ImageUrl);
END
GO

-- Stored Procedure to Update an Existing Product
CREATE PROCEDURE UpdateProduct
    @ProductID INT,
    @CategoryID INT,
    @ProductName NVARCHAR(100),
    @Description NVARCHAR(255),
    @Price DECIMAL(10, 2),
    @ImageUrl NVARCHAR(255)
AS
BEGIN
    UPDATE Products
    SET CategoryID = @CategoryID,
        ProductName = @ProductName,
        Description = @Description,
        Price = @Price,
        ImageUrl = @ImageUrl
    WHERE ProductID = @ProductID;
END
GO

-- Stored Procedure to Delete a Product
CREATE PROCEDURE DeleteProduct
    @ProductID INT
AS
BEGIN
    DELETE FROM Products
    WHERE ProductID = @ProductID;
END
GO


CREATE PROCEDURE GetCategoryById
    @CategoryID INT
AS
BEGIN
    SELECT CategoryID, CategoryName
    FROM Categories
    WHERE CategoryID = @CategoryID;
END;





ALTER PROCEDURE InsertProduct
    @CategoryID INT,
    @ProductName NVARCHAR(100),
    @Description NVARCHAR(255),
    @Price DECIMAL(10, 2),
    @ImageUrl NVARCHAR(255),
    @Quantity INT  -- Add Quantity parameter
AS
BEGIN
    INSERT INTO Products (CategoryID, ProductName, Description, Price, ImageUrl, Quantity)
    VALUES (@CategoryID, @ProductName, @Description, @Price, @ImageUrl, @Quantity);
END





ALTER PROCEDURE UpdateProduct
    @ProductID INT,
    @CategoryID INT,
    @ProductName NVARCHAR(100),
    @Description NVARCHAR(255),
    @Price DECIMAL(10, 2),
    @ImageUrl NVARCHAR(255),
    @Quantity INT  -- Add Quantity parameter
AS
BEGIN
    UPDATE Products
    SET CategoryID = @CategoryID,
        ProductName = @ProductName,
        Description = @Description,
        Price = @Price,
        ImageUrl = @ImageUrl,
        Quantity = @Quantity  -- Update Quantity
    WHERE ProductID = @ProductID;
END



CREATE PROCEDURE DeleteProductsByCategoryID
    @CategoryID INT
AS
BEGIN
    DELETE FROM Products WHERE CategoryID = @CategoryID;
END;










-- Create stored procedure to delete a user by UserID
CREATE PROCEDURE DeleteUser
    @UserID INT
AS
BEGIN
    DELETE FROM Users WHERE UserID = @UserID;
END
GO

-- Create stored procedure to retrieve all users
CREATE PROCEDURE GetAllUsers
AS
BEGIN
    SELECT * FROM Users;
END
GO




CREATE PROCEDURE GetRevenueData
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT 
        u.Username,
        u.Email,
        o.OrderDate,
        od.ProductID,
        p.ProductName,
        od.Quantity,
        od.Price,
        (od.Quantity * od.Price) AS TotalCost
    FROM 
        Orders o
    JOIN 
        Users u ON o.UserID = u.UserID
    JOIN 
        OrderDetails od ON o.OrderID = od.OrderID
    JOIN 
        Products p ON od.ProductID = p.ProductID
    WHERE 
        o.OrderDate BETWEEN @StartDate AND @EndDate;
END;





-- Stored procedure to insert a new reservation



CREATE PROCEDURE GetProductsByCategoryId
    @CategoryID INT
AS
BEGIN
    SELECT ProductID, CategoryID, ProductName, Description, Price, ImageUrl, Quantity
    FROM Products
    WHERE CategoryID = @CategoryID;
END
GO


CREATE PROCEDURE GetUserDetails
    @UserID INT
AS
BEGIN
    SELECT UserID, Username, Password, Email, Address, MobileNo, DateCreated
    FROM Users
    WHERE UserID = @UserID
END





CREATE PROCEDURE GetUserPurchaseHistory
    @UserID INT
AS
BEGIN
    SELECT PurchaseID, ProductName, Quantity, PurchaseDate, TotalPrice
    FROM Purchases
    WHERE UserID = @UserID
END






CREATE VIEW UserPurchaseHistory AS
SELECT 
    o.OrderID,
    o.UserID,
    o.OrderDate AS PurchaseDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    (od.Quantity * od.Price) AS TotalPrice
FROM 
    Orders o
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID;






IF OBJECT_ID('GetUserPurchaseHistory', 'P') IS NOT NULL
    DROP PROCEDURE GetUserPurchaseHistory;
GO

CREATE PROCEDURE GetUserPurchaseHistory
    @UserID INT
AS
BEGIN
    SELECT 
        o.OrderID,
        o.OrderDate AS PurchaseDate,
        od.ProductID,
        p.ProductName,
        od.Quantity,
        (od.Quantity * od.Price) AS TotalPrice
    FROM 
        Orders o
    JOIN 
        OrderDetails od ON o.OrderID = od.OrderID
    JOIN 
        Products p ON od.ProductID = p.ProductID
    WHERE 
        o.UserID = @UserID;
END
GO




CREATE PROCEDURE UpdateUserDetails
    @UserID INT,
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @MobileNo NVARCHAR(15)
AS
BEGIN
    UPDATE Users
    SET Username = @Username,
        Email = @Email,
        Address = @Address,
        MobileNo = @MobileNo
    WHERE UserID = @UserID;
END






CREATE TABLE UserChanges (
    ChangeID INT PRIMARY KEY IDENTITY,
    UserID INT,
    ChangedColumn NVARCHAR(50),
    OldValue NVARCHAR(255),
    NewValue NVARCHAR(255),
    ChangeDate DATETIME DEFAULT GETDATE()
);






	




	CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    TotalAmount DECIMAL(18, 2) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) -- Assuming you have a Users table
);

-- Create OrderDetails Table
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) -- Assuming you have a Products table
);

-- Create CartItems Table
CREATE TABLE CartItems (
    CartItemID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID), -- Assuming you have a Users table
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) -- Assuming you have a Products table
);



CREATE PROCEDURE GetCartItems
    @UserID INT
AS
BEGIN
    SELECT 
        ci.CartItemID,
        ci.UserID,
        ci.ProductID,
        ci.Quantity,
        p.ProductName,
        p.Price,
        p.ImageUrl -- Ensure this column is included
    FROM 
        CartItems ci
    JOIN 
        Products p ON ci.ProductID = p.ProductID
    WHERE 
        ci.UserID = @UserID
END




CREATE PROCEDURE AddProductToCart
    @UserID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    INSERT INTO CartItems (UserID, ProductID, Quantity)
    VALUES (@UserID, @ProductID, @Quantity)
END



CREATE PROCEDURE CreateOrder
    @UserID INT,
    @OrderDate DATETIME,
    @TotalAmount DECIMAL(18, 2)
AS
BEGIN
    INSERT INTO Orders (UserID, OrderDate, TotalAmount, Status)
    VALUES (@UserID, @OrderDate, @TotalAmount, 'Pending');
    
    SELECT SCOPE_IDENTITY(); -- Returns the ID of the newly created order
END

CREATE PROCEDURE InsertOrderDetail
    @OrderID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
    VALUES (@OrderID, @ProductID, @Quantity)
END



CREATE PROCEDURE ClearCart
    @UserID INT
AS
BEGIN
    DELETE FROM CartItems
    WHERE UserID = @UserID
END



CREATE PROCEDURE GetOrderDetailsByOrderId
    @OrderID INT
AS
BEGIN
    SELECT od.OrderDetailID, od.OrderID, od.ProductID, od.Quantity, p.ProductName, p.Price
    FROM OrderDetails od
    INNER JOIN Products p ON od.ProductID = p.ProductID
    WHERE od.OrderID = @OrderID
END


CREATE PROCEDURE UpdateOrderStatus
    @OrderID INT,
    @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Orders
    SET Status = @Status
    WHERE OrderID = @OrderID;
END;


CREATE PROCEDURE GetOrderById
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        OrderID,
        UserID,
        OrderDate,
        TotalAmount,
        Status
    FROM Orders
    WHERE OrderID = @OrderID;
END;









-- Table for storing receipts
CREATE TABLE Receipts (
    ReceiptID INT PRIMARY KEY IDENTITY,
    OrderID INT,
    UserID INT,
    ReceiptDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Table for storing customer-specific details for each order
CREATE TABLE CustomerDetails (
    DetailID INT PRIMARY KEY IDENTITY,
    OrderID INT,
    CustomerName NVARCHAR(100),
    CustomerAddress NVARCHAR(255),
    CustomerEmail NVARCHAR(100),
    CustomerPhone NVARCHAR(15),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


-- Stored Procedure to add product to cart
CREATE PROCEDURE AddProductToCart
    @UserID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM CartItems WHERE UserID = @UserID AND ProductID = @ProductID)
    BEGIN
        UPDATE CartItems
        SET Quantity = Quantity + @Quantity
        WHERE UserID = @UserID AND ProductID = @ProductID;
    END
    ELSE
    BEGIN
        INSERT INTO CartItems (UserID, ProductID, Quantity)
        VALUES (@UserID, @ProductID, @Quantity);
    END
END;

-- Stored Procedure to create an order with customer details and generate a receipt
CREATE PROCEDURE CreateOrderWithDetails
    @UserID INT,
    @OrderDate DATETIME,
    @TotalAmount DECIMAL(18, 2),
    @CustomerName NVARCHAR(100),
    @CustomerAddress NVARCHAR(255),
    @CustomerEmail NVARCHAR(100),
    @CustomerPhone NVARCHAR(15)
AS
BEGIN
    BEGIN TRANSACTION;

    -- Insert into Orders table
    INSERT INTO Orders (UserID, OrderDate, TotalAmount, Status)
    VALUES (@UserID, @OrderDate, @TotalAmount, 'Pending');
    
    DECLARE @OrderID INT = SCOPE_IDENTITY();

    -- Insert into CustomerDetails table
    INSERT INTO CustomerDetails (OrderID, CustomerName, CustomerAddress, CustomerEmail, CustomerPhone)
    VALUES (@OrderID, @CustomerName, @CustomerAddress, @CustomerEmail, @CustomerPhone);

    -- Insert order details from CartItems
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
    SELECT @OrderID, ProductID, Quantity
    FROM CartItems
    WHERE UserID = @UserID;

    -- Clear cart after order is placed
    DELETE FROM CartItems
    WHERE UserID = @UserID;

    -- Generate receipt
    EXEC GenerateReceipt @OrderID = @OrderID, @UserID = @UserID, @TotalAmount = @TotalAmount;

    COMMIT TRANSACTION;
END;

-- Stored Procedure to generate a receipt
CREATE PROCEDURE GenerateReceipt
    @OrderID INT,
    @UserID INT,
    @TotalAmount DECIMAL(18, 2)
AS
BEGIN
    INSERT INTO Receipts (OrderID, UserID, TotalAmount)
    VALUES (@OrderID, @UserID, @TotalAmount);
END;



CREATE PROCEDURE GetAvailableTables
    @ReservationDate DATETIME,
    @NumberOfCustomers INT
AS
BEGIN
    SELECT t.TableID, t.TableSize, t.Location
    FROM Tables t
    WHERE t.TableSize >= @NumberOfCustomers
      AND NOT EXISTS (
          SELECT 1
          FROM Reservations r
          WHERE r.TableID = t.TableID
            AND r.ReservationDate = @ReservationDate
      )
END

























CREATE TABLE Tables (
    TableID INT PRIMARY KEY IDENTITY(1,1),
    TableSize INT NOT NULL,
    Location VARCHAR(255)
);

CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    TableID INT NOT NULL,
    ReservationDate DATETIME NOT NULL,
    NumberOfCustomers INT NOT NULL,
    EventDetails VARCHAR(255),
    CONSTRAINT FK_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Table FOREIGN KEY (TableID) REFERENCES Tables(TableID)
);



CREATE PROCEDURE GetAvailableTables
    @ReservationDate DATETIME,
    @NumberOfCustomers INT
AS
BEGIN
    SELECT * 
    FROM Tables
    WHERE TableSize >= @NumberOfCustomers
      AND TableID NOT IN (
          SELECT TableID 
          FROM Reservations
          WHERE CAST(ReservationDate AS DATE) = CAST(@ReservationDate AS DATE)
      );
END;









-- Procedure to get all reservations
CREATE PROCEDURE GetAllReservations
AS
BEGIN
    SELECT r.ReservationID, r.UserID, r.TableID, r.ReservationDate, r.NumberOfCustomers, 
           r.EventDetails, t.TableSize, u.UserName
    FROM Reservations r
    JOIN Tables t ON r.TableID = t.TableID
    JOIN Users u ON r.UserID = u.UserID
END


CREATE PROCEDURE GetReservationById
    @ReservationID INT
AS
BEGIN
    SELECT r.ReservationID, r.UserID, r.TableID, r.ReservationDate, r.NumberOfCustomers, 
           r.EventDetails, t.TableSize, u.UserName
    FROM Reservations r
    JOIN Tables t ON r.TableID = t.TableID
    JOIN Users u ON r.UserID = u.UserID
    WHERE r.ReservationID = @ReservationID
END



CREATE PROCEDURE UpdateReservationStatus
    @ReservationID INT,
    @Status NVARCHAR(50)
AS
BEGIN
    UPDATE Reservations
    SET Status = @Status
    WHERE ReservationID = @ReservationID
END


CREATE PROCEDURE GetReservationDetailsByReservationId
    @ReservationID INT
AS
BEGIN
    SELECT rd.ReservationDetailID, rd.ReservationID, rd.AdditionalInfo
    FROM ReservationDetails rd
    WHERE rd.ReservationID = @ReservationID
END





-- Procedure to create a reservation
CREATE PROCEDURE CreateReservation
    @UserID INT,
    @TableID INT,
    @ReservationDate DATETIME,
    @NumberOfCustomers INT,
    @EventDetails VARCHAR(255)
AS
BEGIN
    INSERT INTO Reservations (UserID, TableID, ReservationDate, NumberOfCustomers, EventDetails)
    VALUES (@UserID, @TableID, @ReservationDate, @NumberOfCustomers, @EventDetails);
END;

-- Procedure to get all reservations
CREATE PROCEDURE GetAllReservations
AS
BEGIN
    SELECT r.ReservationID, r.UserID, r.TableID, r.ReservationDate, r.NumberOfCustomers, r.EventDetails,
           t.TableSize, u.UserName
    FROM Reservations r
    JOIN Tables t ON r.TableID = t.TableID
    JOIN Users u ON r.UserID = u.UserID;
END;





ALTER TABLE Reservations
ADD Status NVARCHAR(50) DEFAULT 'Pending';



CREATE PROCEDURE GetAllReservations
AS
BEGIN
    SELECT r.ReservationID, r.UserID, r.TableID, r.ReservationDate, r.NumberOfCustomers, 
           r.EventDetails, r.Status, t.TableSize, u.UserName
    FROM Reservations r
    JOIN Tables t ON r.TableID = t.TableID
    JOIN Users u ON r.UserID = u.UserID;
END;





CREATE PROCEDURE GetReservationById
    @ReservationID INT
AS
BEGIN
    SELECT r.ReservationID, r.UserID, r.TableID, r.ReservationDate, r.NumberOfCustomers, 
           r.EventDetails, r.Status, t.TableSize, u.UserName
    FROM Reservations r
    JOIN Tables t ON r.TableID = t.TableID
    JOIN Users u ON r.UserID = u.UserID
    WHERE r.ReservationID = @ReservationID;
END;



CREATE PROCEDURE UpdateReservationStatus
    @ReservationID INT,
    @Status NVARCHAR(50)
AS
BEGIN
    UPDATE Reservations
    SET Status = @Status
    WHERE ReservationID = @ReservationID;
END;
