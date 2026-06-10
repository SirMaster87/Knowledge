-- Knowledge Group Tuition - Database Schema
-- Run this file to set up the database

CREATE DATABASE IF NOT EXISTS knowledge_group;
USE knowledge_group;

-- Users table (students + admins)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    password VARCHAR(255) NOT NULL,
    role ENUM('student','admin') DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Student profiles
CREATE TABLE IF NOT EXISTS student_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    grade VARCHAR(20),
    school VARCHAR(100),
    parent_name VARCHAR(100),
    parent_phone VARCHAR(15),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Teachers
CREATE TABLE IF NOT EXISTS teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    subject VARCHAR(100),
    qualification VARCHAR(150),
    experience INT DEFAULT 0,
    bio TEXT,
    photo VARCHAR(255),
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Courses
CREATE TABLE IF NOT EXISTS courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    grade_level VARCHAR(50),
    schedule VARCHAR(200),
    fees DECIMAL(10,2),
    teacher_id INT,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
);

-- Enrollment requests (from public form)
CREATE TABLE IF NOT EXISTS enrollment_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    course_id INT,
    grade VARCHAR(20),
    parent_name VARCHAR(100),
    parent_phone VARCHAR(15),
    status ENUM('pending','approved','rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL
);

-- Active enrollments
CREATE TABLE IF NOT EXISTS enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active','completed','dropped') DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Results / marks
CREATE TABLE IF NOT EXISTS results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT,
    exam_name VARCHAR(100),
    marks_obtained DECIMAL(6,2),
    total_marks DECIMAL(6,2),
    exam_date DATE,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL
);

-- Announcements
CREATE TABLE IF NOT EXISTS announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    category ENUM('general','exam','holiday','result','fee') DEFAULT 'general',
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Contact messages
CREATE TABLE IF NOT EXISTS contact_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15),
    message TEXT,
    is_read TINYINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Testimonials
CREATE TABLE IF NOT EXISTS testimonials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100),
    grade VARCHAR(50),
    content TEXT,
    rating INT DEFAULT 5,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─── Seed Data ────────────────────────────────────────────────────────────────

-- Admin user (password: admin123)
INSERT INTO users (name, email, phone, password, role) VALUES
('Admin', 'admin@knowledgegroup.com', '9999999999',
 'scrypt:32768:8:1$iFk0h8qCsyF9eF3b$42684c3caf30c0fff05faf3444139f2a75fb3e2ba005e0185936766c2fde5c18ab1e287ac9ea68924e1d4d90a2f15e230fcbf826bbcd8522e2267e202153b543', 'admin');

-- Teachers
INSERT INTO teachers (name, subject, qualification, experience, bio) VALUES
('Prof. Rajesh Sharma', 'Mathematics', 'M.Sc. Mathematics, B.Ed.', 12, 'Specialist in Algebra, Calculus and competitive exam prep.'),
('Ms. Priya Patel', 'Science', 'M.Sc. Physics, B.Ed.', 8, 'Expert in Physics and Chemistry with focus on practical learning.'),
('Mr. Arvind Mehta', 'English', 'M.A. English Literature, B.Ed.', 10, 'Specializes in grammar, essay writing and comprehension skills.'),
('Ms. Neha Shah', 'Social Science', 'M.A. History, B.Ed.', 6, 'Makes history and geography engaging with storytelling approach.');

-- Courses
INSERT INTO courses (name, description, grade_level, schedule, fees, teacher_id) VALUES
('Mathematics - Std 8', 'Complete CBSE/GSEB Math curriculum for Std 8', 'Std 8', 'Mon/Wed/Fri 4:00-5:30 PM', 1200.00, 1),
('Mathematics - Std 9', 'Algebra, Geometry, Statistics for Std 9', 'Std 9', 'Mon/Wed/Fri 5:30-7:00 PM', 1400.00, 1),
('Mathematics - Std 10', 'Board exam preparation with full syllabus', 'Std 10', 'Tue/Thu/Sat 4:00-6:00 PM', 1800.00, 1),
('Science - Std 9', 'Physics, Chemistry, Biology for Std 9', 'Std 9', 'Tue/Thu 4:00-5:30 PM', 1400.00, 2),
('Science - Std 10', 'Complete Science with practicals and board prep', 'Std 10', 'Mon/Wed/Fri 4:00-6:00 PM', 1800.00, 2),
('English - Std 8 to 10', 'Grammar, Writing, Literature for Std 8-10', 'Std 8-10', 'Sat/Sun 9:00-11:00 AM', 1000.00, 3),
('Social Science - Std 10', 'History, Geography, Civics, Economics board prep', 'Std 10', 'Sat 11:00 AM-1:00 PM', 1000.00, 4),
('Foundation Batch - Std 6 & 7', 'Build strong basics in Math and Science', 'Std 6-7', 'Mon/Wed/Fri 3:00-4:00 PM', 900.00, 1);

-- Announcements
INSERT INTO announcements (title, content, category) VALUES
('Welcome to New Academic Year 2024-25!', 'We are excited to begin a new academic year. Admissions are open for all batches. Contact us to enroll your child today!', 'general'),
('Half-Yearly Exam Schedule Released', 'Half-yearly examinations will be conducted from 1st November to 10th November 2024. Timetables will be shared with enrolled students.', 'exam'),
('Diwali Holiday Notice', 'The institute will remain closed from 28th Oct to 3rd Nov 2024 for Diwali vacation. Classes resume on 4th November.', 'holiday'),
('Fee Payment Reminder', 'Kindly clear November month fees by 10th November to avoid late fees. Pay online or at the institute counter.', 'fee');

-- Testimonials
INSERT INTO testimonials (student_name, grade, content, rating) VALUES
('Aryan Patel', 'Std 10 (2024)', 'Knowledge Group helped me score 94% in boards! The teachers are extremely dedicated and patient.', 5),
('Riya Shah', 'Std 9 (2024)', 'The best tuition classes in Ahmedabad. I improved from 65% to 89% in just one year!', 5),
('Mihir Desai', 'Std 10 (2023)', 'Prof. Rajesh sir''s way of teaching Maths made it so easy to understand. Highly recommended!', 5),
('Sneha Trivedi', 'Std 8 (2024)', 'My daughter loves coming to Knowledge Group. The environment is so positive and encouraging.', 5);
