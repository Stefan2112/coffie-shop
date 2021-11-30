
    
const express = require('express');
const router = express.Router();
const { GetCategories } = require('../dataAccessLayer/category-controller');


router.get('/getCategories', GetCategories);

module.exports = router;