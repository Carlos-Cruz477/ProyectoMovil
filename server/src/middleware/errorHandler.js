const { ApiError, notFound } = require('../errors');

function notFoundHandler(req, _res, next) {
  next(notFound(`Route ${req.method} ${req.path} not found`));
}

function errorHandler(logger) {
  return (err, _req, res, _next) => {
    if (err instanceof ApiError) {
      return res.status(err.status).json({ error: err.code, message: err.message });
    }
    // Errors raised by express.json() (malformed JSON, payload too large, bad charset, ...)
    if (err.type === 'entity.parse.failed') {
      return res.status(400).json({ error: 'validation_error', message: 'Request body is not valid JSON' });
    }
    if (err.expose && err.status >= 400 && err.status < 500) {
      return res.status(err.status).json({ error: 'bad_request', message: err.message });
    }
    logger.error(err);
    return res.status(500).json({ error: 'internal_error', message: 'An unexpected error occurred' });
  };
}

module.exports = { notFoundHandler, errorHandler };
