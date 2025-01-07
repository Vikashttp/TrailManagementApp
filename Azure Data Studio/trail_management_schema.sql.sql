-- DROP FOREIGN KEY CONSTRAINT IF EXISTS
BEGIN TRY
    ALTER TABLE CW2.Trails DROP CONSTRAINT FK__Trails__OwnerID;
END TRY
BEGIN CATCH
    PRINT 'Foreign Key Constraint does not exist or already dropped.';
END CATCH;

-- DROP ALL DEPENDENT OBJECTS
IF OBJECT_ID('CW2.TrailAddLog', 'TR') IS NOT NULL
    DROP TRIGGER CW2.TrailAddLog;
GO

IF OBJECT_ID('CW2.TrailLog', 'U') IS NOT NULL
    DROP TABLE CW2.TrailLog;
GO

IF OBJECT_ID('CW2.TrailLocations', 'U') IS NOT NULL
    DROP TABLE CW2.TrailLocations;
GO

IF OBJECT_ID('CW2.Trails', 'U') IS NOT NULL
    DROP TABLE CW2.Trails;
GO

IF OBJECT_ID('CW2.Users', 'U') IS NOT NULL
    DROP TABLE CW2.Users;
GO

-- CREATE USERS TABLE
CREATE TABLE CW2.Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Role NVARCHAR(20) NOT NULL -- Roles can be 'Admin', 'Owner', or 'Viewer'
);
GO

-- CREATE TRAILS TABLE
CREATE TABLE CW2.Trails (
    TrailID INT IDENTITY(1,1) PRIMARY KEY,
    TrailName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    OwnerID INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (OwnerID) REFERENCES CW2.Users(UserID)
);
GO

-- CREATE TRAIL LOCATIONS TABLE
CREATE TABLE CW2.TrailLocations (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    TrailID INT NOT NULL,
    Latitude DECIMAL(9,6) NOT NULL,
    Longitude DECIMAL(9,6) NOT NULL,
    SequenceOrder INT NOT NULL, -- Determines the order of locations in the trail
    FOREIGN KEY (TrailID) REFERENCES CW2.Trails(TrailID)
);
GO

-- CREATE TRAIL LOG TABLE
CREATE TABLE CW2.TrailLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TrailID INT NOT NULL,
    UserID INT NOT NULL,
    Action NVARCHAR(50) NOT NULL, -- Example: "Trail Added"
    Timestamp DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (TrailID) REFERENCES CW2.Trails(TrailID),
    FOREIGN KEY (UserID) REFERENCES CW2.Users(UserID)
);
GO

-- INSERT SAMPLE USERS
INSERT INTO CW2.Users (UserName, Email, Role)
VALUES 
    ('Grace Hopper', 'grace@plymouth.ac.uk', 'Owner'),
    ('Tim Berners-Lee', 'tim@plymouth.ac.uk', 'Admin'),
    ('Ada Lovelace', 'ada@plymouth.ac.uk', 'Viewer');
GO

-- INSERT SAMPLE TRAILS
INSERT INTO CW2.Trails (TrailName, Description, OwnerID)
VALUES 
    ('Plymbridge Circular', 'A scenic trail around Plymbridge woods', 1);
GO

-- INSERT SAMPLE TRAIL LOCATIONS
INSERT INTO CW2.TrailLocations (TrailID, Latitude, Longitude, SequenceOrder)
VALUES 
    (1, 50.38959, -4.09147, 1),
    (1, 50.39285, -4.08956, 2),
    (1, 50.39512, -4.08762, 3);
GO

-- CREATE VIEW FOR TRAIL DETAILS
IF OBJECT_ID('CW2.TrailDetails', 'V') IS NOT NULL
    DROP VIEW CW2.TrailDetails;
GO
CREATE VIEW CW2.TrailDetails AS
SELECT 
    T.TrailID,
    T.TrailName,
    T.Description,
    U.UserName AS OwnerName
FROM 
    CW2.Trails T
JOIN 
    CW2.Users U ON T.OwnerID = U.UserID;
GO

-- CREATE STORED PROCEDURES

-- AddTrail Procedure
IF OBJECT_ID('CW2.AddTrail', 'P') IS NOT NULL
    DROP PROCEDURE CW2.AddTrail;
GO
CREATE PROCEDURE CW2.AddTrail
    @TrailName NVARCHAR(100),
    @Description NVARCHAR(MAX),
    @OwnerID INT
AS
BEGIN
    INSERT INTO CW2.Trails (TrailName, Description, OwnerID)
    VALUES (@TrailName, @Description, @OwnerID);
END;
GO

-- GetTrails Procedure
IF OBJECT_ID('CW2.GetTrails', 'P') IS NOT NULL
    DROP PROCEDURE CW2.GetTrails;
GO
CREATE PROCEDURE CW2.GetTrails
AS
BEGIN
    SELECT * FROM CW2.Trails;
END;
GO

-- UpdateTrail Procedure
IF OBJECT_ID('CW2.UpdateTrail', 'P') IS NOT NULL
    DROP PROCEDURE CW2.UpdateTrail;
GO
CREATE PROCEDURE CW2.UpdateTrail
    @TrailID INT,
    @TrailName NVARCHAR(100),
    @Description NVARCHAR(MAX)
AS
BEGIN
    UPDATE CW2.Trails
    SET TrailName = @TrailName,
        Description = @Description
    WHERE TrailID = @TrailID;
END;
GO

-- DeleteTrail Procedure
IF OBJECT_ID('CW2.DeleteTrail', 'P') IS NOT NULL
    DROP PROCEDURE CW2.DeleteTrail;
GO
CREATE PROCEDURE CW2.DeleteTrail
    @TrailID INT
AS
BEGIN
    DELETE FROM CW2.Trails
    WHERE TrailID = @TrailID;
END;
GO

-- CREATE TRIGGER FOR LOGGING TRAIL ADDITIONS
IF OBJECT_ID('CW2.TrailAddLog', 'TR') IS NOT NULL
    DROP TRIGGER CW2.TrailAddLog;
GO
CREATE TRIGGER CW2.TrailAddLog
ON CW2.Trails
AFTER INSERT
AS
BEGIN
    INSERT INTO CW2.TrailLog (TrailID, UserID, Action)
    SELECT 
        INSERTED.TrailID,
        INSERTED.OwnerID,
        'Trail Added'
    FROM INSERTED;
END;
GO

-- TEST INSERT USING AddTrail PROCEDURE
EXEC CW2.AddTrail 
    @TrailName = 'Dartmoor Adventure', 
    @Description = 'Explore the rugged terrain of Dartmoor.', 
    @OwnerID = 1;
GO

-- TEST DATA SELECTION
SELECT * FROM CW2.Users;
SELECT * FROM CW2.Trails;
SELECT * FROM CW2.TrailLocations;
SELECT * FROM CW2.TrailLog;
SELECT * FROM CW2.TrailDetails;
GO
