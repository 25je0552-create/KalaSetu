const express = require('express');
const router = express.Router();

// Real impl later: GET /api/orders
router.get('/', (req, res) => {
  res.json({ message: 'Orders endpoint scaffolded.' });
});

// Real impl later: POST /api/orders
router.post('/', (req, res) => {
  res.status(201).json({ message: 'Order checkout endpoint scaffolded.' });
});

module.exports = router;
