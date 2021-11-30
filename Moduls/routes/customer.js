
    
const express = require('express');
const router = express.Router();
const {
    AuthenticateLogin,
    RegisterCustomer,
    Logout
} = require('../dataAccessLayer/customer-controller');


router.post('/addNewCustomer', RegisterCustomer);


router.post('/authenticateLogin', AuthenticateLogin);


router.get('/logout', Logout)

module.exports = router;