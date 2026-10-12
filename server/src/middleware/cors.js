const ALLOWED_METHODS = 'GET, POST, PUT, PATCH, DELETE, OPTIONS';
const ALLOWED_HEADERS = 'Authorization, Content-Type';
const PREFLIGHT_MAX_AGE_SECONDS = '600';

/**
 * Minimal CORS support. `origins` is a list of allowed origins, or ['*'] to allow any.
 * Auth uses bearer tokens (no cookies), so credentials are never enabled.
 */
function cors({ origins }) {
  const allowAny = origins.includes('*');
  const allowed = new Set(origins);

  return (req, res, next) => {
    const origin = req.get('origin');
    res.vary('Origin');
    if (origin && (allowAny || allowed.has(origin))) {
      res.set('Access-Control-Allow-Origin', allowAny ? '*' : origin);
    }

    if (req.method === 'OPTIONS') {
      res.set({
        'Access-Control-Allow-Methods': ALLOWED_METHODS,
        'Access-Control-Allow-Headers': ALLOWED_HEADERS,
        'Access-Control-Max-Age': PREFLIGHT_MAX_AGE_SECONDS,
      });
      return res.sendStatus(204);
    }
    return next();
  };
}

module.exports = { cors };
