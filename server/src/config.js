const DEV_JWT_SECRET = 'dev-only-insecure-secret-change-me';

function loadConfig(env = process.env) {
  const nodeEnv = env.NODE_ENV || 'development';
  const jwtSecret = env.JWT_SECRET || (nodeEnv === 'production' ? null : DEV_JWT_SECRET);
  if (!jwtSecret) {
    throw new Error('JWT_SECRET must be set in production');
  }

  return {
    nodeEnv,
    port: Number(env.PORT) || 3000,
    databaseFile: env.DATABASE_FILE || 'app.sqlite',
    jwtSecret,
    jwtExpiresIn: env.JWT_EXPIRES_IN || '1h',
    bcryptRounds: Number(env.BCRYPT_ROUNDS) || 10,

    trustProxy: env.TRUST_PROXY === 'true',

    corsOrigins: (env.CORS_ORIGINS || '*').split(',').map((o) => o.trim()).filter(Boolean),
    loginRateLimit: {
      windowMs: Number(env.LOGIN_RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
      max: Number(env.LOGIN_RATE_LIMIT_MAX) || 10,
    },
  };
}

module.exports = { loadConfig, DEV_JWT_SECRET };
