const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// MySQL connection pool
const pool = mysql.createPool({
  host: 'localhost',   // apka DB host
  user: 'root',        // apka mysql user
  password: 'Riya@bis2929',        // apka mysql password
  database: 'exam_app' // apka database name
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

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API server running on http://localhost:${PORT}`);
});
