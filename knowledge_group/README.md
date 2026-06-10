# Knowledge Group Tuition Website

A complete tuition management system built with Flask, MySQL, HTML, CSS, and JavaScript.

## Features

### For Visitors
- Browse available courses with schedules and fees
- View teacher profiles and testimonials
- Read announcements (exam dates, holidays, results)
- Submit enrollment requests through the website
- Contact form for inquiries

### For Students
- Login to personal dashboard
- View enrolled courses and schedules
- Track exam results and performance
- Update profile information
- View announcements and notifications

### For Admins
- Comprehensive admin dashboard with statistics
- Manage students, courses, and teachers
- Review and approve enrollment requests
- Add exam results for students
- Post announcements (exams, holidays, fees)
- View contact form messages
- Activate/deactivate courses

## Technology Stack

- **Backend**: Python Flask
- **Database**: MySQL
- **Frontend**: HTML5, CSS3, JavaScript
- **Authentication**: Session-based with password hashing
- **UI/UX**: Responsive mobile-friendly design with custom CSS

## Installation & Setup

### 1. Prerequisites
- Python 3.8+
- MySQL Server 5.7+
- pip (Python package manager)

### 2. Clone/Extract Project
```bash
cd knowledge_group
```

### 3. Install Python Dependencies
```bash
pip install -r requirements.txt
```

### 4. Setup MySQL Database
```bash
# Login to MySQL
mysql -u root -p

# Run the schema file
mysql -u root -p < schema.sql
```

This will:
- Create the `knowledge_group` database
- Create all necessary tables
- Insert sample data (courses, teachers, announcements, testimonials)
- Create an admin user with credentials:
  - **Email**: admin@knowledgegroup.com
  - **Password**: admin123

### 5. Configure Database Connection
Edit `app.py` and update the MySQL configuration:
```python
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'your_password'  # Change this
app.config['MYSQL_DB'] = 'knowledge_group'
```

### 6. Run the Application
```bash
python app.py
```

The application will start at: **http://localhost:5000**

## Default Credentials

### Admin Login
- **Email**: admin@knowledgegroup.com
- **Password**: admin123

### Student Registration
Students can register through the `/register` page or admins can approve enrollment requests.

## Project Structure

```
knowledge_group/
├── app.py                      # Main Flask application
├── schema.sql                  # Database schema and seed data
├── requirements.txt            # Python dependencies
├── templates/
│   ├── base.html              # Base template with navbar/footer
│   ├── index.html             # Homepage
│   ├── courses.html           # Courses listing
│   ├── about.html             # About page with teachers
│   ├── contact.html           # Contact form
│   ├── enroll.html            # Enrollment form
│   ├── login.html             # Login page
│   ├── register.html          # Student registration
│   ├── student/
│   │   ├── dashboard.html     # Student dashboard
│   │   ├── results.html       # Student results
│   │   └── profile.html       # Student profile
│   └── admin/
│       ├── dashboard.html     # Admin dashboard
│       ├── students.html      # Manage students
│       ├── courses.html       # Manage courses
│       ├── teachers.html      # Manage teachers
│       ├── enrollments.html   # Review enrollments
│       ├── results.html       # Add exam results
│       ├── announcements.html # Post announcements
│       └── messages.html      # Contact messages
└── static/
    ├── css/
    │   └── style.css          # Main stylesheet
    └── js/
        └── main.js            # JavaScript functionality

```

## Database Tables

- **users** - Student and admin accounts
- **student_profiles** - Extended student information
- **teachers** - Teaching faculty
- **courses** - Available courses/batches
- **enrollments** - Active student enrollments
- **enrollment_requests** - Public enrollment form submissions
- **results** - Exam marks and scores
- **announcements** - News and notifications
- **contact_messages** - Contact form submissions
- **testimonials** - Student testimonials

## Key Features Explained

### Responsive Design
- Mobile-first approach
- Hamburger menu for mobile
- Flexible grid layouts
- Touch-friendly buttons

### Security
- Password hashing using Werkzeug
- Session-based authentication
- Role-based access control (student/admin)
- CSRF protection through Flask

### Admin Workflows
1. **Enrollment**: Public form → Admin review → Approve/Reject → Auto-create user
2. **Results**: Select student → Add marks → Visible in student dashboard
3. **Announcements**: Post announcement → Shows on homepage and dashboards

## Customization

### Change Colors
Edit CSS variables in `static/css/style.css`:
```css
:root {
    --primary: #1a237e;      /* Main brand color */
    --accent: #ff6f00;       /* Accent/CTA color */
    --success: #2e7d32;
    --danger: #c62828;
}
```

### Update Logo
The "K" logo icon is generated with CSS. To replace with an image:
1. Add logo image to `static/images/`
2. Update `.logo-icon` in base.html

### Contact Information
Update footer and contact page in:
- `templates/base.html` (footer section)
- `templates/contact.html` (contact details)

## Production Deployment

### Security Checklist
1. Change `app.secret_key` in app.py
2. Set `DEBUG=False`
3. Use environment variables for database credentials
4. Enable HTTPS
5. Update MYSQL password from default

### Recommended Hosting
- **Backend**: PythonAnywhere, Heroku, AWS, DigitalOcean
- **Database**: MySQL on same server or managed MySQL (AWS RDS, DigitalOcean)

## Support

For issues or questions about the codebase, refer to:
- Flask documentation: https://flask.palletsprojects.com/
- MySQL documentation: https://dev.mysql.com/doc/

## License

This is a custom-built tuition management system for Knowledge Group Tuition.
