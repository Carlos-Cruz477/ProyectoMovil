const { unauthorized } = require('../errors');

function authenticate({ tokens, users }) {
  return (req, _res, next) => {
    const header = req.get('authorization') || '';
    const match = /^Bearer\s+(\S+)$/i.exec(header);
    if (!match) return next(unauthorized());

    const userId = tokens.verify(match[1]);
    const user = userId && users.findById(userId);
    if (!user) return next(unauthorized());

    req.user = user;
    return next();
  };
}

module.exports = { authenticate };
