const express = require('express');
const { createUserRepository } = require('./userRepository');
const { createTokenService } = require('./tokens');
const { createAuthRouter } = require('./routes/auth');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');
const { cors } = require('./middleware/cors');

function createApp({ db, config, logger = console }) {
  const users = createUserRepository(db);
  const tokens = createTokenService({ secret: config.jwtSecret, expiresIn: config.jwtExpiresIn });

  const app = express();
  app.disable('x-powered-by');
  app.set('trust proxy', config.trustProxy);
  app.use(cors({ origins: config.corsOrigins }));
  app.use(express.json({ limit: '100kb' }));

  app.get('/health', (_req, res) => res.json({ status: 'ok' }));

  app.use(
    '/api/v1/auth',
    createAuthRouter({
      users,
      tokens,
      bcryptRounds: config.bcryptRounds,
      loginRateLimit: config.loginRateLimit,
    }),
  );

  app.use(notFoundHandler);
  app.use(errorHandler(logger));
  return app;
}

module.exports = { createApp };
