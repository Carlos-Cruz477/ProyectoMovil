const request = require('supertest');
const { buildTestApp } = require('./helpers');

describe('app', () => {
  let app;
  let db;
  beforeEach(() => ({ app, db } = buildTestApp()));
  afterEach(() => db.close());

  it('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });

  it('returns 404 JSON for unknown routes', async () => {
    const res = await request(app).get('/api/v1/nope');
    expect(res.status).toBe(404);
    expect(res.body).toEqual({ error: 'not_found', message: 'Route GET /api/v1/nope not found' });
  });

  it('does not advertise Express', async () => {
    const res = await request(app).get('/health');
    expect(res.headers['x-powered-by']).toBeUndefined();
  });

  it('rejects oversized bodies with a JSON 413', async () => {
    const res = await request(app)
      .post('/api/v1/auth/signup')
      .set('Content-Type', 'application/json')
      .send(JSON.stringify({ name: 'a'.repeat(200 * 1024) }));
    expect(res.status).toBe(413);
    expect(res.body).toEqual({ error: 'bad_request', message: 'request entity too large' });
  });

  it('logs to console by default', async () => {
    const { createApp } = require('../src/app');
    const { createDatabase } = require('../src/db');
    const spy = jest.spyOn(console, 'error').mockImplementation(() => {});
    const db2 = createDatabase();
    const app2 = createApp({ db: db2, config: buildTestApp().config });
    db2.exec('DROP TABLE users');
    const res2 = await request(app2).post('/api/v1/auth/login').send({ email: 'a@b.co', password: 'x' });
    expect(res2.status).toBe(500);
    expect(spy).toHaveBeenCalled();
    spy.mockRestore();
    db2.close();
  });
});
