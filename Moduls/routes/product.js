
    
const express = require('express');
const router = express.Router();
const { 
    GetProducts,
    GetProductAttributes,
    GetFilteredProducts,
    GetProductDetailsById
 } = require('../dataAccessLayer/product-controller');


router.get('/getProducts', GetProducts);


router.get('/getProductAttributes', GetProductAttributes)

router.post('/getFilteredProducts', GetFilteredProducts);


router.get('/getProductDetails', GetProductDetailsById)


module.exports = router;