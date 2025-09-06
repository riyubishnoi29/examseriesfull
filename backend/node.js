const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function createAdmin() {
  // 1️⃣ Connect to your MySQL database
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,        // your DB host
    user: process.env.DB_USER,     // your DB username
    password: process.env.DB_PASS, // your DB password
    database: process.env.DB_NAME      // your database name
  });

  // 2️⃣ Hash the password
  const plainPassword = 'admin@0123456789'; // password you want
  const hashedPassword = await bcrypt.hash(plainPassword, 10);

  // 3️⃣ Insert admin user
  await connection.execute(
    "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)",
    ['Admin', 'admin@exam.com', hashedPassword, 'admin']
  );

  console.log("✅ Admin user created successfully!");
  process.exit();
}

createAdmin();
