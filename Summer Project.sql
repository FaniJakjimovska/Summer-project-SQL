
USE master
GO 

DROP DATABASE IF EXISTS 
SummerProject

CREATE DATABASE SummerProject
GO

USE SummerProject
GO

CREATE TABLE dbo.[SeniorityLevel] 
(Id int PRIMARY KEY IDENTITY (1,1) NOT NULL,
Name nvarchar(100) NOT NULL)
GO

CREATE TABLE dbo.[Location]
(Id int	PRIMARY KEY IDENTITY (1,1) NOT NULL,
CountryName nvarchar(100) NULL,
Continent nvarchar(100) NULL,
Region nvarchar(100) NULL)
GO

CREATE TABLE dbo.[Department]
(Id int PRIMARY KEY IDENTITY (1,1) NOT NULL,
Name nvarchar(100) NOT NULL)
GO

CREATE TABLE dbo.[Employee]
(Id int PRIMARY KEY IDENTITY (1,1) NOT NULL,
FirstName nvarchar(100) NOT NULL,
LastName nvarchar(100) NOT NULL,
LocationId int NOT NULL,
SeniorityLevelId int NOT NULL,
DepartmentId int NOT NULL)
GO

CREATE TABLE dbo.[Salary]
(Id int PRIMARY KEY IDENTITY (1,1) NOT NULL,
EmployeeId int NOT NULL,
Month smallint NOT NULL,
Year smallint NOT NULL,
GrossAmount decimal(18,2) NOT NULL,
NetAmount decimal(18,2) NOT NULL,
RegularWorkAmount decimal(18,2) NOT NULL,
BonusAmount decimal(18,2) NOT NULL,
OvertimeAmount decimal(18,2) NOT NULL,
VacationDays smallint NOT NULL,
SickLeaveDays smallint NOT NULL)
GO



--references
ALTER TABLE dbo.[Salary]  WITH CHECK ADD  CONSTRAINT FK_Employee_Salary FOREIGN KEY (EmployeeId)  
REFERENCES dbo.Employee(Id)
GO

ALTER TABLE dbo.Employee WITH CHECK ADD CONSTRAINT FK_Location_Employee FOREIGN KEY (LocationId)  
REFERENCES dbo.Location(Id)
GO

ALTER TABLE dbo.Employee WITH CHECK ADD CONSTRAINT FK_SeniorityLevel_Employee FOREIGN KEY (SeniorityLevelId)  
REFERENCES dbo.SeniorityLevel(Id)
GO

ALTER TABLE dbo.Employee WITH CHECK ADD CONSTRAINT FK_Department_Employee FOREIGN KEY (DepartmentId)  
REFERENCES dbo.Department(Id)
GO

--Insert Data
INSERT INTO dbo.SeniorityLevel (Name)
VALUES ('Junior'), ('Intermediate'), ('Senior'), ('Lead'), ('Project Manager'), ('Division Manager'), 
('Office Manager'), ('CEO'), ('CTO'), ('CIO')
GO

--SELECT * FROM dbo.SeniorityLevel

INSERT INTO dbo.Location (CountryName, Continent, Region)
SELECT CountryName, Continent, Region
FROM WideWorldImporters.Application.Countries 
GO

--SELECT * FROM dbo.Location

INSERT INTO dbo.Department (Name)
VALUES ('Personal Banking & Operations'), ('Digital Banking Department'), 
('Retail Banking & Marketing Department'), ('Wealth Management & Third Party Products'), 
('International Banking Division & DFB'), ('Treasury'), ('Information Technology'), 
('Corporate Communications'), ('Support Services & Branch Expansion'), ('Human Resources')
GO

--SELECT * FROM dbo.Department

INSERT INTO dbo.Employee (FirstName, LastName, LocationId, SeniorityLevelId, DepartmentId)
SELECT SUBSTRING(FullName, 1, CHARINDEX(' ', FullName ) - 1) AS [FirstName],
       SUBSTRING(FullName , CHARINDEX(' ', FullName ) + 1, LEN(FullName )) AS [LastName],
	   PersonID % 190 + 1, PersonID % 10 + 1, PersonID % 10 + 1
FROM WideWorldImporters.Application.People

GO

--SELECT * FROM dbo.Employee 

--SELECT * FROM WideWorldImporters.Application.People



DECLARE @Year INT = 2001;
DECLARE @Month INT = 1;
DECLARE @EmployeeCount INT = (SELECT COUNT(*) FROM Employee);
DECLARE @EmployeeId INT = 1;

WHILE @Year <= 2020
BEGIN
    SET @Month = 1;
    
    WHILE @Month <= 12
    BEGIN
        -- For each employee, calculate NetAmount, BonusAmount, OvertimeAmount, VacationDays, and SickLeaveDays.
        -- The random SummerProject is now generated per employee.

        -- Insert the SummerProject data for each employee with a random GrossAmount
        INSERT INTO Salary (EmployeeId, Month, Year, GrossAmount, NetAmount, RegularWorkAmount, 
            BonusAmount, OvertimeAmount, VacationDays, SickLeaveDays)
        SELECT
            Id AS EmployeeId,
            @Month AS Month,
            @Year AS Year,
			ABS(CHECKSUM(NEWID()))%30000 + 30001 AS GrossAmount,
            0 AS NetAmount,
            0 AS RegularWorkAmount,
            0 AS BonusAmount,
            0 AS OvertimeAmount,
            0 AS VacationDays,
            0 AS SickLeaveDays
        FROM Employee;

        SET @Month = @Month + 1;
    END

    SET @Year = @Year + 1;
END

UPDATE dbo.Salary
SET NetAmount = 0.9 * GrossAmount
GO

UPDATE dbo.Salary
SET RegularWorkAmount = 0.8 * GrossAmount
GO

UPDATE dbo.Salary
SET NetAmount = 0.9 * GrossAmount
GO

UPDATE dbo.Salary
SET BonusAmount = NetAmount - RegularWorkAmount
WHERE Month % 2 = 1
GO

UPDATE dbo.Salary
SET OvertimeAmount = NetAmount - RegularWorkAmount
WHERE Month % 2 = 0
GO

UPDATE dbo.Salary
SET VacationDays = 10 
WHERE Month in (7, 12)
GO

---- Update vacationDays and SickLeaveDays based on the provided script
UPDATE dbo.Salary
SET VacationDays = VacationDays + (EmployeeId % 2)
WHERE (EmployeeId + Month + Year) % 5 = 1
GO

UPDATE dbo.Salary
SET SickLeaveDays = EmployeeId % 8,
    VacationDays = VacationDays + (EmployeeId % 3)
WHERE (EmployeeId + Month + Year) % 5 = 2
GO

---- Verify that no employee has incorrect NetAmount as per the provided query
SELECT *
FROM Salary
WHERE NetAmount <> (RegularWorkAmount + BonusAmount + OvertimeAmount);
GO

--Verify that vacation days are between 20 and 30 for each employee
SELECT SUM(VacationDays) AS Num
FROM dbo.Salary
GROUP BY EmployeeId,Year
HAVING SUM(VacationDays)<20 or SUM(VacationDays)>30 
GO

SELECT *
FROM Salary


