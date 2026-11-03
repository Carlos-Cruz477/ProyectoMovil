const request = require('supertest');
const { createDatabase } = require('../src/db');
const { createApp } = require('../src/app');
const { loadConfig } = require('../src/config');
const { createUserRepository } = require('../src/userRepository');
const { createTokenService } = require('../src/tokens');

describe('mentor discovery and confidential requests', () => {
  let db, app, token, user;
  beforeEach(() => {
    db = createDatabase(':memory:');
    const config = loadConfig({ NODE_ENV: 'test', JWT_SECRET: 'test-only', BCRYPT_ROUNDS: '4' });
    user = createUserRepository(db).create({ email: 'founder@example.com', name: 'Founder', passwordHash: 'unused', businessSector: 'Climate' });
    token = createTokenService({ secret: config.jwtSecret, expiresIn: '1h' }).sign(user.id);
    app = createApp({ db, config, logger: { error: jest.fn() } });
  });
  afterEach(() => db.close());
  const payload = { type: 'feedback', message: 'Me gustaría recibir consejo.', shareReport: false };
  const auth = (req) => req.set('Authorization', `Bearer ${token}`);

  it('requires a session for profiles and requests', async () => {
    expect((await request(app).get('/api/v1/mentors')).status).toBe(401);
    expect((await request(app).post('/api/v1/mentors/sofia/requests').send(payload)).status).toBe(401);
  });
  it('combines search and category filters', async () => {
    const res = await auth(request(app).get('/api/v1/mentors').query({ q: 'Sofía', category: 'Impacto & Clima' }));
    expect(res.status).toBe(200);
    expect(res.body.mentors.map(m => m.id)).toEqual(['sofia']);
    expect(res.body.mentors[0].demo).toBe(true);
    expect((await auth(request(app).get('/api/v1/mentors').query({ q: 'Sofía', category: 'B2B SaaS' }))).body.mentors).toEqual([]);
    expect((await auth(request(app).get('/api/v1/mentors').query({ category: 'Ángel Inversionistas' }))).body.mentors.map(m => m.id)).toEqual(['carlos']);
  });
  it('loads detail and handles missing profiles', async () => {
    expect((await auth(request(app).get('/api/v1/mentors/elena'))).body.mentor.name).toBe('Elena Rostova');
    expect((await auth(request(app).get('/api/v1/mentors/missing'))).status).toBe(404);
    expect((await auth(request(app).post('/api/v1/mentors/missing/requests')).send(payload)).status).toBe(404);
  });
  it('binds the request to its authenticated owner without sharing a report', async () => {
    const res = await auth(request(app).post('/api/v1/mentors/sofia/requests')).send({ ...payload, userId: 'spoofed' });
    expect(res.status).toBe(201);
    expect(res.body.request.status).toBe('recorded');
    const stored = db.prepare('SELECT * FROM mentor_requests').get();
    expect(stored.user_id).toBe(user.id);
    expect(stored.share_report).toBe(0);
    expect(stored.report_json).toBeNull();
    expect(JSON.stringify((await auth(request(app).get('/api/v1/mentors'))).body)).not.toContain(payload.message);
  });
  it('requires explicit consent before storing a report snapshot', async () => {
    const report = { tam: 1000, som: 20 };
    expect((await auth(request(app).post('/api/v1/mentors/sofia/requests')).send({ ...payload, report })).status).toBe(400);
    expect(db.prepare('SELECT count(*) AS n FROM mentor_requests').get().n).toBe(0);
    expect((await auth(request(app).post('/api/v1/mentors/sofia/requests')).send({ ...payload, shareReport: true, report })).status).toBe(201);
    expect(JSON.parse(db.prepare('SELECT report_json FROM mentor_requests').get().report_json)).toEqual(report);
  });
  it.each([
    { message: '' }, { message: ' '.repeat(20) }, { message: 'a'.repeat(241) },
    { type: 'unknown' }, { shareReport: 'true' }, { shareReport: true, report: [] },
  ])('validates request fields: %j', async (changes) => {
    expect((await auth(request(app).post('/api/v1/mentors/sofia/requests')).send({ ...payload, ...changes })).status).toBe(400);
  });
  it('counts user-visible Unicode characters consistently with Flutter', async () => {
    const family = '👨‍👩‍👧‍👦';
    expect((await auth(request(app).post('/api/v1/mentors/sofia/requests')).send({ ...payload, message: family.repeat(240) })).status).toBe(201);
    expect((await auth(request(app).post('/api/v1/mentors/sofia/requests')).send({ ...payload, message: family.repeat(241) })).status).toBe(400);
  });
  it('accepts 240 characters and each request type', async () => {
    for (const type of ['feedback', 'mentoring', 'pitch']) {
      expect((await auth(request(app).post('/api/v1/mentors/carlos/requests')).send({ ...payload, type, message: 'a'.repeat(240) })).status).toBe(201);
    }
  });
});
