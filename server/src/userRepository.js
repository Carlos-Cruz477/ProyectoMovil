const crypto = require('node:crypto');

function toUser(row) {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    businessSector: row.business_sector,
    projectStage: row.project_stage ?? null,
    createdAt: row.created_at,
  };
}

function createUserRepository(db) {
  const insertStmt = db.prepare(`
    INSERT INTO users (id, email, name, password_hash, business_sector, project_stage, created_at)
    VALUES (@id, @email, @name, @passwordHash, @businessSector, NULL, @createdAt)
  `);
  const byEmailStmt = db.prepare('SELECT * FROM users WHERE email = ?');
  const byIdStmt = db.prepare('SELECT * FROM users WHERE id = ?');
  const updateProjectStageStmt = db.prepare(
    'UPDATE users SET project_stage = ? WHERE id = ?',
  );

  return {
    create({ email, name, passwordHash, businessSector }) {
      const row = {
        id: `usr_${crypto.randomBytes(12).toString('hex')}`,
        email,
        name,
        passwordHash,
        businessSector,
        createdAt: new Date().toISOString(),
      };
      insertStmt.run(row);
      return toUser({ ...row, business_sector: row.businessSector, created_at: row.createdAt });
    },


    findByEmailWithHash(email) {
      const row = byEmailStmt.get(email);
      return row ? { user: toUser(row), passwordHash: row.password_hash } : null;
    },

    findById(id) {
      const row = byIdStmt.get(id);
      return row ? toUser(row) : null;
    },

    updateProjectStage(id, projectStage) {
      const result = updateProjectStageStmt.run(projectStage, id);
      if (result.changes === 0) return null;
      return toUser(byIdStmt.get(id));
    },
  };
}

module.exports = { createUserRepository };
