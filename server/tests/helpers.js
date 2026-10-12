const fs = require('node:fs');
const path = require('node:path');
const yaml = require('js-yaml');
const Ajv = require('ajv');
const addFormats = require('ajv-formats');
const { createDatabase } = require('../src/db');
const { createApp } = require('../src/app');
const { loadConfig } = require('../src/config');

const spec = yaml.load(fs.readFileSync(path.join(__dirname, '..', '..', 'openapi.yaml'), 'utf8'));
const BASE_PATH = new URL(spec.servers[0].url).pathname; 

const ajv = new Ajv({ strict: false, allErrors: true });
addFormats(ajv);
ajv.addFormat('password', true);

ajv.addSchema(
  JSON.parse(JSON.stringify({ components: spec.components }).replaceAll('"#/components', '"openapi#/components')),
  'openapi',
);


function expectToMatchContract(res, method, apiPath) {
  const operation = spec.paths[apiPath]?.[method.toLowerCase()];
  if (!operation) throw new Error(`No operation ${method} ${apiPath} in openapi.yaml`);
  const response = operation.responses[String(res.status)];
  if (!response) {
    throw new Error(`Status ${res.status} is not documented for ${method} ${apiPath}`);
  }
  expect(res.headers['content-type']).toMatch(/application\/json/);
  const schema = JSON.parse(
    JSON.stringify(response.content['application/json'].schema).replaceAll(
      '"#/components',
      '"openapi#/components',
    ),
  );
  const validate = ajv.compile(schema);
  if (!validate(res.body)) {
    throw new Error(`Response does not match contract: ${ajv.errorsText(validate.errors)}`);
  }
}

function buildTestApp(overrides = {}) {
  const config = {
    ...loadConfig({ NODE_ENV: 'test', JWT_SECRET: 'test-secret', BCRYPT_ROUNDS: '4' }),
    ...overrides,
  };
  const db = createDatabase(':memory:');
  const logger = { error: jest.fn(), log: jest.fn() };
  const app = createApp({ db, config, logger });
  return { app, db, config, logger };
}

const validSignup = () => ({
  email: 'user@example.com',
  name: 'Jane Doe',
  password: 'securePass123!',
  businessSector: 'technology',
});

module.exports = { spec, BASE_PATH, expectToMatchContract, buildTestApp, validSignup };
