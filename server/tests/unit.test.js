const { loadConfig, DEV_JWT_SECRET } = require('../src/config');
const { createDatabase } = require('../src/db');
const { createUserRepository } = require('../src/userRepository');
const { createTokenService } = require('../src/tokens');

describe('loadConfig', () => {
  it('applies defaults outside production', () => {
    expect(loadConfig({})).toEqual({
      nodeEnv: 'development',
      port: 3000,
      databaseFile: 'app.sqlite',
      jwtSecret: DEV_JWT_SECRET,
      jwtExpiresIn: '1h',
      bcryptRounds: 10,
      trustProxy: false,
      corsOrigins: ['*'],
      loginRateLimit: { windowMs: 900000, max: 10 },
    });
  });

  it('reads values from the environment', () => {
    const config = loadConfig({
      NODE_ENV: 'production',
      PORT: '8080',
      DATABASE_FILE: '/data/x.db',
      JWT_SECRET: 's3cret',
      JWT_EXPIRES_IN: '7d',
      BCRYPT_ROUNDS: '12',
      TRUST_PROXY: 'true',
      CORS_ORIGINS: 'http://localhost:5173, https://app.example.com',
      LOGIN_RATE_LIMIT_WINDOW_MS: '1000',
      LOGIN_RATE_LIMIT_MAX: '3',
    });
    expect(config).toEqual({
      nodeEnv: 'production',
      port: 8080,
      databaseFile: '/data/x.db',
      jwtSecret: 's3cret',
      jwtExpiresIn: '7d',
      bcryptRounds: 12,
      trustProxy: true,
      corsOrigins: ['http://localhost:5173', 'https://app.example.com'],
      loginRateLimit: { windowMs: 1000, max: 3 },
    });
  });

  it('defaults to process.env', () => {
    expect(loadConfig().port).toBe(Number(process.env.PORT) || 3000);
  });

  it('refuses to start in production without JWT_SECRET', () => {
    expect(() => loadConfig({ NODE_ENV: 'production' })).toThrow('JWT_SECRET must be set in production');
  });
});

describe('userRepository', () => {
  let db;
  let users;
  beforeEach(() => {
    db = createDatabase();
    users = createUserRepository(db);
  });
  afterEach(() => db.close());

  it('creates and finds users', () => {
    const user = users.create({ email: 'a@b.co', name: 'A', passwordHash: 'h', businessSector: 's' });
    expect(users.findById(user.id)).toEqual(user);
    expect(users.findByEmailWithHash('A@B.CO')).toEqual({ user, passwordHash: 'h' });
  });

  it('returns null for unknown users', () => {
    expect(users.findById('usr_missing')).toBeNull();
    expect(users.findByEmailWithHash('missing@x.co')).toBeNull();
  });
});

describe('tokenService', () => {
  const tokens = createTokenService({ secret: 'k', expiresIn: '1h' });

  it('round-trips the user id', () => {
    expect(tokens.verify(tokens.sign('usr_1'))).toBe('usr_1');
  });

  it('returns null for invalid tokens', () => {
    expect(tokens.verify('nope')).toBeNull();
  });
});
