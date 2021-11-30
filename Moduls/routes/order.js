
const express = require('express');
const router = express.Router();
const { CreateOrder, SendTestMail } = require('../dataAccessLayer/order-controller');


router.post('/submitOrder', CreateOrder);
router.get('/sendTestMail', SendTestMail);

module.exports = router;