// ─── Knowledge Group Tuition - Main JS ───────────────────────────────────────

// Navbar scroll effect
const navbar = document.getElementById('navbar');
if (navbar) {
    window.addEventListener('scroll', () => {
        navbar.classList.toggle('scrolled', window.scrollY > 20);
    });
}

// Hamburger menu
const hamburger = document.getElementById('hamburger');
const navLinks = document.getElementById('navLinks');
if (hamburger && navLinks) {
    hamburger.addEventListener('click', () => {
        navLinks.classList.toggle('open');
        hamburger.classList.toggle('active');
    });
    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!hamburger.contains(e.target) && !navLinks.contains(e.target)) {
            navLinks.classList.remove('open');
            hamburger.classList.remove('active');
        }
    });
}

// Auto-dismiss flash messages after 5 seconds
document.querySelectorAll('.flash').forEach(flash => {
    setTimeout(() => {
        flash.style.opacity = '0';
        flash.style.transform = 'translateX(20px)';
        flash.style.transition = '0.3s';
        setTimeout(() => flash.remove(), 300);
    }, 5000);
});

// Intersection Observer for animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};
const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('animated');
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

document.querySelectorAll('.feature-card, .course-card, .testimonial-card, .teacher-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(24px)';
    el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
    observer.observe(el);
});

// Add animated class to trigger animation
const style = document.createElement('style');
style.textContent = '.animated { opacity: 1 !important; transform: translateY(0) !important; }';
document.head.appendChild(style);

// Staggered animation for grid items
document.querySelectorAll('.features-grid .feature-card, .courses-grid .course-card').forEach((el, i) => {
    el.style.transitionDelay = `${i * 80}ms`;
});

// Confirm dialogs for destructive actions
document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', (e) => {
        if (!confirm(el.dataset.confirm)) e.preventDefault();
    });
});

// Active sidebar link
const currentPath = window.location.pathname;
document.querySelectorAll('.sidebar-nav a').forEach(link => {
    if (link.getAttribute('href') === currentPath) {
        link.classList.add('active');
    }
});
