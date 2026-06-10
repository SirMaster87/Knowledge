from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify, g
import sqlite3
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
import os
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'knowledge_group_secret_key_2024'
DATABASE = 'knowledge_group.db'

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
        db.row_factory = sqlite3.Row
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

def init_db():
    with app.app_context():
        db = get_db()
        with app.open_resource('schema_sqlite.sql', mode='r') as f:
            db.cursor().executescript(f.read())
        db.commit()

# Initialize DB if it doesn't exist
if not os.path.exists(DATABASE):
    init_db()

@app.context_processor
def inject_pending_requests():
    if 'user_id' in session and session.get('role') == 'admin':
        try:
            db = get_db()
            cur = db.cursor()
            cur.execute("SELECT COUNT(*) as count FROM enrollment_requests WHERE status='pending'")
            count = cur.fetchone()['count']
            return dict(pending_requests_count=count)
        except Exception:
            pass
    return dict(pending_requests_count=0)

# ─── Decorators ───────────────────────────────────────────────────────────────

def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please login first.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session or session.get('role') != 'admin':
            flash('Admin access required.', 'danger')
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated

def student_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session or session.get('role') != 'student':
            flash('Student access required.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated

# ─── Public Routes ─────────────────────────────────────────────────────────────

@app.route('/')
def index():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM courses WHERE is_active=1 LIMIT 6")
    courses = cur.fetchall()
    cur.execute("SELECT * FROM testimonials WHERE is_active=1 LIMIT 4")
    testimonials = cur.fetchall()
    cur.execute("SELECT * FROM announcements ORDER BY created_at DESC LIMIT 3")
    announcements = cur.fetchall()
    return render_template('index.html', courses=courses, testimonials=testimonials, announcements=announcements)

@app.route('/courses')
def courses():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM courses WHERE is_active=1 ORDER BY grade_level")
    all_courses = cur.fetchall()
    return render_template('courses.html', courses=all_courses)

@app.route('/about')
def about():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM teachers WHERE is_active=1")
    teachers = cur.fetchall()
    return render_template('about.html', teachers=teachers)

@app.route('/contact', methods=['GET', 'POST'])
def contact():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form.get('phone', '')
        message = request.form['message']
        db = get_db()
        cur = db.cursor()
        cur.execute("INSERT INTO contact_messages (name, email, phone, message) VALUES (?, ?, ?, ?)",
                    (name, email, phone, message))
        db.commit()
        flash('Message sent successfully! We will contact you soon.', 'success')
        return redirect(url_for('contact'))
    return render_template('contact.html')

@app.route('/enroll', methods=['GET', 'POST'])
def enroll():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM courses WHERE is_active=1")
    courses = cur.fetchall()
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        course_id = request.form['course_id']
        grade = request.form['grade']
        parent_name = request.form.get('parent_name', '')
        parent_phone = request.form.get('parent_phone', '')
        cur.execute("""INSERT INTO enrollment_requests 
                    (name, email, phone, course_id, grade, parent_name, parent_phone)
                    VALUES (?,?,?,?,?,?,?)""",
                    (name, email, phone, course_id, grade, parent_name, parent_phone))
        db.commit()
        flash('Enrollment request submitted! We will review and contact you shortly.', 'success')
        return redirect(url_for('enroll'))
    return render_template('enroll.html', courses=courses)

# ─── Auth Routes ───────────────────────────────────────────────────────────────

@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        db = get_db()
        cur = db.cursor()
        cur.execute("SELECT * FROM users WHERE email=?", (email,))
        user = cur.fetchone()
        if user and check_password_hash(user['password'], password):
            session['user_id'] = user['id']
            session['name'] = user['name']
            session['role'] = user['role']
            flash(f'Welcome back, {user["name"]}!', 'success')
            if user['role'] == 'admin':
                return redirect(url_for('admin_dashboard'))
            return redirect(url_for('student_dashboard'))
        flash('Invalid email or password.', 'danger')
    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        password = generate_password_hash(request.form['password'])
        db = get_db()
        cur = db.cursor()
        cur.execute("SELECT id FROM users WHERE email=?", (email,))
        if cur.fetchone():
            flash('Email already registered.', 'danger')
            return redirect(url_for('register'))
        cur.execute("INSERT INTO users (name, email, phone, password, role) VALUES (?,?,?,?,'student')",
                    (name, email, phone, password))
        db.commit()
        user_id = cur.lastrowid
        cur.execute("INSERT INTO student_profiles (user_id) VALUES (?)", (user_id,))
        db.commit()
        flash('Registration successful! Please login.', 'success')
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('Logged out successfully.', 'info')
    return redirect(url_for('index'))

# ─── Student Routes ─────────────────────────────────────────────────────────────

@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    if session.get('role') == 'admin':
        return redirect(url_for('admin_dashboard'))
    return redirect(url_for('student_dashboard'))

@app.route('/student/dashboard')
@student_required
def student_dashboard():
    db = get_db()
    cur = db.cursor()
    cur.execute("""SELECT e.*, c.name as course_name, c.grade_level, c.schedule
                   FROM enrollments e JOIN courses c ON e.course_id=c.id
                   WHERE e.user_id=?""", (session['user_id'],))
    enrollments = cur.fetchall()
    cur.execute("""SELECT * FROM results WHERE user_id=? ORDER BY exam_date DESC LIMIT 5""",
                (session['user_id'],))
    results = cur.fetchall()
    cur.execute("SELECT * FROM announcements ORDER BY created_at DESC LIMIT 5")
    announcements = cur.fetchall()
    cur.execute("SELECT * FROM student_profiles WHERE user_id=?", (session['user_id'],))
    profile = cur.fetchone()
    return render_template('student/dashboard.html',
                           enrollments=enrollments, results=results,
                           announcements=announcements, profile=profile)

@app.route('/student/results')
@student_required
def student_results():
    db = get_db()
    cur = db.cursor()
    cur.execute("""SELECT r.*, c.name as course_name FROM results r
                   LEFT JOIN courses c ON r.course_id=c.id
                   WHERE r.user_id=? ORDER BY exam_date DESC""", (session['user_id'],))
    results = cur.fetchall()
    return render_template('student/results.html', results=results)

@app.route('/student/profile', methods=['GET', 'POST'])
@student_required
def student_profile():
    db = get_db()
    cur = db.cursor()
    if request.method == 'POST':
        name = request.form['name']
        phone = request.form['phone']
        grade = request.form.get('grade', '')
        school = request.form.get('school', '')
        parent_name = request.form.get('parent_name', '')
        parent_phone = request.form.get('parent_phone', '')
        cur.execute("UPDATE users SET name=?, phone=? WHERE id=?",
                    (name, phone, session['user_id']))
        cur.execute("""UPDATE student_profiles SET grade=?, school=?,
                    parent_name=?, parent_phone=? WHERE user_id=?""",
                    (grade, school, parent_name, parent_phone, session['user_id']))
        db.commit()
        session['name'] = name
        flash('Profile updated successfully!', 'success')
    cur.execute("SELECT u.*, sp.grade, sp.school, sp.parent_name, sp.parent_phone FROM users u LEFT JOIN student_profiles sp ON u.id=sp.user_id WHERE u.id=?", (session['user_id'],))
    user = cur.fetchone()
    return render_template('student/profile.html', user=user)

# ─── Admin Routes ──────────────────────────────────────────────────────────────

@app.route('/admin/dashboard')
@admin_required
def admin_dashboard():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT COUNT(*) as count FROM users WHERE role='student'")
    student_count = cur.fetchone()['count']
    cur.execute("SELECT COUNT(*) as count FROM enrollments")
    enrollment_count = cur.fetchone()['count']
    cur.execute("SELECT COUNT(*) as count FROM courses WHERE is_active=1")
    course_count = cur.fetchone()['count']
    cur.execute("SELECT COUNT(*) as count FROM enrollment_requests WHERE status='pending'")
    pending_requests = cur.fetchone()['count']
    cur.execute("""SELECT er.*, c.name as course_name FROM enrollment_requests er
                   LEFT JOIN courses c ON er.course_id=c.id
                   WHERE er.status='pending' ORDER BY er.created_at DESC LIMIT 5""")
    recent_requests = cur.fetchall()
    cur.execute("SELECT * FROM contact_messages WHERE is_read=0 ORDER BY created_at DESC LIMIT 5")
    unread_messages = cur.fetchall()
    return render_template('admin/dashboard.html',
                           student_count=student_count, enrollment_count=enrollment_count,
                           course_count=course_count, pending_requests=pending_requests,
                           recent_requests=recent_requests, unread_messages=unread_messages)

@app.route('/admin/students')
@admin_required
def admin_students():
    db = get_db()
    cur = db.cursor()
    cur.execute("""SELECT u.*, sp.grade, sp.school FROM users u
                   LEFT JOIN student_profiles sp ON u.id=sp.user_id
                   WHERE u.role='student' ORDER BY u.created_at DESC""")
    students = cur.fetchall()
    return render_template('admin/students.html', students=students)

@app.route('/admin/courses', methods=['GET', 'POST'])
@admin_required
def admin_courses():
    db = get_db()
    cur = db.cursor()
    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'add':
            cur.execute("""INSERT INTO courses (name, description, grade_level, schedule, fees, teacher_id)
                          VALUES (?,?,?,?,?,?)""",
                        (request.form['name'], request.form['description'],
                         request.form['grade_level'], request.form['schedule'],
                         request.form['fees'], request.form.get('teacher_id') or None))
            db.commit()
            flash('Course added successfully!', 'success')
        elif action == 'toggle':
            cur.execute("UPDATE courses SET is_active = NOT is_active WHERE id=?",
                        (request.form['course_id'],))
            db.commit()
            flash('Course status updated.', 'info')
    cur.execute("""SELECT c.*, t.name as teacher_name FROM courses c
                   LEFT JOIN teachers t ON c.teacher_id=t.id ORDER BY c.grade_level""")
    courses = cur.fetchall()
    cur.execute("SELECT * FROM teachers WHERE is_active=1")
    teachers = cur.fetchall()
    return render_template('admin/courses.html', courses=courses, teachers=teachers)

@app.route('/admin/enrollments')
@admin_required
def admin_enrollments():
    db = get_db()
    cur = db.cursor()
    cur.execute("""SELECT er.*, c.name as course_name FROM enrollment_requests er
                   LEFT JOIN courses c ON er.course_id=c.id ORDER BY er.created_at DESC""")
    requests_list = cur.fetchall()
    return render_template('admin/enrollments.html', requests=requests_list)

@app.route('/admin/enrollment/approve/<int:req_id>')
@admin_required
def approve_enrollment(req_id):
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM enrollment_requests WHERE id=?", (req_id,))
    req = cur.fetchone()
    if req:
        cur.execute("SELECT id FROM users WHERE email=?", (req['email'],))
        user = cur.fetchone()
        if not user:
            pwd = generate_password_hash('student123')
            cur.execute("INSERT INTO users (name, email, phone, password, role) VALUES (?,?,?,?,'student')",
                        (req['name'], req['email'], req['phone'], pwd))
            db.commit()
            user_id = cur.lastrowid
            cur.execute("INSERT INTO student_profiles (user_id, grade, parent_name, parent_phone) VALUES (?,?,?,?)",
                        (user_id, req['grade'], req['parent_name'], req['parent_phone']))
        else:
            user_id = user['id']
        cur.execute("INSERT INTO enrollments (user_id, course_id) VALUES (?,?)",
                    (user_id, req['course_id']))
        cur.execute("UPDATE enrollment_requests SET status='approved' WHERE id=?", (req_id,))
        db.commit()
        flash('Enrollment approved!', 'success')
    return redirect(url_for('admin_enrollments'))

@app.route('/admin/enrollment/reject/<int:req_id>')
@admin_required
def reject_enrollment(req_id):
    db = get_db()
    cur = db.cursor()
    cur.execute("UPDATE enrollment_requests SET status='rejected' WHERE id=?", (req_id,))
    db.commit()
    flash('Enrollment rejected.', 'info')
    return redirect(url_for('admin_enrollments'))

@app.route('/admin/results', methods=['GET', 'POST'])
@admin_required
def admin_results():
    db = get_db()
    cur = db.cursor()
    if request.method == 'POST':
        cur.execute("""INSERT INTO results (user_id, course_id, exam_name, marks_obtained, total_marks, exam_date)
                      VALUES (?,?,?,?,?,?)""",
                    (request.form['user_id'], request.form['course_id'],
                     request.form['exam_name'], request.form['marks_obtained'],
                     request.form['total_marks'], request.form['exam_date']))
        db.commit()
        flash('Result added successfully!', 'success')
    cur.execute("""SELECT r.*, u.name as student_name, c.name as course_name
                   FROM results r JOIN users u ON r.user_id=u.id
                   LEFT JOIN courses c ON r.course_id=c.id ORDER BY r.exam_date DESC""")
    results = cur.fetchall()
    cur.execute("SELECT id, name FROM users WHERE role='student'")
    students = cur.fetchall()
    cur.execute("SELECT id, name FROM courses WHERE is_active=1")
    courses = cur.fetchall()
    return render_template('admin/results.html', results=results, students=students, courses=courses)

@app.route('/admin/announcements', methods=['GET', 'POST'])
@admin_required
def admin_announcements():
    db = get_db()
    cur = db.cursor()
    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'add':
            cur.execute("INSERT INTO announcements (title, content, category) VALUES (?,?,?)",
                        (request.form['title'], request.form['content'], request.form['category']))
            db.commit()
            flash('Announcement posted!', 'success')
        elif action == 'delete':
            cur.execute("DELETE FROM announcements WHERE id=?", (request.form['ann_id'],))
            db.commit()
            flash('Announcement deleted.', 'info')
    cur.execute("SELECT * FROM announcements ORDER BY created_at DESC")
    announcements = cur.fetchall()
    return render_template('admin/announcements.html', announcements=announcements)

@app.route('/admin/messages')
@admin_required
def admin_messages():
    db = get_db()
    cur = db.cursor()
    cur.execute("UPDATE contact_messages SET is_read=1")
    db.commit()
    cur.execute("SELECT * FROM contact_messages ORDER BY created_at DESC")
    messages = cur.fetchall()
    return render_template('admin/messages.html', messages=messages)

@app.route('/admin/teachers', methods=['GET', 'POST'])
@admin_required
def admin_teachers():
    db = get_db()
    cur = db.cursor()
    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'add':
            cur.execute("INSERT INTO teachers (name, subject, qualification, experience, bio) VALUES (?,?,?,?,?)",
                        (request.form['name'], request.form['subject'],
                         request.form['qualification'], request.form['experience'], request.form['bio']))
            db.commit()
            flash('Teacher added!', 'success')
    cur.execute("SELECT * FROM teachers ORDER BY name")
    teachers = cur.fetchall()
    return render_template('admin/teachers.html', teachers=teachers)

if __name__ == '__main__':
    app.run(debug=True)
