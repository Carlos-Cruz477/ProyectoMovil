const request = require('supertest');
const jwt = require('jsonwebtoken');
const { BASE_PATH, expectToMatchContract, buildTestApp, validSignup } = require('./helpers');

const me = (app, authorization) => {
  const req = request(app).get(`${BASE_PATH}/auth/me`);
  return authorization === undefined ? req : req.set('Authorization', authorization);
};
const check = (res) => expectToMatchContract(res, 'GET', '/auth/me');

describe('GET /auth/me', () => {
  let app;
  let db;
  let config;
  let auth;
  beforeEach(async () => {
    ({ app, db, config } = buildTestApp());
    auth = (await request(app).post(`${BASE_PATH}/auth/signup`).send(validSignup())).body;
  });
  afterEach(() => db.close());

  it('returns the current user (200)', async () => {
    const res = await me(app, `Bearer ${auth.token}`);
    expect(res.status).toBe(200);
    check(res);
    expect(res.body).toEqual({ user: auth.user });
  });

  it('accepts a case-insensitive "bearer" scheme', async () => {
    const res = await me(app, `bearer ${auth.token}`);
    expect(res.status).toBe(200);
  });

  describe('401 unauthorized', () => {
    const expect401 = (res) => {
      expect(res.status).toBe(401);
      check(res);
      expect(res.body).toEqual({ error: 'unauthorized', message: 'A valid Bearer token is required' });
    };

    it('without Authorization header', async () => expect401(await me(app)));
    it('with a non-Bearer scheme', async () => expect401(await me(app, `Basic ${auth.token}`)));
    it('with an empty Bearer token', async () => expect401(await me(app, 'Bearer ')));
    it('with a garbage token', async () => expect401(await me(app, 'Bearer not.a.jwt')));

    it('with a token signed by another secret', async () => {
      const forged = jwt.sign({}, 'other-secret', { subject: auth.user.id });
      expect401(await me(app, `Bearer ${forged}`));
    });

    it('with an expired token', async () => {
      const expired = jwt.sign({ exp: Math.floor(Date.now() / 1000) - 10 }, config.jwtSecret, {
        subject: auth.user.id,
      });
      expect401(await me(app, `Bearer ${expired}`));
    });

    it('with an unsigned (alg=none) token', async () => {
      const none = jwt.sign({}, null, { algorithm: 'none', subject: auth.user.id });
      expect401(await me(app, `Bearer ${none}`));
    });

    it('with a token lacking a subject', async () => {
      const noSub = jwt.sign({ foo: 'bar' }, config.jwtSecret);
      expect401(await me(app, `Bearer ${noSub}`));
    });

    it('when the user no longer exists', async () => {
      db.prepare('DELETE FROM users').run();
      expect401(await me(app, `Bearer ${auth.token}`));
    });
  });
});
