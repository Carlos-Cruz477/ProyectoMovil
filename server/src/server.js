const { loadConfig } = require('./config');
const { createDatabase } = require('./db');
const { createApp } = require('./app');

function start({ env = process.env, logger = console } = {}) {
  const config = loadConfig(env);
  const db = createDatabase(config.databaseFile);
  const app = createApp({ db, config, logger });

  return new Promise((resolve) => {
    const server = app.listen(config.port, () => {
      logger.log(`App API listening on http://localhost:${server.address().port}/api/v1`);
      resolve({
        server,
        db,
        close: () =>
          new Promise((done) => {
            server.close(() => {
              db.close();
              done();
            });
          }),
      });
    });
  });
}


if (require.main === module) {
  start().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}

module.exports = { start };
