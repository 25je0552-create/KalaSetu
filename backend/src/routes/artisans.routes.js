const express = require('express');
const router = express.Router();

// Real impl later: GET /api/artisans/:id
router.get('/:id', (req, res) => {
  res.json({ id: req.params.id, message: 'Artisan profile endpoint scaffolded.' });
});

module.exports = router;
