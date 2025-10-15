const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
require('dotenv').config();  
const fs = require('fs');
const https = require('https');
const http = require('http');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const path = require('path');



// --- Helper for JWT ---
const signToken = (payload) =>
  jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });
const app = express();


app.use(express.static(path.join(__dirname)));
app.use(cors());
app.use(express.json());
console.log("using hostname ", process.env.DB_HOST);
console.log("using port ", process.env.DB_PORT);

// MySQL connection pool using environment variables
const pool = mysql.createPool({
  host: process.env.DB_HOST,      
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
});



// --- API Routes ---
// --- Middleware: role-based auth ---
const roleAuth = (allowedRoles) => {
  return async (req, res, next) => {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.userId = decoded.id;

      const [rows] = await pool.query('SELECT role FROM users WHERE id = ?', [req.userId]);
      if (!rows.length) {
        return res.status(403).json({ success: false, message: '❌ User not found' });
      }

      const userRole = rows[0].role;
      if (!allowedRoles.includes(userRole)) {
        return res.status(403).json({ success: false, message: '❌ Access denied' });
      }

      req.userRole = userRole; 
      next();
    } catch {
      return res.status(401).json({ success: false, message: 'Invalid/Expired token' });
    }
  };
};

// Simple JWT auth middleware
const auth = async (req, res, next) => {
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

// Save result (insert with negative marking calculation)
app.post('/results', async (req, res) => {
  try {
    const { user_id, mock_id, answers, time_taken_minutes } = req.body;
    // answers = array of { question_id, selected_option }

    // 1. Get mock test details (to fetch negative_marking)
    const [mockTestRows] = await pool.query(
      'SELECT negative_marking , total_marks FROM mock_tests WHERE id = ?',
      [mock_id]
    );
    if (!mockTestRows.length) {
      return res.status(404).json({ error: "Mock test not found" });
    }
    const negativeMarking = mockTestRows[0].negative_marking || 0;

    // 2. Get all questions for this mock test
    const [questions] = await pool.query(
      'SELECT id, correct_answer, marks FROM questions WHERE mock_id = ?',
      [mock_id]
    );

    // 3. Calculate score
    let score = 0.0;
    let correctCount = 0;
    let wrongCount = 0;
    let unattemptedCount = 0;

    for (let q of questions) {
      const userAns = answers.find(a => a.question_id === q.id);
      if (!userAns || !userAns.selected_option) {
        unattemptedCount++;
        continue;
      }

      if (userAns.selected_option === q.correct_answer) {
        score += parseFloat(q.marks);   // full marks
        correctCount++;
      } else {
        score -= parseFloat(negativeMarking);  // deduct negative
        wrongCount++;
      }
    }

    if (score < 0) score = 0.0; // prevent negative total score

    score = parseFloat(score.toFixed(2));
    // 4. Save result in DB
    const [result] = await pool.query(
      'INSERT INTO results (user_id, mock_id, score, total_marks, time_taken_minutes) VALUES (?, ?, ?, ?, ?)',
      [user_id, mock_id, score, parseFloat(mockTestRows[0].total_marks),  time_taken_minutes]
    );

    res.json({
      message: 'Result saved with negative marking',
      id: result.insertId,
      score,
      correctCount,
      wrongCount,
      unattemptedCount,
      negativeMarking
    });

  } catch (err) {
    console.error("RESULT SAVE ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});


// Add new question (editor + admin allowed)
app.post('/questions', roleAuth(['admin', 'editor']), async (req, res) => {
  try {
    const { mock_id, question_text, options, correct_answer, marks } = req.body;

    if (!mock_id || !question_text || !options || !correct_answer) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const optionsJson = typeof options === "string" ? options : JSON.stringify(options);

    const [result] = await pool.query(
      `INSERT INTO questions (mock_id, question_text, options, correct_answer, marks, status)
       VALUES (?, ?, ?, ?, ?, 'draft')`,
      [mock_id, question_text, optionsJson, correct_answer, marks || 1]
    );

    res.json({ message: "✅ Question saved as draft", id: result.insertId });
  } catch (err) {
    console.error("QUESTION INSERT ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

//  Get mock tests by status (default = draft)
app.get('/mock_tests', roleAuth(['admin', 'publisher']), async (req, res) => {
  try {
    const status = req.query.status || 'draft';
    const [rows] = await pool.query('SELECT * FROM mock_tests WHERE status = ?', [status]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update question status (approve/reject) - only admin/publisher
app.patch('/questions/:id/status', roleAuth(['admin', 'publisher']), async (req, res) => {
  try {

    const questionId = req.params.id;
    const { status } = req.body; 
    console.log("PATCH BODY:", req.body);
   
    let dbStatus;
    let s = status.toLowerCase(); 
    if (s === 'approved' || s === 'live') dbStatus = 'live';
    else if (s === 'rejected' || s === 'draft') dbStatus = 'draft';
    else return res.status(400).json({ error: "Invalid status" });

    const [result] = await pool.query(
      'UPDATE questions SET status = ? WHERE id = ?',
      [dbStatus, questionId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Question not found" });
    }

    res.json({ message: `Question ${status} successfully` });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all pending questions
app.get('/questions', roleAuth(['admin', 'publisher']), async (req, res) => {
  try {
    const status = req.query.status || 'draft';
    const [rows] = await pool.query('SELECT * FROM questions WHERE status = ?', [status]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add new mock test (Admin + Editor)
app.post('/mock_tests', roleAuth(['admin', 'editor']), async (req, res) => {
  try {
    const { exam_id, title, duration_minutes, difficulty, total_marks, negative_marking } = req.body;

    if (!exam_id || !title || !duration_minutes) {
      return res.status(400).json({ error: "exam_id, title, duration_minutes required" });
    }

    const [result] = await pool.query(
      `INSERT INTO mock_tests (exam_id, title, duration_minutes, difficulty, total_marks, negative_marking, status)
       VALUES (?, ?, ?, ?, ?, ?, 'draft')`,
      [exam_id, title, duration_minutes, difficulty || 'Medium', total_marks || 100, negative_marking || null]
    );

    res.json({ message: "✅ Mock test created (draft)", id: result.insertId });
  } catch (err) {
    console.error("MOCK TEST INSERT ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

// Update mock test status (approve/reject) - only admin/publisher
app.patch('/mock_tests/:id/status', roleAuth(['admin', 'publisher']), async (req, res) => {
  try {
    const mockId = req.params.id;
    const { status } = req.body;

    let dbStatus;
    const s = status.toLowerCase();
    if (s === 'approved' || s === 'live') dbStatus = 'live';
    else if (s === 'rejected' || s === 'draft') dbStatus = 'draft';
    else return res.status(400).json({ error: "Invalid status" });

    const [result] = await pool.query(
      'UPDATE mock_tests SET status = ? WHERE id = ?',
      [dbStatus, mockId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Mock test not found" });
    }

    res.json({ message: `Mock test ${dbStatus} successfully` });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete question (Admin only)
app.delete('/questions/:id', roleAuth(['admin']), async (req, res) => {
  try {
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

// Get results with mock test names
app.get('/results/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const [rows] = await pool.query(
      `SELECT r.id, r.mock_id, r.score, r.time_taken_minutes, r.date_taken,
              m.title AS title, m.total_marks
       FROM results r
       JOIN mock_tests m ON r.mock_id = m.id
       WHERE r.user_id = ?
       ORDER BY r.date_taken DESC`,
      [userId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Auth Routes ---
// SIGNUP
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
      'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
      [name, email, hash, 'user'] 
    );

    const user = { id: result.insertId, name, email, role: 'user' };
    const token = signToken({ id: user.id });

    return res.status(201).json({ success: true, token, user });
  } catch (e) {
    console.error('SIGNUP ERROR:', e);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// LOGIN
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ success: false, message: 'email and password required' });

  try {
    const [rows] = await pool.query(
      'SELECT id, name, email, password, role FROM users WHERE email = ?',
      [email]
    );
    if (!rows.length)
      return res.status(401).json({ success: false, message: 'Invalid email or password' });

    const row = rows[0];
    const ok = await bcrypt.compare(password, row.password);
    if (!ok)
      return res.status(401).json({ success: false, message: 'Invalid email or password' });

    const user = { id: row.id, name: row.name, email: row.email, role: row.role };
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
      'SELECT id, name, email, profile_picture , created_at FROM users WHERE id = ?',
      [req.userId]
    );
    if (!rows.length) return res.status(404).json({ success: false, message: 'User not found' });

    return res.json({ success: true, user: rows[0] });
  } catch (e) {
    console.error('PROFILE ERROR:', e);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});


// Serve the frontend
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

// Admin login page
app.get('/admin/login', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin_login.html'));
});

// Admin panel page
app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin.html'));
});



//test db connection
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

  const PORT = process.env.PORT || 80;     // HTTP redirect port
  const HTTPS_PORT = process.env.HTTPS_PORT || 3443; // HTTPS port

  if (process.env.NODE_ENV === 'production') {
    const httpsOptions = {
      key: fs.readFileSync('/etc/letsencrypt/live/rankyard.in/privkey.pem'),
      cert: fs.readFileSync('/etc/letsencrypt/live/rankyard.in/fullchain.pem')
    };

    // ✅ HTTPS server
    https.createServer(httpsOptions, app).listen(HTTPS_PORT, "0.0.0.0", () => {
      console.log(`🚀 HTTPS Server running on port ${HTTPS_PORT}`);
    });

    // ✅ HTTP redirect to HTTPS
    http.createServer((req, res) => {
      const host = req.headers.host.split(':')[0]; // remove any port if exists
      res.writeHead(301, { Location: `https://${host}:${HTTPS_PORT}${req.url}` });
      res.end();
    }).listen(PORT, "0.0.0.0", () => {
      console.log(`🌐 HTTP redirect enabled on port ${PORT}`);
    });

  } else {
    // Dev server
    app.listen(PORT, () => console.log(`🌐 Dev server running on http://localhost:${PORT}`));
  }
})();
