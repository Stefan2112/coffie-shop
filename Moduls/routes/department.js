
    
const express = require('express');
const router = express.Router();
const { GetDepartments } = require('../dataAccessLayer/department-controller');


router.get('/getDepartments', GetDepartments);

module.exports = router;