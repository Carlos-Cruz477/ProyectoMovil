const Database = require('better-sqlite3');

const SCHEMA = `
  CREATE TABLE IF NOT EXISTS users (
    id              TEXT PRIMARY KEY,
    email           TEXT NOT NULL UNIQUE COLLATE NOCASE,
    name            TEXT NOT NULL,
    password_hash   TEXT NOT NULL,
    business_sector TEXT NOT NULL,
    created_at      TEXT NOT NULL
  );
`;

function createDatabase(filename = ':memory:') {
  const db = new Database(filename);
  db.pragma('journal_mode = WAL');
  db.pragma('foreign_keys = ON');
  db.exec(SCHEMA);
  return db;
}

module.exports = { createDatabase };
