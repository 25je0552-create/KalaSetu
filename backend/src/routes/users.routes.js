const express = require('express');
const router = express.Router();

// Real impl later: GET /api/users/me
router.get('/me', (req, res) => {
  res.json({ message: 'User profile endpoint scaffolded.' });
});

module.exports = router;
