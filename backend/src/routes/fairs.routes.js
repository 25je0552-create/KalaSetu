const express = require('express');
const router = express.Router();

// Real impl later: GET /api/fairs
router.get('/', (req, res) => {
  res.json({ message: 'Craft fairs endpoint scaffolded.' });
});

// Real impl later: POST /api/fairs/:id/apply
router.post('/:id/apply', (req, res) => {
  res.status(200).json({ message: 'Fair stall application submitted.' });
});

module.exports = router;
