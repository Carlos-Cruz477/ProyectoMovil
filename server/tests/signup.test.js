const request = require('supertest');
const bcrypt = require('bcryptjs');
const { BASE_PATH, expectToMatchContract, buildTestApp, validSignup } = require('./helpers');

const URL_ = `${BASE_PATH}/auth/signup`;
const signup = (app, body) => request(app).post(URL_).send(body);
const check = (res) => expectToMatchContract(res, 'POST', '/auth/signup');

describe('POST /auth/signup', () => {
  let app;
  let db;
  let logger;
  beforeEach(() => ({ app, db, logger } = buildTestApp()));
  afterEach(() => {
    jest.restoreAllMocks();
    db.close();
  });

  it('creates a user and returns token + profile (200)', async () => {
    const res = await signup(app, validSignup());
    expect(res.status).toBe(200);
    check(res);
    expect(res.body.user).toEqual({
      id: expect.stringMatching(/^usr_[0-9a-f]{24}$/),
      name: 'Jane Doe',
      email: 'user@example.com',
      businessSector: 'technology',
      createdAt: expect.any(String),
    });
    expect(new Date(res.body.user.createdAt).toISOString()).toBe(res.body.user.createdAt);
    expect(res.body.token.split('.')).toHaveLength(3);
  });

  it('never exposes the password or its hash', async () => {
    const res = await signup(app, validSignup());
    const raw = JSON.stringify(res.body);
    expect(raw).not.toContain('securePass123!');
    expect(raw).not.toMatch(/password/i);
  });

  it('stores a bcrypt hash, not the plain password', async () => {
    await signup(app, validSignup());
    const row = db.prepare('SELECT password_hash FROM users').get();
    expect(row.password_hash).toMatch(/^\$2[aby]\$/);
  });

  it('trims email, name and business sector and lowercases email', async () => {
    const res = await signup(app, {
      ...validSignup(),
      email: '  User@Example.COM ',
      name: '  Jane Doe  ',
      businessSector: ' technology ',
    });
    expect(res.status).toBe(200);
    expect(res.body.user).toMatchObject({
      email: 'user@example.com',
      name: 'Jane Doe',
      businessSector: 'technology',
    });
  });

  it('returned token works with /auth/me', async () => {
    const { body } = await signup(app, validSignup());
    const me = await request(app).get(`${BASE_PATH}/auth/me`).set('Authorization', `Bearer ${body.token}`);
    expect(me.status).toBe(200);
    expect(me.body.user).toEqual(body.user);
  });

  it('accepts a name of exactly 100 characters', async () => {
    const res = await signup(app, { ...validSignup(), name: 'a'.repeat(100) });
    expect(res.status).toBe(200);
  });

  it('accepts a password of exactly 8 characters', async () => {
    const res = await signup(app, { ...validSignup(), password: '12345678' });
    expect(res.status).toBe(200);
  });

  describe('409 conflict', () => {
    it('rejects a duplicate email', async () => {
      await signup(app, validSignup());
      const res = await signup(app, validSignup());
      expect(res.status).toBe(409);
      check(res);
      expect(res.body).toEqual({ error: 'conflict', message: 'A user with this email already exists' });
    });

    it('treats emails case-insensitively', async () => {
      await signup(app, validSignup());
      const res = await signup(app, { ...validSignup(), email: 'USER@example.com' });
      expect(res.status).toBe(409);
    });

    it('maps a unique-constraint race to 409', async () => {
      const realHash = bcrypt.hash;

      jest.spyOn(bcrypt, 'hash').mockImplementationOnce(async (...args) => {
        db.prepare(
          `INSERT INTO users (id, email, name, password_hash, business_sector, created_at)
           VALUES ('usr_racer', 'user@example.com', 'Racer', 'x', 'tech', '2026-01-01T00:00:00.000Z')`,
        ).run();
        return realHash(...args);
      });
      const res = await signup(app, validSignup());
      expect(res.status).toBe(409);
      check(res);
    });
  });

  it('returns 500 with a generic body on unexpected database errors', async () => {
    const realHash = bcrypt.hash;
    jest.spyOn(bcrypt, 'hash').mockImplementationOnce(async (...args) => {
      db.exec('DROP TABLE users');
      return realHash(...args);
    });
    const res = await signup(app, validSignup());
    expect(res.status).toBe(500);
    expect(res.body).toEqual({ error: 'internal_error', message: 'An unexpected error occurred' });
    expect(logger.error).toHaveBeenCalled();
  });

  describe('400 validation_error', () => {
    const cases = [
      ['missing email', { email: undefined }, 'Email is required'],
      ['null email', { email: null }, 'Email is required'],
      ['blank email', { email: '   ' }, 'Email is required'],
      ['non-string email', { email: 42 }, 'Email must be a string'],
      ['malformed email', { email: 'not-an-email' }, 'Email must be a valid email address'],
      ['missing name', { name: undefined }, 'Name is required'],
      ['blank name', { name: '   ' }, 'Name is required'],
      ['name too long', { name: 'a'.repeat(101) }, 'Name must be at most 100 characters'],
      ['missing password', { password: undefined }, 'Password is required'],
      ['short password', { password: '1234567' }, 'Password must be at least 8 characters'],
      ['non-string password', { password: 12345678 }, 'Password must be a string'],
      ['missing businessSector', { businessSector: undefined }, 'Business sector is required'],
      ['blank businessSector', { businessSector: '  ' }, 'Business sector is required'],
    ];

    it.each(cases)('%s', async (_label, patch, message) => {
      const res = await signup(app, { ...validSignup(), ...patch });
      expect(res.status).toBe(400);
      check(res);
      expect(res.body).toEqual({ error: 'validation_error', message });
    });

    it('rejects a non-object JSON body', async () => {
      const res = await request(app).post(URL_).set('Content-Type', 'application/json').send('[1,2]');
      expect(res.status).toBe(400);
      check(res);
      expect(res.body.message).toBe('Request body must be a JSON object');
    });

    it('rejects a missing body', async () => {
      const res = await request(app).post(URL_);
      expect(res.status).toBe(400);
      check(res);
    });

    it('rejects malformed JSON', async () => {
      const res = await request(app).post(URL_).set('Content-Type', 'application/json').send('{"email":');
      expect(res.status).toBe(400);
      check(res);
      expect(res.body).toEqual({ error: 'validation_error', message: 'Request body is not valid JSON' });
    });
  });
});
