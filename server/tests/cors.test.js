const request = require('supertest');
const { buildTestApp, BASE_PATH } = require('./helpers');

describe('CORS', () => {
  let db;
  afterEach(() => db.close());

  describe('allowing any origin (default)', () => {
    let app;
    beforeEach(() => ({ app, db } = buildTestApp()));

    it('answers preflight requests with 204 and CORS headers', async () => {
      const res = await request(app)
        .options(`${BASE_PATH}/auth/login`)
        .set('Origin', 'http://localhost:5173')
        .set('Access-Control-Request-Method', 'POST')
        .set('Access-Control-Request-Headers', 'content-type,authorization');
      expect(res.status).toBe(204);
      expect(res.headers['access-control-allow-origin']).toBe('*');
      expect(res.headers['access-control-allow-methods']).toContain('POST');
      expect(res.headers['access-control-allow-headers']).toBe('Authorization, Content-Type');
      expect(res.headers['access-control-max-age']).toBe('600');
    });

    it('adds the allow-origin header to regular responses', async () => {
      const res = await request(app).get('/health').set('Origin', 'http://localhost:5173');
      expect(res.status).toBe(200);
      expect(res.headers['access-control-allow-origin']).toBe('*');
    });

    it('adds the allow-origin header to error responses', async () => {
      const res = await request(app).get(`${BASE_PATH}/auth/me`).set('Origin', 'http://localhost:5173');
      expect(res.status).toBe(401);
      expect(res.headers['access-control-allow-origin']).toBe('*');
    });

    it('omits CORS headers for same-origin / non-browser requests', async () => {
      const res = await request(app).get('/health');
      expect(res.headers['access-control-allow-origin']).toBeUndefined();
    });
  });

  describe('with an origin allowlist', () => {
    let app;
    beforeEach(() => ({ app, db } = buildTestApp({ corsOrigins: ['https://app.example.com'] })));

    it('echoes an allowed origin', async () => {
      const res = await request(app).get('/health').set('Origin', 'https://app.example.com');
      expect(res.headers['access-control-allow-origin']).toBe('https://app.example.com');
      expect(res.headers.vary).toContain('Origin');
    });

    it('does not allow other origins', async () => {
      const res = await request(app)
        .options(`${BASE_PATH}/auth/login`)
        .set('Origin', 'https://evil.example.com')
        .set('Access-Control-Request-Method', 'POST');
      expect(res.status).toBe(204);
      expect(res.headers['access-control-allow-origin']).toBeUndefined();
    });
  });
});
