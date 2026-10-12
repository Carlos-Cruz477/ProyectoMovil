const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { start } = require('../src/server');

describe('server.start', () => {
  it('listens on the configured port with a file-backed database', async () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'app-'));
    const logger = { log: jest.fn(), error: jest.fn() };
    const { server, close } = await start({
      env: { NODE_ENV: 'test', PORT: '0', DATABASE_FILE: path.join(dir, 'test.sqlite'), JWT_SECRET: 'x' },
      logger,
    });
    try {
      const { port } = server.address();
      const res = await fetch(`http://127.0.0.1:${port}/health`);
      expect(res.status).toBe(200);
      expect(logger.log).toHaveBeenCalledWith(expect.stringContaining('/api/v1'));
      expect(fs.existsSync(path.join(dir, 'test.sqlite'))).toBe(true);
    } finally {
      await close();
      fs.rmSync(dir, { recursive: true, force: true });
    }
  });
});

describe('server.start defaults', () => {
  it('falls back to process.env and console', async () => {
    const saved = { ...process.env };
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'app-'));
    Object.assign(process.env, { PORT: '0', DATABASE_FILE: path.join(dir, 'db.sqlite'), JWT_SECRET: 'x' });
    const spy = jest.spyOn(console, 'log').mockImplementation(() => {});
    try {
      const { close } = await start();
      expect(spy).toHaveBeenCalledWith(expect.stringContaining('App API listening'));
      await close();
    } finally {
      spy.mockRestore();
      process.env = saved;
      fs.rmSync(dir, { recursive: true, force: true });
    }
  });
});
