const express = require('express');
const bcrypt = require('bcryptjs');
const { rateLimit } = require('express-rate-limit');
const { validateSignup, validateLogin } = require('../validation');
const { conflict, invalidCredentials } = require('../errors');
const { authenticate } = require('../middleware/authenticate');

function createAuthRouter({ users, tokens, bcryptRounds, loginRateLimit }) {
  const router = express.Router();

  const dummyHash = bcrypt.hashSync('dummy-password-for-timing', bcryptRounds);

  const loginLimiter = rateLimit({
    windowMs: loginRateLimit.windowMs,
    limit: loginRateLimit.max,
    skipSuccessfulRequests: true,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    handler: (_req, res) =>
      res.status(429).json({
        error: 'too_many_requests',
        message: 'Too many login attempts. Please try again later.',
      }),
  });

  router.post('/signup', async (req, res) => {
    const { email, name, password, businessSector } = validateSignup(req.body);
    if (users.findByEmailWithHash(email)) {
      throw conflict('A user with this email already exists');
    }
    const passwordHash = await bcrypt.hash(password, bcryptRounds);
    let user;
    try {
      user = users.create({ email, name, passwordHash, businessSector });
    } catch (err) {

      if (err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
        throw conflict('A user with this email already exists');
      }
      throw err;
    }
    res.status(200).json({ token: tokens.sign(user.id), user });
  });

  router.post('/login', loginLimiter, async (req, res) => {
    res.set('Access-Control-Allow-Origin', '*' );
    const { email, password } = validateLogin(req.body);
    const record = users.findByEmailWithHash(email);
    const ok = await bcrypt.compare(password, record ? record.passwordHash : dummyHash);
    if (!record || !ok) throw invalidCredentials();
    res.status(200).json({ token: tokens.sign(record.user.id), user: record.user });
  });

  router.get('/me', authenticate({ tokens, users }), (req, res) => {
    res.status(200).json({ user: req.user });
  });

  return router;
}

module.exports = { createAuthRouter };
