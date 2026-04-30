// ============================================
// Honkai Star Retail - Backend Server
// ============================================
const express = require('express');
const mysql = require('mysql2');
const crypto = require('crypto');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// ============================================
// Database Connection (XAMPP MySQL)
// ============================================
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'honkai_star_retail'
});

db.connect((err) => {
  if (err) {
    console.log('DB connection failed:', err.message);
    return;
  }
  console.log('Connected to MySQL!');
});

// ============================================
// Token Management (in-memory)
// ============================================
const tokens = {};

// Generate a 40-char alphanumeric token (meets 20+ char requirement)
function generateToken(userId, role, email) {
  const token = crypto.randomBytes(20).toString('hex');
  tokens[token] = { userId, role, email };
  return token;
}

// Middleware: verify bearer token
function verifyToken(req, res, next) {
  const auth = req.headers['authorization'];
  if (!auth || !auth.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }
  const token = auth.split(' ')[1];
  if (!tokens[token]) {
    return res.status(401).json({ error: 'Invalid token' });
  }
  req.user = tokens[token];
  next();
}

// ============================================
// AUTH ROUTES
// ============================================

// POST /auth/register
app.post('/auth/register', (req, res) => {
  const { email, password, name } = req.body;
  if (!email || !password || !name) {
    return res.status(400).json({ error: 'All fields are required' });
  }
  const sql = 'INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, "user")';
  db.query(sql, [email, password, name], (err) => {
    if (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ error: 'Email already exists' });
      }
      return res.status(500).json({ error: 'Server error' });
    }
    res.json({ message: 'Registration successful' });
  });
});

// POST /auth/login - Standard login
app.post('/auth/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }
  const sql = 'SELECT * FROM users WHERE email = ? AND password = ?';
  db.query(sql, [email, password], (err, results) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    if (results.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    const user = results[0];
    const token = generateToken(user.id, user.role, user.email);
    res.json({ message: 'Login successful', token, role: user.role, name: user.name });
  });
});

// POST /auth/google - Google OAuth login
app.post('/auth/google', (req, res) => {
  const { email, name } = req.body;
  if (!email || !name) {
    return res.status(400).json({ error: 'Google info required' });
  }
  const findSql = 'SELECT * FROM users WHERE email = ?';
  db.query(findSql, [email], (err, results) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    if (results.length > 0) {
      // Existing user
      const user = results[0];
      const token = generateToken(user.id, user.role, user.email);
      res.json({ message: 'Google login successful', token, role: user.role, name: user.name });
    } else {
      // New user from Google
      const insertSql = 'INSERT INTO users (email, password, name, role) VALUES (?, "google_oauth", ?, "user")';
      db.query(insertSql, [email, name], (err, result) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        const token = generateToken(result.insertId, 'user', email);
        res.json({ message: 'Google login successful', token, role: 'user', name });
      });
    }
  });
});

// ============================================
// RESOURCE ROUTES
// ============================================

// GET /resources - Get all resources
app.get('/resources', (req, res) => {
  db.query('SELECT * FROM resources', (err, results) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    res.json(results);
  });
});

// GET /resources/:id - Get one resource
app.get('/resources/:id', (req, res) => {
  db.query('SELECT * FROM resources WHERE id = ?', [req.params.id], (err, results) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    if (results.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json(results[0]);
  });
});

// POST /resources - Create (admin + token required)
app.post('/resources', verifyToken, (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin only' });
  }
  const { name, type, description, stock, image, price } = req.body;
  const sql = 'INSERT INTO resources (name, type, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(sql, [name, type, description, stock, image, price], (err, result) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    res.json({ message: 'Resource created', id: result.insertId });
  });
});

// PUT /resources/:id - Update (admin + token required)
app.put('/resources/:id', verifyToken, (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin only' });
  }
  const { name, type, description, stock, image, price } = req.body;
  const sql = 'UPDATE resources SET name=?, type=?, description=?, stock=?, image=?, price=? WHERE id=?';
  db.query(sql, [name, type, description, stock, image, price, req.params.id], (err) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    res.json({ message: 'Resource updated' });
  });
});

// DELETE /resources/:id - Delete (admin + token required)
app.delete('/resources/:id', verifyToken, (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin only' });
  }
  db.query('DELETE FROM resources WHERE id = ?', [req.params.id], (err) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    res.json({ message: 'Resource deleted' });
  });
});

// POST /resources/:id/buy - Buy resource (token required)
app.post('/resources/:id/buy', verifyToken, (req, res) => {
  const { quantity } = req.body;
  if (!quantity || quantity <= 0) {
    return res.status(400).json({ error: 'Quantity must be greater than 0' });
  }
  db.query('SELECT * FROM resources WHERE id = ?', [req.params.id], (err, results) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    if (results.length === 0) return res.status(404).json({ error: 'Not found' });
    const item = results[0];
    if (item.stock < quantity) {
      return res.status(400).json({ error: 'Not enough stock' });
    }
    db.query('UPDATE resources SET stock = stock - ? WHERE id = ?', [quantity, req.params.id], (err) => {
      if (err) return res.status(500).json({ error: 'Server error' });
      res.json({ message: `Bought ${quantity} x ${item.name}`, totalCost: item.price * quantity });
    });
  });
});

// ============================================
// Start Server
// ============================================
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
