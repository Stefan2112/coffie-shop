
const GetProducts = (request, response) => {
    try {
        let query = `SELECT TOP 10
                            P.product_id AS 'ProductId',
                            P.name AS 'Name',
                            P.description AS 'Description',
                            P.price AS 'Price',
                            P.discounted_price AS 'DescountedPrice',
                            P.image AS 'PrimaryImage',
                            P.category_id AS 'CategoryId',
                            P.department_id AS 'DepartmentId'
                    FROM product P, category C, product_category PC
                    WHERE P.product_id = PC.product_id 
                        AND C.category_id = PC.category_id;`; 

        let productCountQuery = `SELECT COUNT(P.product_id) AS 'ProductCount'
                    FROM 
                        product P, 
                        category C, 
                        department D, 
                        product_category PC
                    WHERE P.product_id = PC.product_id 
                        AND C.category_id = PC.category_id
                        AND C.department_id = D.department_id
                    ${filterDepartment} ${filterCategory};`;

        
        db.query(query + productCountQuery, [1, 2], (err, result) => {
            if (err != null){
                response.status(500).send({ error: err.message });
            }

            let resultSet = {
                Products: result[0], 
                ProductCount: result[1]
            }
        
            let productIdList = [];
            resultSet.Products.forEach((element, index) => {
                 productIdList.push(element.ProductId);
            });

            let productlistString = productIdList.toString();

            let query = `SELECT 
                A.name AS 'AttributeName',
                A.attribute_id AS 'AttributeId',
                AV.attribute_value_id AS 'AttributeValueId',
                AV.value AS 'AttributeValue',
                PA.product_id AS 'ProductId'
            FROM attribute_value AV
            INNER JOIN attribute A
                    ON AV.attribute_id = A.attribute_id
            INNER JOIN product_attribute PA
                    ON PA.attribute_value_id = AV.attribute_value_id
            WHERE AV.attribute_value_id IN
                    (SELECT attribute_value_id
                    FROM   product_attribute
                    WHERE  product_id in (${productlistString}))
            ORDER BY A.name`;

            
            db.query(query, (err, result) => {
                if (err != null){
                    response.status(500).send({ error: err.message });
                }

                resultSet.Products.forEach((element,index) => {
                    var aaa = result.filter(a => a.ProductId == element.ProductId);
                    resultSet.Products[index]['Velicina'] = aaa.filter(a => a.AttributeId == 1);
                    resultSet.Products[index]['Boja'] = aaa.filter(a => a.AttributeId == 2);
                });
                return response.json(resultSet);
            });

           return response.json(result);
       });
    } catch (error) {
        if (error != null) response.status(500).send({ error: error.message });
    }
};

const GetProductAttributes = (request, response) => {
    try {
        let query = 'CALL catalog_get_attribute_values(1);CALL catalog_get_attribute_values(2)'
        
        db.query(query, [1, 2], (err, result) => {
            if (err != null){
                response.status(500).send({ error: err.message });
               }
            return response.json({Size: result[0], Color: result[1]});
        });
    } catch (error) {
        
    }
};

const GetFilteredProducts = (request, response) => {
    try {
        let filterDepartment = (request.body.paging.DepartmentId == 0) ? 'AND C.department_id = C.department_id' : `AND C.department_id = ${request.body.paging.DepartmentId}`;
        let filterCategory = (request.body.paging.CategoryId == 0) ? 'AND C.category_id = C.category_id' : `AND C.category_id = ${request.body.paging.CategoryId}`;
        let filterSearchString = ''; 
        request.body.paging.SearchString = (request.body.paging.SearchString == undefined) ? '': request.body.paging.SearchString;
        
        if(request.body.paging.SearchString == ''){
            filterSearchString = `P.name like '%%' OR P.description like '%%'`;
        } else if(request.body.paging.IsAllWords) {
            let words = request.body.paging.SearchString.split(' ');
            let likeQuery = [];
            words.forEach(element => {
                likeQuery.push(`P.name like '%${element}%' OR P.description like '%${element}%'`);
            });
            filterSearchString = likeQuery.join(' OR ');
        } else{
            filterSearchString = `P.name like '%${request.body.paging.SearchString}%' 
                                 OR P.description like '%${request.body.paging.SearchString}%'`;
        }
        let query = `SELECT 
                        P.product_id AS 'ProductId',
                        P.name AS 'Name',
                        P.description AS 'Description',
                        P.price AS 'Price',
                        P.discounted_price AS 'DescountedPrice',
                        P.image AS 'PrimaryImage',
                        C.category_id AS 'CategoryId',
                        C.department_id AS 'DepartmentId',
                        D.name AS 'DepartmentName',
                        C.name AS 'CategoryName'
                    FROM product P, category C, department D, product_category PC
                    WHERE P.product_id = PC.product_id 
                        AND C.category_id = PC.category_id
                        AND C.department_id = D.department_id
                        ${filterDepartment} ${filterCategory}
                        AND (${filterSearchString})
                    LIMIT ${request.body.paging.PageNumber}, ${request.body.paging.PageSize};`; 

        let productCountQuery = `SELECT COUNT(P.product_id) AS 'ProductCount'
                                FROM product P, category C, department D, product_category PC
                                WHERE P.product_id = PC.product_id 
                                    AND C.category_id = PC.category_id
                                    AND C.department_id = D.department_id
                                    ${filterDepartment} ${filterCategory}
                                    AND (${filterSearchString});`; 
        
        db.query(query + productCountQuery, [1, 2], (err, result) => {
           if (err != null){
            return response.status(500).send({ error: err.message });
           }
            let resultSet = {
               Products: result[0], 
               ProductCount: result[1]
            }
            if(resultSet.Products.length == 0){
                return response.json(resultSet);
            }
           
            let productIdList = [];
            resultSet.Products.forEach((element, index) => {
                productIdList.push(element.ProductId);
            });
            let productlistString = productIdList.toString();

            let query = `SELECT 
                A.name AS 'AttributeName',
                A.attribute_id AS 'AttributeId',
                AV.attribute_value_id AS 'AttributeValueId',
                AV.value AS 'AttributeValue',
                PA.product_id AS 'ProductId'
            FROM attribute_value AV
            INNER JOIN attribute A
                    ON AV.attribute_id = A.attribute_id
            INNER JOIN product_attribute PA
                    ON PA.attribute_value_id = AV.attribute_value_id
            WHERE AV.attribute_value_id IN
                    (SELECT attribute_value_id
                    FROM   product_attribute
                    WHERE  product_id in (${productlistString}))
            ORDER BY A.name`;

            
            db.query(query, (err, result) => {
                if (err != null){
                    response.status(500).send({ error: err.message });
                }

                resultSet.Products.forEach((element,index) => {
                    var aaa = result.filter(a => a.ProductId == element.ProductId);
                    resultSet.Products[index]['Velicina'] = aaa.filter(a => a.AttributeId == 1).sort(function(a, b){return a.AttributeValueId - b.AttributeValueId});
                    resultSet.Products[index]['Boja'] = aaa.filter(a => a.AttributeId == 2).sort(function(a, b){return a.AttributeValueId - b.AttributeValueId});
                });
                return response.json(resultSet);
            });

       });
    } catch (err) {
        if (err != null) {
            response.status(500).send({ error: err });
        }
    }
};

const GetProductDetailsById = (request, response) => {
    try {
        let query = `SELECT 
                        P.product_id AS 'ProductId',
                        P.name AS 'Name',
                        P.description AS 'Description',
                        P.price AS 'Price',
                        P.discounted_price AS 'DescountedPrice',
                        P.image AS 'PrimaryImage',
                        C.category_id AS 'CategoryId',
                        C.department_id AS 'DepartmentId',
                        D.name AS 'DepartmentName',
                        C.name AS 'CategoryName'
                    FROM 
                        product P, 
                        category C, 
                        department D, 
                        product_category PC
                    WHERE P.product_id = PC.product_id 
                    AND C.category_id = PC.category_id
                    AND C.department_id = D.department_id
                    AND P.product_id = ${request.query.productId}`; 

    
        db.query(query ,(err, result) => {
            if (err != null){
                response.status(500).send({ error: err.message });
            }
            let productDetails = result[0];
            let subquery = `SELECT 
                            A.name AS 'AttributeName',
                            A.attribute_id AS 'AttributeId',
                            AV.attribute_value_id AS 'AttributeValueId',
                            AV.value AS 'AttributeValue',
                            PA.product_id AS 'ProductId'
                        FROM attribute_value AV
                        INNER JOIN attribute A
                                ON AV.attribute_id = A.attribute_id
                        INNER JOIN product_attribute PA
                                ON PA.attribute_value_id = AV.attribute_value_id
                        WHERE PA.product_id = ${request.query.productId}
                        ORDER BY A.name`;

            
            db.query(subquery, (err, results) => {
                if (err != null){
                    response.status(500).send({ error: err.message });
                }

                productDetails['Velicina'] = results.filter(a => a.AttributeId == 1).sort(function(a, b){return a.AttributeValueId - b.AttributeValueId});
                productDetails['Boja'] = results.filter(a => a.AttributeId == 2).sort(function(a, b){return a.AttributeValueId - b.AttributeValueId});

                return response.json(productDetails);
            });

       });
    } catch (err) {
        if (err != null) {
            response.status(500).send({ error: err });
        }
    }
};

const product = {
    GetProducts,
    GetProductAttributes,
    GetFilteredProducts,
    GetProductDetailsById
};

module.exports = product;