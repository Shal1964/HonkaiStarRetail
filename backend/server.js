require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const crypto = require('crypto');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME || 'honkai_star_retail'
});

db.connect((err) => {
  if (err) {
    console.error('DB connection failed:', err.message);
    return;
  }
  console.log('Connected to MySQL: honkai_star_retail!');
});

const tokens = {};
function generateToken() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  return Array.from({ length: 20 }, () => chars[crypto.randomInt(0, chars.length)]).join('');
}
function verifyToken(req, res, next) {
  const auth = req.headers['authorization'];
  if (!auth || !auth.startsWith('Bearer ')) return res.status(401).json({ error: 'No token provided' });
  const token = auth.split(' ')[1];
  if (!tokens[token]) return res.status(401).json({ error: 'Invalid token' });
  req.user = tokens[token];
  next();
}

app.get('/light-cones', (req, res) => {
  db.query('SELECT * FROM light_cones', (err, results) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    res.json(results);
  });
});

app.post('/light-cones', verifyToken, (req, res) => {
  const { name, type, description, stock, image, price, rarity } = req.body;
  const sql = 'INSERT INTO light_cones (name, type, description, stock, image, price, rarity) VALUES (?, ?, ?, ?, ?, ?, ?)';
  db.query(sql, [name, type, description, stock, image, price, rarity], (err, result) => {
  if (err) {
      console.error('GAGAL INSERT LIGHT CONE:', err.message); // <--- Tambahkan baris ini
      return res.status(500).json({ error: 'Server error' });
    }
    res.json({ message: 'Light Cone created', id: result.insertId });
  });
});

app.put('/light-cones/:id', verifyToken, (req, res) => {
  const { id } = req.params;
  const { name, type, description, stock, image, price, rarity } = req.body;
  
  const sql = 'UPDATE light_cones SET name = ?, type = ?, description = ?, stock = ?, image = ?, price = ?, rarity = ? WHERE id = ?';
  db.query(sql, [name, type, description, stock, image, price, rarity, id], (err, result) => {
    if (err) return res.status(500).json({ error: 'Server error saat update Light Cone' });
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Light Cone tidak ditemukan' });
    
    res.json({ message: 'Light Cone berhasil diupdate' });
  });
});

app.delete('/light-cones/:id', verifyToken, (req, res) => {
  const { id } = req.params;
  
  const sql = 'DELETE FROM light_cones WHERE id = ?';
  db.query(sql, [id], (err, result) => {
    if (err) return res.status(500).json({ error: 'Server error saat menghapus Light Cone' });
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Light Cone tidak ditemukan' });
    
    res.json({ message: 'Light Cone berhasil dihapus' });
  });
});

app.get('/galactic-resources', (req, res) => {
  db.query('SELECT * FROM galactic_resources', (err, results) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    res.json(results);
  });
});

app.post('/galactic-resources', verifyToken, (req, res) => {
  const { name, type, description, stock, image, price } = req.body;
  // Perhatikan: Tidak ada 'rarity' di sini sesuai skema DB
  const sql = 'INSERT INTO galactic_resources (name, type, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(sql, [name, type, description, stock, image, price], (err, result) => {
    if (err) return res.status(500).json({ error: 'Server error' });
    res.json({ message: 'Galactic Resource created', id: result.insertId });
  });
});

app.put('/galactic-resources/:id', verifyToken, (req, res) => {
  const { id } = req.params;
  const { name, type, description, stock, image, price } = req.body; // Tanpa rarity
  
  const sql = 'UPDATE galactic_resources SET name = ?, type = ?, description = ?, stock = ?, image = ?, price = ? WHERE id = ?';
  db.query(sql, [name, type, description, stock, image, price, id], (err, result) => {
    if (err) return res.status(500).json({ error: 'Server error saat update Galactic Resource' });
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Galactic Resource tidak ditemukan' });
    
    res.json({ message: 'Galactic Resource berhasil diupdate' });
  });
});

app.delete('/galactic-resources/:id', verifyToken, (req, res) => {
  const { id } = req.params;
  
  const sql = 'DELETE FROM galactic_resources WHERE id = ?';
  db.query(sql, [id], (err, result) => {
    if (err) return res.status(500).json({ error: 'Server error saat menghapus Galactic Resource' });
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Galactic Resource tidak ditemukan' });
    
    res.json({ message: 'Galactic Resource berhasil dihapus' });
  });
});

app.post('/auth/login', (req, res) => {
  const { email, password } = req.body;

  const sql = 'SELECT * FROM users WHERE email = ?';
  db.query(sql, [email], (err, results) => {
    if (err) return res.status(500).json({ error: 'Server error' });

    if (results.length === 0) {
      return res.status(401).json({ error: 'User tidak ditemukan' });
    }

    const user = results[0];

    if (user.password !== password) {
      return res.status(401).json({ error: 'Password salah' });
    }

    const token = crypto.randomBytes(16).toString('hex');
    tokens[token] = { id: user.id, role: user.role };

    res.json({
      token,
      role: user.role,
      name: user.name
    });
  });
});


app.post('/auth/register', (req, res) => {
  console.log('REGISTER HIT', req.body);
  const { name, email, password } = req.body;
  const checkSql = 'SELECT * FROM users WHERE email = ?';
  db.query(checkSql, [email], (err, results) => {
    if (err) return res.status(500).json({ error: 'Server error' });

    if (results.length > 0) {
      return res.status(400).json({ error: 'Email sudah terdaftar' });
    }

    const insertSql = 'INSERT INTO users (name, email, password) VALUES (?, ?, ?)';

    db.query(insertSql, [name, email, password], (err, result) => {
      if (err) return res.status(500).json({ error: 'Gagal register' });

      res.json({
        message: 'Register berhasil',
        userId: result.insertId
      });
    });
  });
});

app.post('/auth/google', (req, res) => {
  const { email, name } = req.body;
  if (!email) return res.status(400).json({ error: 'Email required' });

  db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
    if (err) { console.error('Google login SELECT error:', err.message); return res.status(500).json({ error: 'Server error' }); }

    if (results.length > 0) {
      const user = results[0];
      const token = generateToken();
      tokens[token] = { id: user.id, role: user.role };
      return res.json({ token, role: user.role, name: user.name });
    }
    db.query(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name || email, email, ''],
      (err, result) => {
        if (err) return res.status(500).json({ error: 'Gagal register Google user' });
        const token = generateToken();
        tokens[token] = { id: result.insertId, role: 'user' };
        res.json({ token, role: 'user', name: name || email });
      }
    );
  });
});

app.listen(PORT,() => {
  console.log(`Astral Express server running on port ${PORT}`);
});