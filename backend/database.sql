-- ============================================
-- Honkai Star Retail - Database Setup
-- Run this in phpMyAdmin (XAMPP)
-- ============================================

CREATE DATABASE IF NOT EXISTS honkai_star_retail;
USE honkai_star_retail;

-- Users table
CREATE TABLE users (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  email    VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name     VARCHAR(255) NOT NULL,
  role     ENUM('user', 'admin') DEFAULT 'user'
);

-- ============================================
-- Light Cones table (PUNYA rarity)
-- ============================================
CREATE TABLE light_cones (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,
  type        VARCHAR(100) NOT NULL,   -- path: The Hunt, Erudition, Harmony, dll
  description TEXT,
  stock       INT DEFAULT 0,
  image       VARCHAR(500),
  price       DOUBLE NOT NULL,
  rarity      TINYINT NOT NULL DEFAULT 3  -- nilai: 3, 4, atau 5 (bintang)
);

-- ============================================
-- Galactic Resources table (TANPA rarity)
-- ============================================
CREATE TABLE galactic_resources (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,
  type        VARCHAR(100) NOT NULL,   -- Currency, Material, dll
  description TEXT,
  stock       INT DEFAULT 0,
  image       VARCHAR(500),
  price       DOUBLE NOT NULL
);

-- Seed admin & user
INSERT INTO users (email, password, name, role) VALUES
('admin@hsr.com', 'admin123', 'Admin', 'admin'),
('user@hsr.com',  'user123',  'Trailblazer', 'user');

-- Seed light_cones
INSERT INTO light_cones (name, type, description, stock, image, price, rarity) VALUES
('After the Charmony Fall',  'The Hunt',    'A 5-star Light Cone that greatly boosts ATK.', 5,'assets/images/LC_AfterTheCharmonyFall.png',  15000, 5),
('Flames Afar',    'Destruction', 'A 5-star Light Cone for damage dealers.',       3, 'assets/images/LC_FlamesAfar.png', 18000, 5),
('PlanetaryRendezvous',  'The Hunt',    'A 4-star Light Cone for follow-up attacks.',    10,'assets/images/LC_PlanetaryRendezvous.png',  8000,  4);

-- Seed galactic_resources 
INSERT INTO galactic_resources (name, type, description, stock, image, price) VALUES
('Stellar Jade',    'Currency', 'Precious jade used for Warps.',                     200,  'assets/images/GR_Credit.png',   1600),
('Trailblaze EXP',  'Material', 'Used to increase your Trailblaze Level.',           500,  'assets/images/GR_StellarJade.png',    500),
('Credit',          'Currency', 'Universal currency across the galaxy.',             9999, 'assets/images/GR_TrailblazeEXP.png', 100),
