CREATE DATABASE ELibrary;
GO
USE ELibrary;
GO

-- Table: Users
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) CHECK (Role IN ('Student', 'Researcher', 'Admin')) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table: Categories
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) UNIQUE NOT NULL,
    Description VARCHAR(255)
);

-- Table: ResearchPapers
CREATE TABLE ResearchPapers (
    PaperID INT IDENTITY(1,1) PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    Abstract TEXT,
    FilePath VARCHAR(255) NOT NULL,
    UploadDate DATETIME DEFAULT GETDATE(),
    CategoryID INT NOT NULL,
    UploadedBy INT NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (UploadedBy) REFERENCES Users(UserID)
);

-- Table: Authors
CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    AuthorName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE
);

-- Table: PaperAuthors (Many-to-Many between ResearchPapers and Authors)
CREATE TABLE PaperAuthors (
    PaperID INT NOT NULL,
    AuthorID INT NOT NULL,
    PRIMARY KEY (PaperID, AuthorID),
    FOREIGN KEY (PaperID) REFERENCES ResearchPapers(PaperID),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

-- Table: Citations (Self-Relationship for Research Papers)
CREATE TABLE Citations (
    CitingPaperID INT NOT NULL,
    CitedPaperID INT NOT NULL,
    PRIMARY KEY (CitingPaperID, CitedPaperID),
    FOREIGN KEY (CitingPaperID) REFERENCES ResearchPapers(PaperID),
    FOREIGN KEY (CitedPaperID) REFERENCES ResearchPapers(PaperID)
);

-- Table: Reviews
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    PaperID INT NOT NULL,
    UserID INT NOT NULL,
    ReviewText VARCHAR(500),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    ReviewDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (PaperID) REFERENCES ResearchPapers(PaperID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Table: Recommendations
CREATE TABLE Recommendations (
    RecommendationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    PaperID INT NOT NULL,
    Reason VARCHAR(255),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (PaperID) REFERENCES ResearchPapers(PaperID)
);

-- Table: PlagiarismReports
CREATE TABLE PlagiarismReports (
    ReportID INT IDENTITY(1,1) PRIMARY KEY,
    PaperID INT NOT NULL,
    CheckedAgainstPaperID INT NULL,
    SimilarityPercentage DECIMAL(5,2) CHECK (SimilarityPercentage BETWEEN 0 AND 100),
    ReportDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (PaperID) REFERENCES ResearchPapers(PaperID),
    FOREIGN KEY (CheckedAgainstPaperID) REFERENCES ResearchPapers(PaperID)
);

-- Insert Sample Data (DML)
INSERT INTO Users (FullName, Email, PasswordHash, Role) VALUES
('Moaz Kashif', 'moaz@example.com', 'hashedpass1', 'Student'),
('Umer Khalid', 'umer@example.com', 'hashedpass2', 'Researcher'),
('Hamza Mumtaz', 'hamza@example.com', 'hashedpass3', 'Admin');

INSERT INTO Categories (CategoryName, Description) VALUES
('Computer Science', 'Research in CS and IT'),
('Physics', 'Research in Physics'),
('Mathematics', 'Research in Pure and Applied Math');

INSERT INTO Authors (AuthorName, Email) VALUES
('Dr. Ali Ahmed', 'ali.ahmed@uni.edu'),
('Prof. Sara Khan', 'sara.khan@uni.edu');

INSERT INTO ResearchPapers (Title, Abstract, FilePath, CategoryID, UploadedBy) VALUES
('AI in Healthcare', 'This paper discusses AI applications in healthcare.', 'uploads/ai_healthcare.pdf', 1, 1),
('Quantum Mechanics Study', 'Advanced research on quantum mechanics.', 'uploads/quantum.pdf', 2, 2);

INSERT INTO PaperAuthors (PaperID, AuthorID) VALUES
(1, 1),
(1, 2),
(2, 2);

INSERT INTO Citations (CitingPaperID, CitedPaperID) VALUES
(1, 2);

INSERT INTO Reviews (PaperID, UserID, ReviewText, Rating) VALUES
(1, 2, 'Very informative and well-written.', 5),
(2, 1, 'Difficult to understand, but good research.', 4);

INSERT INTO Recommendations (UserID, PaperID, Reason) VALUES
(1, 2, 'Based on your interest in Physics'),
(2, 1, 'Similar to your recent uploads');

INSERT INTO PlagiarismReports (PaperID, CheckedAgainstPaperID, SimilarityPercentage) VALUES
(1, 2, 35.50),
(2, NULL, 5.00);

-- CRUD Operations Example
-- Create
INSERT INTO Users (FullName, Email, PasswordHash, Role) 
VALUES 
('Test User', 'test@example.com', 'testpass', 'Student');

-- Read
SELECT * FROM ResearchPapers;

-- Update
UPDATE Users SET FullName = 'Moaz Updated' WHERE UserID = 1;

-- Delete
DELETE FROM Users WHERE UserID = 4;

select* from Users;

USE ELibrary;
GO

------------------------------------------------------------
-- 1️ SCHEMA ENHANCEMENTS (Data Integrity & Constraints)
------------------------------------------------------------

ALTER TABLE ResearchPapers
ALTER COLUMN Title VARCHAR(200) NOT NULL;

ALTER TABLE Authors
ALTER COLUMN AuthorName VARCHAR(100) NOT NULL;

-- Composite unique constraint for PaperAuthors
ALTER TABLE PaperAuthors
ADD CONSTRAINT UQ_PaperAuthor UNIQUE (PaperID, AuthorID);

-- Constraint to avoid duplicate Recommendations
ALTER TABLE Recommendations
ADD CONSTRAINT UQ_UserPaperRecommendation UNIQUE (UserID, PaperID);

------------------------------------------------------------
-- 2️ REFERENTIAL INTEGRITY TEST (Demonstration)
------------------------------------------------------------

-- This should FAIL because CategoryID 999 does not exist
INSERT INTO ResearchPapers (Title, Abstract, FilePath, CategoryID, UploadedBy)
VALUES ('Invalid Test', 'Testing referential integrity', 'file.pdf', 999, 1);

------------------------------------------------------------
-- 3️ CRUD OPERATIONS TESTS
------------------------------------------------------------

-- Create
INSERT INTO Users (FullName, Email, PasswordHash, Role)
VALUES ('Test Student', 'student@test.com', 'hashedpass', 'Student');

-- Read
SELECT * FROM Users WHERE Email = 'student@test.com';

-- Update
UPDATE Users SET FullName = 'Updated Student'
WHERE Email = 'student@test.com';

-- Delete
DELETE FROM Users WHERE Email = 'student@test.com';

------------------------------------------------------------
-- 4️ REPORTING & RETRIEVAL VIEWS
------------------------------------------------------------

-- View 1: Detailed Research Paper Information
CREATE VIEW vw_ResearchPaperDetails AS
SELECT 
    rp.PaperID,
    rp.Title,
    c.CategoryName,
    u.FullName AS UploadedBy,
    rp.UploadDate
FROM ResearchPapers rp
JOIN Categories c ON rp.CategoryID = c.CategoryID
JOIN Users u ON rp.UploadedBy = u.UserID;

-- View 2: Reviews Summary (Average Rating per Paper)
CREATE VIEW vw_PaperReviews AS
SELECT 
    rp.Title,
    AVG(r.Rating) AS AverageRating,
    COUNT(r.ReviewID) AS TotalReviews
FROM ResearchPapers rp
LEFT JOIN Reviews r ON rp.PaperID = r.PaperID
GROUP BY rp.Title;

-- View 3: Author Contribution Overview
CREATE VIEW vw_AuthorContributions AS
SELECT 
    a.AuthorName,
    COUNT(pa.PaperID) AS TotalPapers
FROM Authors a
LEFT JOIN PaperAuthors pa ON a.AuthorID = pa.AuthorID
GROUP BY a.AuthorName;

------------------------------------------------------------
-- 5️ STORED PROCEDURES
------------------------------------------------------------

-- Procedure 1: Add a new research paper
CREATE PROCEDURE sp_AddResearchPaper
    @Title VARCHAR(200),
    @Abstract TEXT,
    @FilePath VARCHAR(255),
    @CategoryID INT,
    @UploadedBy INT
AS
BEGIN
    INSERT INTO ResearchPapers (Title, Abstract, FilePath, CategoryID, UploadedBy)
    VALUES (@Title, @Abstract, @FilePath, @CategoryID, @UploadedBy);
END;

-- Procedure 2: Get all papers under a specific category
CREATE PROCEDURE sp_GetPapersByCategory
    @CategoryName VARCHAR(100)
AS
BEGIN
    SELECT rp.Title, rp.UploadDate, u.FullName AS UploadedBy
    FROM ResearchPapers rp
    JOIN Categories c ON rp.CategoryID = c.CategoryID
    JOIN Users u ON rp.UploadedBy = u.UserID
    WHERE c.CategoryName = @CategoryName;
END;

-- Procedure 3: Add a Review
CREATE PROCEDURE sp_AddReview
    @PaperID INT,
    @UserID INT,
    @ReviewText VARCHAR(500),
    @Rating INT
AS
BEGIN
    INSERT INTO Reviews (PaperID, UserID, ReviewText, Rating)
    VALUES (@PaperID, @UserID, @ReviewText, @Rating);
END;

-- Procedure 4: Get Plagiarism Reports above threshold
CREATE PROCEDURE sp_GetHighPlagiarismReports
    @Threshold DECIMAL(5,2)
AS
BEGIN
    SELECT 
        rp1.Title AS PaperTitle,
        rp2.Title AS CheckedAgainst,
        pr.SimilarityPercentage
    FROM PlagiarismReports pr
    JOIN ResearchPapers rp1 ON pr.PaperID = rp1.PaperID
    LEFT JOIN ResearchPapers rp2 ON pr.CheckedAgainstPaperID = rp2.PaperID
    WHERE pr.SimilarityPercentage > @Threshold;
END;

------------------------------------------------------------
-- 6️ TESTING STORED PROCEDURES
------------------------------------------------------------

EXEC sp_AddResearchPaper 'New AI Paper', 'AI in Education', 'uploads/ai_edu.pdf', 1, 1;
EXEC sp_GetPapersByCategory 'Computer Science';
EXEC sp_AddReview 1, 2, 'Excellent work!', 5;
EXEC sp_GetHighPlagiarismReports 30.0;

select* from vw_ResearchPaperDetails

