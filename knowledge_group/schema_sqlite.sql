-- Knowledge Group Tuition - SQLite Database Schema
-- Run this file to set up the database

-- Users table (students + admins)
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'student', -- CHECK(role IN ('student', 'admin'))
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Student profiles
CREATE TABLE IF NOT EXISTS student_profiles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    grade TEXT,
    school TEXT,
    parent_name TEXT,
    parent_phone TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Teachers
CREATE TABLE IF NOT EXISTS teachers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    subject TEXT,
    qualification TEXT,
    experience INTEGER DEFAULT 0,
    bio TEXT,
    photo TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Courses
CREATE TABLE IF NOT EXISTS courses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    grade_level TEXT,
    schedule TEXT,
    fees REAL,
    teacher_id INTEGER,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
);

-- Enrollment requests (from public form)
CREATE TABLE IF NOT EXISTS enrollment_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    course_id INTEGER,
    grade TEXT,
    parent_name TEXT,
    parent_phone TEXT,
    status TEXT DEFAULT 'pending', -- CHECK(status IN ('pending', 'approved', 'rejected'))
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL
);

-- Active enrollments
CREATE TABLE IF NOT EXISTS enrollments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'active', -- CHECK(status IN ('active', 'completed', 'dropped'))
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Results / marks
CREATE TABLE IF NOT EXISTS results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    course_id INTEGER,
    exam_name TEXT,
    marks_obtained REAL,
    total_marks REAL,
    exam_date TEXT,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL
);

-- Announcements
CREATE TABLE IF NOT EXISTS announcements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT,
    category TEXT DEFAULT 'general', -- CHECK(category IN ('general', 'exam', 'holiday', 'result', 'fee'))
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Contact messages
CREATE TABLE IF NOT EXISTS contact_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT,
    phone TEXT,
    message TEXT,
    is_read INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Testimonials
CREATE TABLE IF NOT EXISTS testimonials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_name TEXT,
    grade TEXT,
    content TEXT,
    rating INTEGER DEFAULT 5,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─── Seed Data ────────────────────────────────────────────────────────────────

-- Admin user (password: admin123)
INSERT OR IGNORE INTO users (name, email, phone, password, role) VALUES
('Admin', 'admin@knowledgegroup.com', '9999999999',
 'scrypt:32768:8:1$iFk0h8qCsyF9eF3b$42684c3caf30c0fff05faf3444139f2a75fb3e2ba005e0185936766c2fde5c18ab1e287ac9ea68924e1d4d90a2f15e230fcbf826bbcd8522e2267e202153b543', 'admin');

-- Teachers
INSERT OR IGNORE INTO teachers (name, subject, qualification, experience, bio) VALUES
('Prof. Rajesh Sharma', 'Mathematics', 'M.Sc. Mathematics, B.Ed.', 12, 'Specialist in Algebra, Calculus and competitive exam prep.'),
('Ms. Priya Patel', 'Science', 'M.Sc. Physics, B.Ed.', 8, 'Expert in Physics and Chemistry with focus on practical learning.'),
('Mr. Arvind Mehta', 'English', 'M.A. English Literature, B.Ed.', 10, 'Specializes in grammar, essay writing and comprehension skills.'),
('Ms. Neha Shah', 'Social Science', 'M.A. History, B.Ed.', 6, 'Makes history and geography engaging with storytelling approach.');

-- Courses
INSERT OR IGNORE INTO courses (name, description, grade_level, schedule, fees, teacher_id) VALUES
('Mathematics - Std 8', 'Complete CBSE/GSEB Math curriculum for Std 8', 'Std 8', 'Mon/Wed/Fri 4:00-5:30 PM', 1200.00, 1),
('Mathematics - Std 9', 'Algebra, Geometry, Statistics for Std 9', 'Std 9', 'Mon/Wed/Fri 5:30-7:00 PM', 1400.00, 1),
('Mathematics - Std 10', 'Board exam preparation with full syllabus', 'Std 10', 'Tue/Thu/Sat 4:00-6:00 PM', 1800.00, 1),
('Science - Std 9', 'Physics, Chemistry, Biology for Std 9', 'Std 9', 'Tue/Thu 4:00-5:30 PM', 1400.00, 2),
('Science - Std 10', 'Complete Science with practicals and board prep', 'Std 10', 'Mon/Wed/Fri 4:00-6:00 PM', 1800.00, 2),
('English - Std 8 to 10', 'Grammar, Writing, Literature for Std 8-10', 'Std 8-10', 'Sat/Sun 9:00-11:00 AM', 1000.00, 3),
('Social Science - Std 10', 'History, Geography, Civics, Economics board prep', 'Std 10', 'Sat 11:00 AM-1:00 PM', 1000.00, 4),
('Foundation Batch - Std 6 & 7', 'Build strong basics in Math and Science', 'Std 6-7', 'Mon/Wed/Fri 3:00-4:00 PM', 900.00, 1);

-- Announcements
INSERT OR IGNORE INTO announcements (title, content, category) VALUES
('Welcome to New Academic Year 2024-25!', 'We are excited to begin a new academic year. Admissions are open for all batches. Contact us to enroll your child today!', 'general'),
('Half-Yearly Exam Schedule Released', 'Half-yearly examinations will be conducted from 1st November to 10th November 2024. Timetables will be shared with enrolled students.', 'exam'),
('Diwali Holiday Notice', 'The institute will remain closed from 28th Oct to 3rd Nov 2024 for Diwali vacation. Classes resume on 4th November.', 'holiday'),
('Fee Payment Reminder', 'Kindly clear November month fees by 10th November to avoid late fees. Pay online or at the institute counter.', 'fee');

-- Testimonials
INSERT OR IGNORE INTO testimonials (student_name, grade, content, rating) VALUES
('Aryan Patel', 'Std 10 (2024)', 'Knowledge Group helped me score 94% in boards! The teachers are extremely dedicated and patient.', 5),
('Riya Shah', 'Std 9 (2024)', 'The best tuition classes in Ahmedabad. I improved from 65% to 89% in just one year!', 5),
('Mihir Desai', 'Std 10 (2023)', 'Prof. Rajesh sir''s way of teaching Maths made it so easy to understand. Highly recommended!', 5),
('Sneha Trivedi', 'Std 8 (2024)', 'My daughter loves coming to Knowledge Group. The environment is so positive and encouraging.', 5);
