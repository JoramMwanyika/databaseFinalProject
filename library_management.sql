-- Library Management System Database
-- This SQL file creates all necessary tables for a library management system

-- Create database
CREATE DATABASE IF NOT EXISTS library_management;
USE library_management;

-- Create Roles table for role-based access control
CREATE TABLE Roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (role_name)
);

-- Create Users table for authentication
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    role_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    password_changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id),
    UNIQUE (username),
    UNIQUE (email)
);

-- Create Permissions table
CREATE TABLE Permissions (
    permission_id INT PRIMARY KEY AUTO_INCREMENT,
    permission_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (permission_name)
);

-- Create Role_Permissions table (many-to-many relationship)
CREATE TABLE Role_Permissions (
    role_id INT,
    permission_id INT,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES Roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES Permissions(permission_id) ON DELETE CASCADE
);

-- Create Audit_Logs table for tracking all database changes
CREATE TABLE Audit_Logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE', 'SELECT') NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Create Login_Attempts table for security monitoring
CREATE TABLE Login_Attempts (
    attempt_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT FALSE,
    failure_reason VARCHAR(255)
);

-- Create Password_Reset_Tokens table
CREATE TABLE Password_Reset_Tokens (
    token_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    UNIQUE (token)
);

-- Create Session_Logs table
CREATE TABLE Session_Logs (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    UNIQUE (session_token)
);

-- Create Publishers table
CREATE TABLE Publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (publisher_name)
);

-- Create Categories table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (category_name)
);

-- Create Authors table
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (first_name, last_name)
);

-- Create Books table
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(13) NOT NULL,
    title VARCHAR(255) NOT NULL,
    publisher_id INT,
    category_id INT,
    publication_year INT,
    edition VARCHAR(20),
    price DECIMAL(10,2),
    quantity INT NOT NULL DEFAULT 0,
    available_quantity INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    UNIQUE (isbn),
    CHECK (publication_year > 0),
    CHECK (quantity >= 0),
    CHECK (available_quantity >= 0),
    CHECK (available_quantity <= quantity)
);

-- Create Book_Authors table (for many-to-many relationship)
CREATE TABLE Book_Authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

-- Create Members table
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    membership_date DATE NOT NULL,
    membership_status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (email)
);

-- Create Borrowings table
CREATE TABLE Borrowings (
    borrowing_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('borrowed', 'returned', 'overdue') DEFAULT 'borrowed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE RESTRICT,
    CHECK (due_date >= borrow_date),
    CHECK (return_date >= borrow_date OR return_date IS NULL)
);

-- Create Fine_Rates table
CREATE TABLE Fine_Rates (
    rate_id INT PRIMARY KEY AUTO_INCREMENT,
    days_overdue INT NOT NULL,
    fine_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (days_overdue),
    CHECK (days_overdue > 0),
    CHECK (fine_amount >= 0)
);

-- Insert default fine rates
INSERT INTO Fine_Rates (days_overdue, fine_amount) VALUES
(1, 1.00),
(7, 5.00),
(14, 10.00),
(30, 25.00);

-- Insert default roles
INSERT INTO Roles (role_name, description) VALUES
('admin', 'System administrator with full access'),
('librarian', 'Library staff with book management access'),
('member', 'Regular library member with limited access');

-- Insert default permissions
INSERT INTO Permissions (permission_name, description) VALUES
('manage_users', 'Can create, update, and delete users'),
('manage_books', 'Can manage book inventory'),
('manage_borrowings', 'Can manage book borrowings'),
('view_reports', 'Can view system reports'),
('manage_fines', 'Can manage fine calculations'),
('view_audit_logs', 'Can view system audit logs');

-- Assign permissions to roles
INSERT INTO Role_Permissions (role_id, permission_id) VALUES
(1, 1), -- admin: manage_users
(1, 2), -- admin: manage_books
(1, 3), -- admin: manage_borrowings
(1, 4), -- admin: view_reports
(1, 5), -- admin: manage_fines
(1, 6), -- admin: view_audit_logs
(2, 2), -- librarian: manage_books
(2, 3), -- librarian: manage_borrowings
(2, 4), -- librarian: view_reports
(2, 5), -- librarian: manage_fines
(3, 3); -- member: manage_borrowings (only their own)

-- Create indexes for better performance
CREATE INDEX idx_books_isbn ON Books(isbn);
CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_members_email ON Members(email);
CREATE INDEX idx_borrowings_dates ON Borrowings(borrow_date, due_date, return_date);

-- Create indexes for security-related tables
CREATE INDEX idx_users_username ON Users(username);
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_audit_logs_timestamp ON Audit_Logs(timestamp);
CREATE INDEX idx_login_attempts_username ON Login_Attempts(username);
CREATE INDEX idx_session_logs_user_id ON Session_Logs(user_id);
CREATE INDEX idx_password_reset_tokens_token ON Password_Reset_Tokens(token);

-- Create trigger for audit logging on Books table
DELIMITER //
CREATE TRIGGER books_audit_insert
AFTER INSERT ON Books
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Logs (user_id, action_type, table_name, record_id, new_values)
    VALUES (CURRENT_USER(), 'INSERT', 'Books', NEW.book_id, JSON_OBJECT(
        'isbn', NEW.isbn,
        'title', NEW.title,
        'publisher_id', NEW.publisher_id,
        'category_id', NEW.category_id,
        'publication_year', NEW.publication_year,
        'quantity', NEW.quantity,
        'available_quantity', NEW.available_quantity
    ));
END//

CREATE TRIGGER books_audit_update
AFTER UPDATE ON Books
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Logs (user_id, action_type, table_name, record_id, old_values, new_values)
    VALUES (CURRENT_USER(), 'UPDATE', 'Books', NEW.book_id, 
        JSON_OBJECT(
            'isbn', OLD.isbn,
            'title', OLD.title,
            'publisher_id', OLD.publisher_id,
            'category_id', OLD.category_id,
            'publication_year', OLD.publication_year,
            'quantity', OLD.quantity,
            'available_quantity', OLD.available_quantity
        ),
        JSON_OBJECT(
            'isbn', NEW.isbn,
            'title', NEW.title,
            'publisher_id', NEW.publisher_id,
            'category_id', NEW.category_id,
            'publication_year', NEW.publication_year,
            'quantity', NEW.quantity,
            'available_quantity', NEW.available_quantity
        )
    );
END//

CREATE TRIGGER books_audit_delete
AFTER DELETE ON Books
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Logs (user_id, action_type, table_name, record_id, old_values)
    VALUES (CURRENT_USER(), 'DELETE', 'Books', OLD.book_id, JSON_OBJECT(
        'isbn', OLD.isbn,
        'title', OLD.title,
        'publisher_id', OLD.publisher_id,
        'category_id', OLD.category_id,
        'publication_year', OLD.publication_year,
        'quantity', OLD.quantity,
        'available_quantity', OLD.available_quantity
    ));
END//
DELIMITER ; 