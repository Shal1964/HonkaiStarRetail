-- ============================================
-- Honkai Star Retail - Database Setup
-- Run this in phpMyAdmin (XAMPP)
-- ============================================

CREATE DATABASE IF NOT EXISTS honkai_star_retail;
USE honkai_star_retail;

-- Users table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role ENUM('user', 'admin') DEFAULT 'user'
);

-- Resources table (id, name, type, description, stock, image, price)
CREATE TABLE resources (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(100) NOT NULL,
  description TEXT,
  stock INT DEFAULT 0,
  image VARCHAR(500),
  price DOUBLE NOT NULL
);

-- Seed admin user (email: admin@hsr.com, password: admin123)
INSERT INTO users (email, password, name, role) VALUES
('admin@hsr.com', 'admin123', 'Admin', 'admin');

-- Seed regular user (email: user@hsr.com, password: user123)
INSERT INTO users (email, password, name, role) VALUES
('user@hsr.com', 'user123', 'Trailblazer', 'user');

-- Seed resources
INSERT INTO resources (name, type, description, stock, image, price) VALUES
('Stellar Jade', 'Currency', 'A precious jade that contains the energy of stars. Used for Warps.', 200, 'https://picsum.photos/seed/jade/300/300', 1600),
('Trailblaze EXP', 'Material', 'Used to increase your Trailblaze Level and unlock new content.', 500, 'https://picsum.photos/seed/exp/300/300', 500),
('Credit', 'Currency', 'Universal currency used for transactions across the galaxy.', 9999, 'https://picsum.photos/seed/credit/300/300', 100),
('Condensed Aether', 'Material', 'Crystallized aether energy. Used for character ascension.', 80, 'https://picsum.photos/seed/aether/300/300', 2000),
('Moment of Joy', 'Light Cone', 'A 5-star Light Cone that greatly boosts ATK for its wielder.', 5, 'https://picsum.photos/seed/joy/300/300', 15000),
('Flames Afar', 'Light Cone', 'A 5-star Light Cone designed for powerful damage dealers.', 3, 'https://picsum.photos/seed/flames/300/300', 18000);
