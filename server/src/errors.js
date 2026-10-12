class ApiError extends Error {
  constructor(status, code, message) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

const validationError = (message) => new ApiError(400, 'validation_error', message);
const unauthorized = (message = 'A valid Bearer token is required') =>
  new ApiError(401, 'unauthorized', message);
const invalidCredentials = () =>
  new ApiError(401, 'invalid_credentials', 'Email or password is incorrect');
const conflict = (message) => new ApiError(409, 'conflict', message);
const notFound = (message) => new ApiError(404, 'not_found', message);

module.exports = { ApiError, validationError, unauthorized, invalidCredentials, conflict, notFound };
