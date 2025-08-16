const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
require('dotenv').config();  // Load .env variables
 
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');


const app = express();

app.use(cors());
app.use(express.json());
console.log("using hostname ", process.env.DB_HOST);
console.log("using port ", process.env.DB_PORT);

// MySQL connection pool using environment variables
const pool = mysql.createPool({
  host: process.env.DB_HOST,      // from .env
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  //ssl: { rejectUnauthorized: true }
});

// --- API Routes ---


// Get all exams

app.get('/exams', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM exams');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get mock tests by exam_id
app.get('/exams/:examId/mock_tests', async (req, res) => {
  try {
    const examId = req.params.examId;
    const [rows] = await pool.query('SELECT * FROM mock_tests WHERE exam_id = ?', [examId]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get questions by mock_id
app.get('/mock_tests/:mockId/questions', async (req, res) => {
  try {
    const mockId = req.params.mockId;
    const [rows] = await pool.query('SELECT * FROM questions WHERE mock_id = ?', [mockId]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Save result (insert)
app.post('/results', async (req, res) => {
  try {
    const { user_id, mock_id, score, time_taken_minutes } = req.body;
    const [result] = await pool.query(
      'INSERT INTO results (user_id, mock_id, score, time_taken_minutes) VALUES (?, ?, ?, ?)',
      [user_id, mock_id, score, time_taken_minutes]
    );
    res.json({ message: 'Result saved', id: result.insertId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// Add new question (Only for admin with API key)
app.post('/questions', async (req, res) => {
  try {
    // Check API key from request header
    const apiKey = req.headers['x-api-key'];
    if (apiKey !== process.env.ADMIN_KEY) {
      return res.status(401).json({ error: "❌ Unauthorized: Invalid API key" });
    }

    const { mock_id, question_text, options, correct_answer, marks } = req.body;

    if (!mock_id || !question_text || !options || !correct_answer) {
      return res.status(400).json({ error: "mock_id, question_text, options, correct_answer are required" });
    }

    const [result] = await pool.query(
      `INSERT INTO questions (mock_id, question_text, options, correct_answer, marks)
       VALUES (?, ?, ?, ?, ?)`,
      [mock_id, question_text, JSON.stringify(options), correct_answer, marks || 1]
    );

    res.json({ message: "✅ Question added successfully", id: result.insertId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// Secure delete question delete k liye h yeh api h 
app.delete('/questions/:id', async (req, res) => {
  try {
    const apiKey = req.headers['x-api-key'];
    if (apiKey !== process.env.ADMIN_KEY) {
      return res.status(401).json({ error: "❌ Unauthorized: Invalid API key" });
    }

    const questionId = req.params.id;
    const [result] = await pool.query('DELETE FROM questions WHERE id = ?', [questionId]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Question not found" });
    }

    res.json({ message: "🗑️ Question deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// Get results by user_id (optional)
app.get('/results/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const [rows] = await pool.query('SELECT * FROM results WHERE user_id = ?', [userId]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Helper for JWT ---
const signToken = (payload) =>
  jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });

// --- Middleware for protected routes ---
const auth = (req, res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ success: false, message: 'No token provided' });
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.id;
    next();
  } catch {
    return res.status(401).json({ success: false, message: 'Invalid/Expired token' });
  }
};

// --- SIGNUP ---
app.post('/api/auth/signup', async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password)
    return res.status(400).json({ success: false, message: 'name, email, password required' });

  try {
    const [exists] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (exists.length) {
      return res.status(409).json({ success: false, message: 'Email already registered' });
    }

    const hash = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name, email, hash]
    );

    const user = { id: result.insertId, name, email };
    const token = signToken({ id: user.id });

    return res.status(201).json({ success: true, token, user });
  } catch (e) {
    console.error('SIGNUP ERROR:', e);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// --- LOGIN ---
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ success: false, message: 'email and password required' });

  try {
    const [rows] = await pool.query(
      'SELECT id, name, email, password FROM users WHERE email = ?',
      [email]
    );
    if (!rows.length)
      return res.status(401).json({ success: false, message: 'Invalid email or password' });

    const row = rows[0];
    const ok = await bcrypt.compare(password, row.password);
    if (!ok)
      return res.status(401).json({ success: false, message: 'Invalid email or password' });

    const user = { id: row.id, name: row.name, email: row.email };
    const token = signToken({ id: user.id });

    return res.json({ success: true, token, user });
  } catch (e) {
    console.error('LOGIN ERROR:', e);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// --- PROFILE (protected) ---
app.get('/api/auth/profile', auth, async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT id, name, email, created_at FROM users WHERE id = ?',
      [req.userId]
    );
    if (!rows.length) return res.status(404).json({ success: false, message: 'User not found' });

    return res.json({ success: true, user: rows[0] });
  } catch (e) {
    console.error('PROFILE ERROR:', e);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});


app.get("/", (req, res) => {
  res.send("server is running");
});
async function testDbConnection() {
  try {
    await pool.query('SELECT 1'); // simple query to ensure connection works
    console.log('✅ Database connection successful');
  } catch (err) {
    console.error('❌ Database connection failed:', err.message);
    process.exit(1); // stop app if DB isn't reachable
  }
}
(async () => {
  await testDbConnection();
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, "0.0.0.0", () => {
    console.log(`API server running on port ${PORT}`);
  });


})();



