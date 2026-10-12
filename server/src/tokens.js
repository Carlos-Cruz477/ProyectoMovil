const jwt = require('jsonwebtoken');

const ALGORITHM = 'HS256';

function createTokenService({ secret, expiresIn }) {
  return {
    sign(userId) {
      return jwt.sign({}, secret, { algorithm: ALGORITHM, subject: userId, expiresIn });
    },

    verify(token) {
      try {
        const payload = jwt.verify(token, secret, { algorithms: [ALGORITHM] });
        return typeof payload.sub === 'string' ? payload.sub : null;
      } catch {
        return null;
      }
    },
  };
}

module.exports = { createTokenService };
