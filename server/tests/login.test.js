const request = require('supertest');
const { BASE_PATH, expectToMatchContract, buildTestApp, validSignup } = require('./helpers');

const login = (app, body) => request(app).post(`${BASE_PATH}/auth/login`).send(body);
const check = (res) => expectToMatchContract(res, 'POST', '/auth/login');

describe('POST /auth/login', () => {
  let app;
  let db;
  let signedUp;
  beforeEach(async () => {
    ({ app, db } = buildTestApp());
    signedUp = (await request(app).post(`${BASE_PATH}/auth/signup`).send(validSignup())).body;
  });
  afterEach(() => db.close());

  it('returns token + profile for valid credentials (200)', async () => {
    const res = await login(app, { email: 'user@example.com', password: 'securePass123!' });
    expect(res.status).toBe(200);
    check(res);
    expect(res.body.user).toEqual(signedUp.user);
    expect(typeof res.body.token).toBe('string');
  });

  it('trims and case-normalizes the email', async () => {
    const res = await login(app, { email: '  USER@example.com ', password: 'securePass123!' });
    expect(res.status).toBe(200);
  });

  it('issued token authenticates /auth/me', async () => {
    const { body } = await login(app, { email: 'user@example.com', password: 'securePass123!' });
    const me = await request(app).get(`${BASE_PATH}/auth/me`).set('Authorization', `Bearer ${body.token}`);
    expect(me.status).toBe(200);
    expect(me.body.user.id).toBe(signedUp.user.id);
  });

  describe('401 invalid_credentials', () => {
    it.each([
      ['wrong password', { email: 'user@example.com', password: 'wrongPass123!' }],
      ['unknown email', { email: 'nobody@example.com', password: 'securePass123!' }],
      ['password is case-sensitive', { email: 'user@example.com', password: 'SECUREPASS123!' }],
    ])('%s', async (_label, body) => {
      const res = await login(app, body);
      expect(res.status).toBe(401);
      check(res);
      expect(res.body).toEqual({ error: 'invalid_credentials', message: 'Email or password is incorrect' });
    });
  });

  describe('400 validation_error', () => {
    it.each([
      ['missing email', { password: 'x' }, 'Email is required'],
      ['blank email', { email: '  ', password: 'x' }, 'Email is required'],
      ['missing password', { email: 'user@example.com' }, 'Password is required'],
      ['empty password', { email: 'user@example.com', password: '' }, 'Password is required'],
      ['non-string password', { email: 'user@example.com', password: 123 }, 'Password must be a string'],
    ])('%s', async (_label, body, message) => {
      const res = await login(app, body);
      expect(res.status).toBe(400);
      expect(res.body).toEqual({ error: 'validation_error', message });
    });
  });
});

describe('POST /auth/login rate limiting', () => {
  it('returns 429 after too many failed attempts', async () => {
    const { app, db, config } = buildTestApp({ loginRateLimit: { windowMs: 60_000, max: 3 } });
    await request(app).post(`${BASE_PATH}/auth/signup`).send(validSignup());
    const bad = { email: 'user@example.com', password: 'wrongPass123!' };

    for (let i = 0; i < config.loginRateLimit.max; i += 1) {
      expect((await login(app, bad)).status).toBe(401);
    }
    const res = await login(app, bad);
    expect(res.status).toBe(429);
    check(res);
    expect(res.body.error).toBe('too_many_requests');

    expect((await login(app, { email: 'user@example.com', password: 'securePass123!' })).status).toBe(429);
    db.close();
  });

  it('does not count successful logins toward the limit', async () => {
    const { app, db } = buildTestApp({ loginRateLimit: { windowMs: 60_000, max: 2 } });
    await request(app).post(`${BASE_PATH}/auth/signup`).send(validSignup());
    const good = { email: 'user@example.com', password: 'securePass123!' };
    for (let i = 0; i < 5; i += 1) {
      expect((await login(app, good)).status).toBe(200);
    }
    db.close();
  });
});
