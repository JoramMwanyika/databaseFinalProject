# Library Management System Database

## Project Description
This project implements a comprehensive Library Management System database using MySQL. The database is designed to handle various aspects of library operations including book management, member management, borrowing records, and more.

## Features
- Book catalog management
- Member/User management
- Borrowing and return tracking
- Fine calculation system
- Category and author management
- Publisher information tracking

## Database Schema
The database consists of the following main tables:
- Books
- Members
- Borrowings
- Categories
- Authors
- Publishers
- Book_Authors (for many-to-many relationship)

## Setup Instructions
1. Install MySQL Server if you haven't already
2. Open MySQL command line or MySQL Workbench
3. Run the following command to create the database:
   ```sql
   CREATE DATABASE library_management;
   USE library_management;
   ```
4. Import the `library_management.sql` file:
   ```sql
   source path/to/library_management.sql
   ```

## ERD (Entity Relationship Diagram)
The database follows a relational model with the following relationships:
- One-to-Many: Publisher to Books
- One-to-Many: Category to Books
- Many-to-Many: Books to Authors (through Book_Authors)
- One-to-Many: Members to Borrowings
- One-to-Many: Books to Borrowings

## Database Constraints
- Primary Keys (PK) on all tables
- Foreign Keys (FK) for referential integrity
- NOT NULL constraints on essential fields
- UNIQUE constraints where appropriate
- Check constraints for data validation