const express = require('express');
const router = express.Router();

// Real impl later: GET /api/products (list & search)
router.get('/', (req, res) => {
  res.json({ message: 'Products endpoint scaffolded. Ready for MongoDB implementation.' });
});

// Real impl later: GET /api/products/:id
router.get('/:id', (req, res) => {
  res.json({ id: req.params.id, message: 'Product detail endpoint scaffolded.' });
});

// Real impl later: POST /api/products
router.post('/', (req, res) => {
  res.status(201).json({ message: 'Product creation endpoint scaffolded.' });
});

module.exports = router;
