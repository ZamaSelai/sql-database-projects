-- ============================================================
-- Campus Database (MySQL)
-- Students, lecturers, courses, enrolments and dependants.
-- Shows: table design, primary and foreign keys, cascading
-- deletes, CHECK constraints, INSERT/UPDATE/DELETE, aggregate
-- queries, GROUP BY, JOINs and a stored procedure.
-- All names and emails are made-up sample data.
-- ============================================================

DROP DATABASE IF EXISTS campus_db;
CREATE DATABASE campus_db;
USE campus_db;

-- ---------- TABLES ----------
-- Parent tables first, so foreign keys have something to point to.

CREATE TABLE student (
    StudentID    INT PRIMARY KEY NOT NULL,
    FirstName    VARCHAR(45),
    LastName     VARCHAR(45),
    EmailAddress VARCHAR(100)
);

CREATE TABLE lecturer (
    LecturerID INT PRIMARY KEY,
    LectName   VARCHAR(100) NOT NULL,
    LectEmail  VARCHAR(100)
);

CREATE TABLE course (
    CourseCode VARCHAR(20) PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    Credits    INT,
    LecturerID INT,
    CONSTRAINT fk_course_lecturer
        FOREIGN KEY (LecturerID) REFERENCES lecturer(LecturerID)
);

CREATE TABLE enrolment (
    StudentID     INT NOT NULL,
    CourseCode    VARCHAR(20) NOT NULL,
    EnrolmentDate DATE DEFAULT (CURRENT_DATE),
    Grade         DECIMAL(5,2),
    PRIMARY KEY (StudentID, CourseCode),
    FOREIGN KEY (StudentID)  REFERENCES student(StudentID)
        ON DELETE CASCADE,
    FOREIGN KEY (CourseCode) REFERENCES course(CourseCode)
        ON DELETE CASCADE
);

CREATE TABLE dependant (
    StudentID     INT NOT NULL,
    DependentName VARCHAR(50) NOT NULL,
    Relationship  VARCHAR(30) NOT NULL,
    Age           INT CHECK (Age > 0),
    PRIMARY KEY (StudentID, DependentName),
    FOREIGN KEY (StudentID) REFERENCES student(StudentID)
        ON DELETE CASCADE
);

-- ---------- SAMPLE DATA ----------

INSERT INTO student (StudentID, FirstName, LastName, EmailAddress)
VALUES
(2026001, 'Thabo',      'Nkosi',   'thabo.nkosi@example.com'),
(2026002, 'Siyabulela', 'Mkhize',  'siyabulela.m@example.com'),
(2026003, 'Wilhelm',    'Rothman', 'wilhelm.r@example.com'),
(2026004, 'Sarusha',    'Naidoo',  'sarusha.n@example.com'),
(2026005, 'Sarah',      'Viljoen', 'sarah.v@example.com');

INSERT INTO lecturer (LecturerID, LectName, LectEmail)
VALUES
(101, 'Prof. Alan Smith',    'alan.smith@example.com'),
(102, 'Dr. Brenda Jones',    'brenda.jones@example.com'),
(103, 'Dr. Nomsa Dlamini',   'nomsa.dlamini@example.com');

INSERT INTO course (CourseCode, CourseName, Credits, LecturerID)
VALUES
('IDB152', 'Introduction to Databases', 10, 101),
('CS101',  'Computer Science I',        12, 102),
('MAT151', 'Mathematics for IT',        10, 103);

INSERT INTO dependant (StudentID, DependentName, Relationship, Age)
VALUES
(2026001, 'Sipho Nkosi',    'Son',      8),
(2026003, 'Anika Rothman',  'Daughter', 5);

INSERT INTO enrolment (StudentID, CourseCode, EnrolmentDate, Grade)
VALUES
(2026001, 'IDB152', '2026-02-10', 78.50),
(2026001, 'CS101',  '2026-02-10', 85.00),
(2026002, 'IDB152', '2026-02-11', 64.00),
(2026003, 'IDB152', '2026-02-12', 91.00),
(2026003, 'MAT151', '2026-02-12', 88.00),
(2026005, 'IDB152', '2026-02-15', 82.00);

-- ---------- UPDATE AND DELETE ----------

-- Change one student's email address
UPDATE student
SET EmailAddress = 'sarusha.pillay@example.com'
WHERE StudentID = 2026004;

-- Remove a student. Their enrolments are deleted too (ON DELETE CASCADE).
DELETE FROM student
WHERE StudentID = 2026002;

-- ---------- QUERIES ----------

-- 1. Students after a given ID, sorted by surname
SELECT FirstName, LastName, EmailAddress
FROM student
WHERE StudentID > 2026001
ORDER BY LastName ASC;

-- 2. Class statistics for one course (aggregate functions)
SELECT
    COUNT(StudentID) AS TotalEnrolled,
    AVG(Grade)       AS AverageGrade,
    MAX(Grade)       AS TopMark,
    MIN(Grade)       AS LowestMark
FROM enrolment
WHERE CourseCode = 'IDB152';

-- 3. Number of students per course (GROUP BY)
SELECT CourseCode,
       COUNT(StudentID) AS StudentCount
FROM enrolment
GROUP BY CourseCode;

-- 4. Students with 75 or more in IDB152 (JOIN)
SELECT s.FirstName, s.LastName, e.Grade
FROM student s
JOIN enrolment e ON s.StudentID = e.StudentID
WHERE e.CourseCode = 'IDB152'
  AND e.Grade >= 75
ORDER BY s.LastName ASC;

-- ---------- STORED PROCEDURE ----------
-- Returns the class list for any course code passed in.

DELIMITER //
CREATE PROCEDURE GetClassList(IN p_course_code VARCHAR(20))
BEGIN
    SELECT s.StudentID,
           CONCAT(s.FirstName, ' ', s.LastName) AS StudentName,
           c.CourseCode,
           c.CourseName,
           e.Grade
    FROM student s
        INNER JOIN enrolment e ON s.StudentID = e.StudentID
        INNER JOIN course c    ON e.CourseCode = c.CourseCode
    WHERE c.CourseCode = p_course_code
    ORDER BY s.LastName ASC;
END //
DELIMITER ;

CALL GetClassList('IDB152');
