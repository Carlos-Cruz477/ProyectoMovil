const { validationError } = require('./errors');


const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function requireObject(body) {
  if (body === null || typeof body !== 'object' || Array.isArray(body)) {
    throw validationError('Request body must be a JSON object');
  }
}

function requireString(body, field, label) {
  const value = body[field];
  if (value === undefined || value === null) {
    throw validationError(`${label} is required`);
  }
  if (typeof value !== 'string') {
    throw validationError(`${label} must be a string`);
  }
  return value;
}

function parseEmail(body) {
  const email = requireString(body, 'email', 'Email').trim();
  if (!email) throw validationError('Email is required');
  if (!EMAIL_RE.test(email)) throw validationError('Email must be a valid email address');
  return email.toLowerCase();
}

function validateSignup(body) {
  requireObject(body);
  const email = parseEmail(body);

  const name = requireString(body, 'name', 'Name').trim();
  if (!name) throw validationError('Name is required');
  if (name.length > 100) throw validationError('Name must be at most 100 characters');

  const password = requireString(body, 'password', 'Password');
  if (password.length < 8) throw validationError('Password must be at least 8 characters');

  const businessSector = requireString(body, 'businessSector', 'Business sector').trim();
  if (!businessSector) throw validationError('Business sector is required');

  return { email, name, password, businessSector };
}

function validateLogin(body) {
  requireObject(body);
  const email = requireString(body, 'email', 'Email').trim().toLowerCase();
  if (!email) throw validationError('Email is required');
  const password = requireString(body, 'password', 'Password');
  if (!password) throw validationError('Password is required');
  return { email, password };
}

module.exports = { validateSignup, validateLogin };
