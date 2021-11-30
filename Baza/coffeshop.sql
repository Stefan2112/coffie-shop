
CREATE DATABASE IF NOT EXISTS `coffeshop` ;
USE `coffeshop`;


CREATE TABLE IF NOT EXISTS `attribute` (
  `attribute_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`attribute_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `attribute`;
;
INSERT INTO `attribute` (`attribute_id`, `name`) VALUES
	(2, 'Boja'),
	(1, 'Velicina');
;


CREATE TABLE IF NOT EXISTS `attribute_value` (
  `attribute_value_id` int NOT NULL AUTO_INCREMENT,
  `attribute_id` int NOT NULL,
  `value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`attribute_value_id`),
  KEY `idx_attribute_value_attribute_id` (`attribute_id`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `attribute_value`;
;
INSERT INTO `attribute_value` (`attribute_value_id`, `attribute_id`, `value`) VALUES
	(4, 1, 'Crna'),
	(3, 1, 'Bela'),
	(2, 1, '200gr'),
	(1, 1, '100gr');
;


CREATE TABLE IF NOT EXISTS `audit` (
  `audit_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `created_on` datetime NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `code` int NOT NULL,
  PRIMARY KEY (`audit_id`),
  KEY `idx_audit_order_id` (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `audit`;



DELIMITER //
CREATE PROCEDURE `catalog_add_attribute`(IN inName VARCHAR(100))
BEGIN
  INSERT INTO attribute (name) VALUES (inName);
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_add_attribute_value`(
  IN inAttributeId INT, IN inValue VARCHAR(100))
BEGIN
  INSERT INTO attribute_value (attribute_id, value)
         VALUES (inAttributeId, inValue);
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_add_category`(IN inDepartmentId INT,
  IN inName VARCHAR(100), IN inDescription VARCHAR(1000))
BEGIN
  INSERT INTO category (department_id, name, description)
         VALUES (inDepartmentId, inName, inDescription);
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_add_department`(
  IN inName VARCHAR(100), IN inDescription VARCHAR(1000))
BEGIN
  INSERT INTO department (name, description)
         VALUES (inName, inDescription);
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_add_product_to_category`(IN inCategoryId INT,
  IN inName VARCHAR(100), IN inDescription VARCHAR(1000),
  IN inPrice DECIMAL(10, 2))
BEGIN
  DECLARE productLastInsertId INT;

  INSERT INTO product (name, description, price)
         VALUES (inName, inDescription, inPrice);

  SELECT LAST_INSERT_ID() INTO productLastInsertId;

  INSERT INTO product_category (product_id, category_id)
         VALUES (productLastInsertId, inCategoryId);
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_assign_attribute_value_to_product`(
  IN inProductId INT, IN inAttributeValueId INT)
BEGIN
  INSERT INTO product_attribute (product_id, attribute_value_id)
         VALUES (inProductId, inAttributeValueId);
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_assign_product_to_category`(
  IN inProductId INT, IN inCategoryId INT)
BEGIN
  INSERT INTO product_category (product_id, category_id)
         VALUES (inProductId, inCategoryId);
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_count_products_in_category`(IN inCategoryId INT)
BEGIN
  SELECT     COUNT(*) AS categories_count
  FROM       product p
  INNER JOIN product_category pc
               ON p.product_id = pc.product_id
  WHERE      pc.category_id = inCategoryId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `catalog_count_search_result`(
  IN inSearchString TEXT, IN inAllWords VARCHAR(3))
BEGIN
  IF inAllWords = "on" THEN
    PREPARE statement FROM
      "SELECT   count(*)
       FROM     product
       WHERE    MATCH (name, description) AGAINST (? IN BOOLEAN MODE)";
  ELSE
    PREPARE statement FROM
      "SELECT   count(*)
       FROM     product
       WHERE    MATCH (name, description) AGAINST (?)";
  END IF;

  SET @p1 = inSearchString;

  EXECUTE statement USING @p1;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_create_product_review`(IN inCustomerId INT,
  IN inProductId INT, IN inReview TEXT, IN inRating SMALLINT)
BEGIN
  INSERT INTO review (customer_id, product_id, review, rating, created_on)
         VALUES (inCustomerId, inProductId, inReview, inRating, NOW());
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_delete_attribute`(IN inAttributeId INT)
BEGIN
  DECLARE attributeRowsCount INT;

  SELECT count(*)
  FROM   attribute_value
  WHERE  attribute_id = inAttributeId
  INTO   attributeRowsCount;

  IF attributeRowsCount = 0 THEN
    DELETE FROM attribute WHERE attribute_id = inAttributeId;

    SELECT 1;
  ELSE
    SELECT -1;
  END IF;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_delete_attribute_value`(IN inAttributeValueId INT)
BEGIN
  DECLARE productAttributeRowsCount INT;

  SELECT      count(*)
  FROM        product p
  INNER JOIN  product_attribute pa
                ON p.product_id = pa.product_id
  WHERE       pa.attribute_value_id = inAttributeValueId
  INTO        productAttributeRowsCount;

  IF productAttributeRowsCount = 0 THEN
    DELETE FROM attribute_value WHERE attribute_value_id = inAttributeValueId;

    SELECT 1;
  ELSE
    SELECT -1;
  END IF;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_delete_category`(IN inCategoryId INT)
BEGIN
  DECLARE productCategoryRowsCount INT;

  SELECT      count(*)
  FROM        product p
  INNER JOIN  product_category pc
                ON p.product_id = pc.product_id
  WHERE       pc.category_id = inCategoryId
  INTO        productCategoryRowsCount;

  IF productCategoryRowsCount = 0 THEN
    DELETE FROM category WHERE category_id = inCategoryId;

    SELECT 1;
  ELSE
    SELECT -1;
  END IF;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_delete_department`(IN inDepartmentId INT)
BEGIN
  DECLARE categoryRowsCount INT;

  SELECT count(*)
  FROM   category
  WHERE  department_id = inDepartmentId
  INTO   categoryRowsCount;
  
  IF categoryRowsCount = 0 THEN
    DELETE FROM department WHERE department_id = inDepartmentId;

    SELECT 1;
  ELSE
    SELECT -1;
  END IF;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_delete_product`(IN inProductId INT)
BEGIN
  DELETE FROM product_attribute WHERE product_id = inProductId;
  DELETE FROM product_category WHERE product_id = inProductId;
  DELETE FROM shopping_cart WHERE product_id = inProductId;
  DELETE FROM product WHERE product_id = inProductId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_attributes`()
BEGIN
  SELECT attribute_id, name FROM attribute ORDER BY attribute_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_attributes_not_assigned_to_product`(
  IN inProductId INT)
BEGIN
  SELECT     a.name AS attribute_name,
             av.attribute_value_id, av.value AS attribute_value
  FROM       attribute_value av
  INNER JOIN attribute a
               ON av.attribute_id = a.attribute_id
  WHERE      av.attribute_value_id NOT IN
             (SELECT attribute_value_id
              FROM   product_attribute
              WHERE  product_id = inProductId)
  ORDER BY   attribute_name, av.attribute_value_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_attribute_details`(IN inAttributeId INT)
BEGIN
  SELECT attribute_id, name
  FROM   attribute
  WHERE  attribute_id = inAttributeId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_attribute_values`(IN inAttributeId INT)
BEGIN
  SELECT   attribute_value_id, value
  FROM     attribute_value
  WHERE    attribute_id = inAttributeId
  ORDER BY attribute_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_categories`()
BEGIN
  SELECT   category_id, name, description
  FROM     category
  ORDER BY category_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_categories_for_product`(IN inProductId INT)
BEGIN
  SELECT   c.category_id, c.department_id, c.name
  FROM     category c
  JOIN     product_category pc
             ON c.category_id = pc.category_id
  WHERE    pc.product_id = inProductId
  ORDER BY category_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_categories_list`(IN inDepartmentId INT)
BEGIN
  SELECT   category_id, name
  FROM     category
  WHERE    department_id = inDepartmentId
  ORDER BY category_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_category_details`(IN inCategoryId INT)
BEGIN
  SELECT name, description
  FROM   category
  WHERE  category_id = inCategoryId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_category_name`(IN inCategoryId INT)
BEGIN
  SELECT name FROM category WHERE category_id = inCategoryId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_category_products`(IN inCategoryId INT)
BEGIN
  SELECT     p.product_id, p.name, p.description, p.price,
             p.discounted_price
  FROM       product p
  INNER JOIN product_category pc
               ON p.product_id = pc.product_id
  WHERE      pc.category_id = inCategoryId
  ORDER BY   p.product_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_departments`()
BEGIN
  SELECT   department_id, name, description
  FROM     department
  ORDER BY department_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_departments_list`()
BEGIN
  SELECT department_id, name FROM department ORDER BY department_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_department_categories`(IN inDepartmentId INT)
BEGIN
  SELECT   category_id, name, description
  FROM     category
  WHERE    department_id = inDepartmentId
  ORDER BY category_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_department_details`(IN inDepartmentId INT)
BEGIN
  SELECT name, description
  FROM   department
  WHERE  department_id = inDepartmentId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_department_name`(IN inDepartmentId INT)
BEGIN
  SELECT name FROM department WHERE department_id = inDepartmentId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_products_in_category`(
  IN inCategoryId INT, IN inShortProductDescriptionLength INT,
  IN inProductsPerPage INT, IN inStartItem INT)
BEGIN
  
  PREPARE statement FROM
   "SELECT     p.product_id, p.name,
               IF(LENGTH(p.description) <= ?,
                  p.description,
                  CONCAT(LEFT(p.description, ?),
                         '...')) AS description,
               p.price, p.discounted_price, 
    FROM       product p
    INNER JOIN product_category pc
                 ON p.product_id = pc.product_id
    WHERE      pc.category_id = ?
    LIMIT      ?, ?";

  
  SET @p1 = inShortProductDescriptionLength; 
  SET @p2 = inShortProductDescriptionLength; 
  SET @p3 = inCategoryId;
  SET @p4 = inStartItem; 
  SET @p5 = inProductsPerPage; 

  
  EXECUTE statement USING @p1, @p2, @p3, @p4, @p5;
END//
DELIMITER ;




DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_product_attributes`(IN inProductId INT)
BEGIN
  SELECT     a.name AS attribute_name,
             av.attribute_value_id, av.value AS attribute_value
  FROM       attribute_value av
  INNER JOIN attribute a
               ON av.attribute_id = a.attribute_id
  WHERE      av.attribute_value_id IN
               (SELECT attribute_value_id
                FROM   product_attribute
                WHERE  product_id = inProductId)
  ORDER BY   a.name;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_product_details`(IN inProductId INT)
BEGIN
  SELECT product_id, name, description,
         price, discounted_price, image
  FROM   product
  WHERE  product_id = inProductId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_product_info`(IN inProductId INT)
BEGIN
  SELECT product_id, name, description, price, discounted_price,
         image
  FROM   product
  WHERE  product_id = inProductId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_product_locations`(IN inProductId INT)
BEGIN
  SELECT c.category_id, c.name AS category_name, c.department_id,
         (SELECT name
          FROM   department
          WHERE  department_id = c.department_id) AS department_name
          
  FROM   category c
  WHERE  c.category_id IN
           (SELECT category_id
            FROM   product_category
            WHERE  product_id = inProductId);
            
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_product_name`(IN inProductId INT)
BEGIN
  SELECT name FROM product WHERE product_id = inProductId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_product_reviews`(IN inProductId INT)
BEGIN
  SELECT     c.name, r.review, r.rating, r.created_on
  FROM       review r
  INNER JOIN customer c
               ON c.customer_id = r.customer_id
  WHERE      r.product_id = inProductId
  ORDER BY   r.created_on DESC;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_get_recommendations`(
  IN inProductId INT, IN inShortProductDescriptionLength INT)
BEGIN
  PREPARE statement FROM
    "SELECT   od2.product_id, od2.product_name,
              IF(LENGTH(p.description) <= ?, p.description,
                 CONCAT(LEFT(p.description, ?), '...')) AS description
     FROM     order_detail od1
     JOIN     order_detail od2 ON od1.order_id = od2.order_id
     JOIN     product p ON od2.product_id = p.product_id
     WHERE    od1.product_id = ? AND
              od2.product_id != ?
     GROUP BY od2.product_id
     ORDER BY COUNT(od2.product_id) DESC
     LIMIT 5";

  SET @p1 = inShortProductDescriptionLength;
  SET @p2 = inProductId;

  EXECUTE statement USING @p1, @p1, @p2, @p2;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_move_product_to_category`(IN inProductId INT,
  IN inSourceCategoryId INT, IN inTargetCategoryId INT)
BEGIN
  UPDATE product_category
  SET    category_id = inTargetCategoryId
  WHERE  product_id = inProductId
         AND category_id = inSourceCategoryId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_remove_product_attribute_value`(
  IN inProductId INT, IN inAttributeValueId INT)
BEGIN
  DELETE FROM product_attribute
  WHERE       product_id = inProductId AND
              attribute_value_id = inAttributeValueId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_remove_product_from_category`(
  IN inProductId INT, IN inCategoryId INT)
BEGIN
  DECLARE productCategoryRowsCount INT;

  SELECT count(*)
  FROM   product_category
  WHERE  product_id = inProductId
  INTO   productCategoryRowsCount;

  IF productCategoryRowsCount = 1 THEN
    CALL catalog_delete_product(inProductId);

    SELECT 0;
  ELSE
    DELETE FROM product_category
    WHERE  category_id = inCategoryId AND product_id = inProductId;

    SELECT 1;
  END IF;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_search`(
  IN inSearchString TEXT, IN inAllWords VARCHAR(3),
  IN inShortProductDescriptionLength INT,
  IN inProductsPerPage INT, IN inStartItem INT)
BEGIN
  IF inAllWords = "on" THEN
    PREPARE statement FROM
      "SELECT   product_id, name,
                IF(LENGTH(description) <= ?,
                   description,
                   CONCAT(LEFT(description, ?),
                          '...')) AS description,
                price, discounted_price
       FROM     product
       WHERE    MATCH (name, description)
                AGAINST (? IN BOOLEAN MODE)
       ORDER BY MATCH (name, description)
                AGAINST (? IN BOOLEAN MODE) DESC
       LIMIT    ?, ?";
  ELSE
    PREPARE statement FROM
      "SELECT   product_id, name,
                IF(LENGTH(description) <= ?,
                   description,
                   CONCAT(LEFT(description, ?),
                          '...')) AS description,
                price, discounted_price
       FROM     product
       WHERE    MATCH (name, description) AGAINST (?)
       ORDER BY MATCH (name, description) AGAINST (?) DESC
       LIMIT    ?, ?";
  END IF;

  SET @p1 = inShortProductDescriptionLength;
  SET @p2 = inSearchString;
  SET @p3 = inStartItem;
  SET @p4 = inProductsPerPage;

  EXECUTE statement USING @p1, @p1, @p2, @p2, @p3, @p4;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_set_image`(
  IN inProductId INT, IN inImage VARCHAR(150))
BEGIN
  UPDATE product SET image = inImage WHERE product_id = inProductId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `catalog_update_attribute`(
  IN inAttributeId INT, IN inName VARCHAR(100))
BEGIN
  UPDATE attribute SET name = inName WHERE attribute_id = inAttributeId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `catalog_update_attribute_value`(
  IN inAttributeValueId INT, IN inValue VARCHAR(100))
BEGIN
    UPDATE attribute_value
    SET    value = inValue
    WHERE  attribute_value_id = inAttributeValueId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_update_category`(IN inCategoryId INT,
  IN inName VARCHAR(100), IN inDescription VARCHAR(1000))
BEGIN
    UPDATE category
    SET    name = inName, description = inDescription
    WHERE  category_id = inCategoryId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_update_department`(IN inDepartmentId INT,
  IN inName VARCHAR(100), IN inDescription VARCHAR(1000))
BEGIN
  UPDATE department
  SET    name = inName, description = inDescription
  WHERE  department_id = inDepartmentId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `catalog_update_product`(IN inProductId INT,
  IN inName VARCHAR(100), IN inDescription VARCHAR(1000),
  IN inPrice DECIMAL(10, 2), IN inDiscountedPrice DECIMAL(10, 2))
BEGIN
  UPDATE product
  SET    name = inName, description = inDescription, price = inPrice,
         discounted_price = inDiscountedPrice
  WHERE  product_id = inProductId;
END//
DELIMITER ;


CREATE TABLE IF NOT EXISTS `category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `department_id` int NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  KEY `idx_category_department_id` (`department_id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `category`;

INSERT INTO `category` (`category_id`, `department_id`, `name`, `description`) VALUES
	(1, 1, 'Cappuccino', 'Cappuccino je Italijanska kafa koja se pravi od espresa, toplog mleka i mlecne pene.Nazvan je po boji habita sto ih nose kapucineri.'),
	(2, 1, 'Caffe Latte', 'Caffe Latte je vrsta kafenog napitka sa toplim mlekom.Postoji i ledena Caffe Latte.Latte je popularan u mnogim zemljama mada ne u svojoj izvornoj, italijanskoj, varijanti.'),
	(3, 1, 'Latte Art', 'Latte Art je nacin pripreme espresso kafe sa mlekom  - kaffe late pri kom se nakon sipanja kafe u soljicu na povrsini kafe prave slike od mleka.'),
	(4, 2, 'Makijato', 'Makijato jeste kafa pripremljena na Italijanski nacin, u stvari makijato je kafa espreso sa malo mleka'),
	(5, 2, 'Nes Caffa', 'Nes Caffa je brend instant kafe Svajcarskog proizvodjaca Nestle.Ime proizvoda nastalo je spajanjem naziva kompanije Nestle i reci kafa.Nes Caffa se prvi put pojavila  1.aprila  1938.'),
	(6, 3, 'Turska kafa', 'Turska kafa jeste metod pripreme nefiltrirane kafe.Przena a zatim fino mlevena, zrna kafe se kuvaju u dzezvi, cesto sa secerom te se serviraju u fildzanima.');



CREATE TABLE IF NOT EXISTS `customer` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `credit_card` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `address_1` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `address_2` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `postal_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `shipping_region_id` int NOT NULL DEFAULT '1',
  `mob_phone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `idx_customer_email` (`email`),
  KEY `idx_customer_shipping_region_id` (`shipping_region_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `customer`;



DELIMITER //
CREATE PROCEDURE `customer_add`(IN inName VARCHAR(50),
  IN inEmail VARCHAR(100), IN inPassword VARCHAR(50))
BEGIN
  INSERT INTO customer (name, email, password)
         VALUES (inName, inEmail, inPassword);

  SELECT LAST_INSERT_ID();
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `customer_get_customer`(IN inCustomerId INT)
BEGIN
  SELECT customer_id, name, email, password, credit_card,
         address_1, address_2, city, region, postal_code, country,
         shipping_region_id, mob_phone
  FROM   customer
  WHERE  customer_id = inCustomerId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `customer_get_customers_list`()
BEGIN
  SELECT customer_id, name FROM customer ORDER BY name ASC;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `customer_get_login_info`(IN inEmail VARCHAR(100))
BEGIN
  SELECT customer_id, password FROM customer WHERE email = inEmail;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `customer_get_shipping_regions`()
BEGIN
  SELECT shipping_region_id, shipping_region FROM shipping_region;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `customer_update_account`(IN inCustomerId INT,
  IN inName VARCHAR(50), IN inEmail VARCHAR(100),
  IN inPassword VARCHAR(50), IN inMobPhone VARCHAR(100),
  
BEGIN
  UPDATE customer
  SET    name = inName, email = inEmail,
  WHERE  customer_id = inCustomerId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `customer_update_address`(IN inCustomerId INT,
  IN inAddress1 VARCHAR(100), IN inAddress2 VARCHAR(100),
  IN inCity VARCHAR(100), IN inRegion VARCHAR(100),
  IN inPostalCode VARCHAR(100), IN inCountry VARCHAR(100),
  IN inShippingRegionId INT)
BEGIN
  UPDATE customer
  SET    address_1 = inAddress1, address_2 = inAddress2, city = inCity,
         region = inRegion, postal_code = inPostalCode,
         country = inCountry, shipping_region_id = inShippingRegionId
  WHERE  customer_id = inCustomerId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `customer_update_credit_card`(
  IN inCustomerId INT, IN inCreditCard TEXT)
BEGIN
  UPDATE customer
  SET    credit_card = inCreditCard
  WHERE  customer_id = inCustomerId;
END//
DELIMITER ;

CREATE TABLE IF NOT EXISTS `department` (
  `department_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`department_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `department`;

INSERT INTO `department` (`department_id`, `name`, `description`) VALUES
	(1, 'Brazil', 'Brazil je najveći svetski proizvojač sa najvećim brojem proizvođača i plantaža. Proizvedena zrna kafe u Brazilu su slabijeg kvaliteta ali su velike količine u pitanju. Ima čuvena izreka da u svakom espresu u svetu koji pijete postoji mali deo Brazilske kafe. Najbolje vreme za posetu Brazilu za ljubitelje kafe je period od jula do septembra jer je tada žetva kafe.'),
	(2, 'Kolumbija', 'Kolumbija i čuveni Andi, planinske regije oko Bogote, mesto gde možete da pijete kafu sa "izvora". Kolumbijska kafa je jedna od najpoznatijih u svetu. Probajte Supremo ili Excelso.'),
	(3, 'Havaji', 'Havaji su nadaleko poznati po Kona kafi, koja dolazi iz bogate zemlje ostrva. Kafa je neverovatno skupa i obično je mešaju sa kafama iz drugih zemalja.');
/


CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_on` datetime NOT NULL,
  `shipped_on` datetime DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `comments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `auth_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `reference` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `shipping_id` int DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `idx_orders_customer_id` (`customer_id`),
  KEY `idx_orders_shipping_id` (`shipping_id`),
  
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `orders`;

DELIMITER //
CREATE PROCEDURE `orders_create_audit`(IN inOrderId INT,
  IN inMessage TEXT, IN inCode INT)
BEGIN
  INSERT INTO audit (order_id, created_on, message, code)
         VALUES (inOrderId, NOW(), inMessage, inCode);
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `orders_get_audit_trail`(IN inOrderId INT)
BEGIN
  SELECT audit_id, order_id, created_on, message, code
  FROM   audit
  WHERE  order_id = inOrderId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `orders_get_by_customer_id`(IN inCustomerId INT)
BEGIN
  SELECT     o.order_id, o.total_amount, o.created_on,
             o.shipped_on, o.status, c.name
  FROM       orders o
  INNER JOIN customer c
               ON o.customer_id = c.customer_id
  WHERE      o.customer_id = inCustomerId
  ORDER BY   o.created_on DESC;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `orders_get_most_recent_orders`(IN inHowMany INT)
BEGIN
  PREPARE statement FROM
    "SELECT     o.order_id, o.total_amount, o.created_on,
                o.shipped_on, o.status, c.name
     FROM       orders o
     INNER JOIN customer c
                  ON o.customer_id = c.customer_id
     ORDER BY   o.created_on DESC
     LIMIT      ?";

  SET @p1 = inHowMany;

  EXECUTE statement USING @p1;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `orders_get_orders_between_dates`(
  IN inStartDate DATETIME, IN inEndDate DATETIME)
BEGIN
  SELECT     o.order_id, o.total_amount, o.created_on,
             o.shipped_on, o.status, c.name
  FROM       orders o
  INNER JOIN customer c
               ON o.customer_id = c.customer_id
  WHERE      o.created_on >= inStartDate AND o.created_on <= inEndDate
  ORDER BY   o.created_on DESC;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `orders_get_orders_by_status`(IN inStatus INT)
BEGIN
  SELECT     o.order_id, o.total_amount, o.created_on,
             o.shipped_on, o.status, c.name
  FROM       orders o
  INNER JOIN customer c
               ON o.customer_id = c.customer_id
  WHERE      o.status = inStatus
  ORDER BY   o.created_on DESC;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `orders_get_order_details`(IN inOrderId INT)
BEGIN
  SELECT order_id, product_id, attributes, product_name,
         quantity, unit_cost, (quantity * unit_cost) AS subtotal
  FROM   order_detail
  WHERE  order_id = inOrderId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `orders_get_order_short_details`(IN inOrderId INT)
BEGIN
  SELECT      o.order_id, o.total_amount, o.created_on,
              o.shipped_on, o.status, c.name
  FROM        orders o
  INNER JOIN  customer c
                ON o.customer_id = c.customer_id
  WHERE       o.order_id = inOrderId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `orders_get_shipping_info`(IN inShippingRegionId INT)
BEGIN
  SELECT shipping_id, shipping_type, shipping_cost, shipping_region_id
  FROM   shipping
  WHERE  shipping_region_id = inShippingRegionId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `orders_set_auth_code`(IN inOrderId INT,
  IN inAuthCode VARCHAR(50), IN inReference VARCHAR(50))
BEGIN
  UPDATE orders
  SET    auth_code = inAuthCode, reference = inReference
  WHERE  order_id = inOrderId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `orders_set_date_shipped`(IN inOrderId INT)
BEGIN
  UPDATE orders SET shipped_on = NOW() WHERE order_id = inOrderId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `orders_update_order`(IN inOrderId INT, IN inStatus INT,
  IN inComments VARCHAR(255), IN inAuthCode VARCHAR(50),
  IN inReference VARCHAR(50))
BEGIN
  DECLARE currentDateShipped DATETIME;

  SELECT shipped_on
  FROM   orders
  WHERE  order_id = inOrderId
  INTO   currentDateShipped;

  UPDATE orders
  SET    status = inStatus, comments = inComments,
         auth_code = inAuthCode, reference = inReference
  WHERE  order_id = inOrderId;

  IF inStatus < 7 AND currentDateShipped IS NOT NULL THEN
    UPDATE orders SET shipped_on = NULL WHERE order_id = inOrderId;
  ELSEIF inStatus > 6 AND currentDateShipped IS NULL THEN
    UPDATE orders SET shipped_on = NOW() WHERE order_id = inOrderId;
  END IF;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `orders_update_status`(IN inOrderId INT, IN inStatus INT)
BEGIN
  UPDATE orders SET status = inStatus WHERE order_id = inOrderId;
END//
DELIMITER ;

CREATE TABLE IF NOT EXISTS `order_detail` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `attributes` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `product_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `quantity` int NOT NULL,
  `unit_cost` decimal(10,2) NOT NULL,
  PRIMARY KEY (`item_id`),
  KEY `idx_order_detail_order_id` (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `order_detail`;

CREATE TABLE IF NOT EXISTS `product` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `discounted_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `image` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  FULLTEXT KEY `idx_ft_product_name_description` (`name`,`description`)
) ENGINE=MyISAM AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELETE FROM `product`;
INSERT INTO `product` (`product_id`, `name`, `description`, `price`, `discounted_price`, `image`) VALUES
	(1, 'Arabika', 'Kruševačka kompanija Arabika, koja je do 2004. poslovala pod imenom Oaza, na tržištu je prisutna sa prženom i mlevenom kafom Extra Arabica, u pakovanju od 100g i 200g.', 5.50, 2.50, 'arabica1'),
	(2, 'Grand Prom', 'Grand kafa je na tržištu Srbije zastupljena sa brendovima Grand Gold, Grand Aroma i Grand De Luxe. Raspolaže najsavremenijim sistemom za pakovanje u zaštićenoj atmosferi, čime se omogućava čuvanje najvažnijih svojstava kafe i održava njen visoki kvalitet tokom dužeg vremena. “Grand Gold je prva kafa u Grand portfoliu. Karakteriše je tradicionalni način mlevenja na kamenim mlinovima, koji, osim odlične recepture, ovoj kafi daju posebnu punoću ukusa, bogatu penu i konstantno visok kvalitet. Grand Aroma je namenjena onim ljubiteljima kafe koji traže visok kvalitet, izbalansiran ukus i savremeno, privlačno pakovanje.', 5.00, 3.50, 'Grand1'),
	(3, 'Moravka Pro', 'Moravka pro je zastupljena na tržištu Srbije sa sopstvenim brendovima Cafe Kafica Classic u gramaturama 100g, 200g, 500g i 1.000g, te Cafe Kafica Aroma u gramaturama 100g i 200g. Cafe Kafica je za ljubitelje tradiconalne, ‘turske’ kafe, a Aromu karakteriše mekši i pitkiji, ‘srednjeevropski’ ukus.', 4.20, 2.50, 'Moravka1'),
	(4, 'Straus Adriatic', 'Portfolio Strauss Adriatica čine dva brenda sa dugom tradicijom na tržištu Srbije – Doncafé i C kafa. Doncafé mainstream brend u segmentu tradicionalne kafe nudi tri proizvoda – Doncafé Moment, Strong i Minas. Doncafé Moment je kafa punog ukusa i najprepoznatljiviji proizvod u portfoliju, dostupan u pakovanjima od 100g, 200g soft i vakuum i 500g. Doncafé Strong je proizvod jačeg ukusa, dostupan u pakovanjima od 100g i 200g.', 2.00, 0.00, 'Straus1');

CREATE TABLE IF NOT EXISTS `product_attribute` (
  `product_id` int NOT NULL,
  `attribute_value_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`attribute_value_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `product_attribute`;

INSERT INTO `product_attribute` (`product_id`, `attribute_value_id`) VALUES
	(1, 1),
	(1, 2),
	(1, 3),
	(1, 4);
CREATE TABLE IF NOT EXISTS `product_category` (
  `product_id` int NOT NULL,
  `category_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `product_category`;

INSERT INTO `product_category` (`product_id`, `category_id`) VALUES
	(1, 1),
	(2, 1),
	(3, 1),
	(4, 1);


CREATE TABLE IF NOT EXISTS `review` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `product_id` int NOT NULL,
  `review` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `rating` smallint NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY (`review_id`),
  KEY `idx_review_customer_id` (`customer_id`),
  KEY `idx_review_product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `review`;

CREATE TABLE IF NOT EXISTS `shipping` (
  `shipping_id` int NOT NULL AUTO_INCREMENT,
  `shipping_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `shipping_cost` decimal(10,2) NOT NULL,
  `shipping_region_id` int NOT NULL,
  PRIMARY KEY (`shipping_id`),
  KEY `idx_shipping_shipping_region_id` (`shipping_region_id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `shipping`;

INSERT INTO `shipping` (`shipping_id`, `shipping_type`, `shipping_cost`, `shipping_region_id`) VALUES
	(1, 'U toku dana', 15.00, 2),
	(2, '2-3 Dana', 10.00, 2),
	(3, '5-7 Dana', 12.00, 2),
	(4, 'Zeleznicki transport', 30.00, 3),
	(5, 'Vazdusni transport', 50.00, 3);

CREATE TABLE IF NOT EXISTS `shipping_region` (
  `shipping_region_id` int NOT NULL AUTO_INCREMENT,
  `shipping_region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`shipping_region_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `shipping_region`;

INSERT INTO `shipping_region` (`shipping_region_id`, `shipping_region`) VALUES
	(1, 'Please Select'),
	(2, 'Evropa'),
	(3, 'Amerika'),
	(4, 'Australija');

CREATE TABLE IF NOT EXISTS `shopping_cart` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `cart_id` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `product_id` int NOT NULL,
  `attributes` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `quantity` int NOT NULL,
  `buy_now` tinyint(1) NOT NULL DEFAULT '1',
  `added_on` datetime NOT NULL,
  PRIMARY KEY (`item_id`),
  KEY `idx_shopping_cart_cart_id` (`cart_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DELETE FROM `shopping_cart`;

DELIMITER //
CREATE PROCEDURE `shopping_cart_add_product`(IN inCartId CHAR(32),
  IN inProductId INT, IN inAttributes VARCHAR(1000))
BEGIN
  DECLARE productQuantity INT;

  SELECT quantity
  FROM   shopping_cart
  WHERE  cart_id = inCartId
         AND product_id = inProductId
         AND attributes = inAttributes
  INTO   productQuantity;

  IF productQuantity IS NULL THEN
    INSERT INTO shopping_cart(item_id, cart_id, product_id, attributes,
                              quantity, added_on)
           VALUES (UUID(), inCartId, inProductId, inAttributes, 1, NOW());
  ELSE
    UPDATE shopping_cart
    SET    quantity = quantity + 1, buy_now = true
    WHERE  cart_id = inCartId
           AND product_id = inProductId
           AND attributes = inAttributes;
  END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_count_old_carts`(IN inDays INT)
BEGIN
  SELECT COUNT(cart_id) AS old_shopping_carts_count
  FROM   (SELECT   cart_id
          FROM     shopping_cart
          GROUP BY cart_id
          HAVING   DATE_SUB(NOW(), INTERVAL inDays DAY) >= MAX(added_on))
         AS old_carts;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_create_order`(IN inCartId CHAR(32),
  IN inCustomerId INT, IN inShippingId INT )
BEGIN
  DECLARE orderId INT;

  INSERT INTO orders (created_on, customer_id, shipping_id ) VALUES
         (NOW(), inCustomerId, inShippingId );
 
  SELECT LAST_INSERT_ID() INTO orderId;


  INSERT INTO order_detail (order_id, product_id, attributes,
                            product_name, quantity, unit_cost)
  SELECT      orderId, p.product_id, sc.attributes, p.name, sc.quantity,
              COALESCE(NULLIF(p.discounted_price, 0), p.price) AS unit_cost
  FROM        shopping_cart sc
  INNER JOIN  product p
                ON sc.product_id = p.product_id
  WHERE       sc.cart_id = inCartId AND sc.buy_now;

 
  UPDATE orders
  SET    total_amount = (SELECT SUM(unit_cost * quantity) 
                         FROM   order_detail
                         WHERE  order_id = orderId)
  WHERE  order_id = orderId;


  CALL shopping_cart_empty(inCartId);

  
  SELECT orderId;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE `shopping_cart_delete_old_carts`(IN inDays INT)
BEGIN
  DELETE FROM shopping_cart
  WHERE  cart_id IN
          (SELECT cart_id
           FROM   (SELECT   cart_id
                   FROM     shopping_cart
                   GROUP BY cart_id
                   HAVING   DATE_SUB(NOW(), INTERVAL inDays DAY) >=
                            MAX(added_on))
                  AS sc);
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_empty`(IN inCartId CHAR(32))
BEGIN
  DELETE FROM shopping_cart WHERE cart_id = inCartId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_get_products`(IN inCartId CHAR(32))
BEGIN
  SELECT     sc.item_id, p.name, sc.attributes,
             COALESCE(NULLIF(p.discounted_price, 0), p.price) AS price,
             sc.quantity,
             COALESCE(NULLIF(p.discounted_price, 0),
                      p.price) * sc.quantity AS subtotal
  FROM       shopping_cart sc
  INNER JOIN product p
               ON sc.product_id = p.product_id
  WHERE      sc.cart_id = inCartId AND sc.buy_now;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_get_recommendations`(
  IN inCartId CHAR(32), IN inShortProductDescriptionLength INT)
BEGIN
  PREPARE statement FROM
    "-- Returns the products that exist in a list of orders
     SELECT   od1.product_id, od1.product_name,
              IF(LENGTH(p.description) <= ?, p.description,
                 CONCAT(LEFT(p.description, ?), '...')) AS description
     FROM     order_detail od1
     JOIN     order_detail od2
                ON od1.order_id = od2.order_id
     JOIN     product p
                ON od1.product_id = p.product_id
     JOIN     shopping_cart
                ON od2.product_id = shopping_cart.product_id
     WHERE    shopping_cart.cart_id = ?
              AND od1.product_id NOT IN
              (-- Returns the products in the specified
               -- shopping cart
               SELECT product_id
               FROM   shopping_cart
               WHERE  cart_id = ?)
			GROUP BY od1.product_id
			ORDER BY COUNT(od1.product_id) DESC
			LIMIT    5";

  SET @p1 = inShortProductDescriptionLength;
  SET @p2 = inCartId;

  EXECUTE statement USING @p1, @p1, @p2, @p2;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_get_saved_products`(IN inCartId CHAR(32))
BEGIN
  SELECT     sc.item_id, p.name, sc.attributes,
             COALESCE(NULLIF(p.discounted_price, 0), p.price) AS price
  FROM       shopping_cart sc
  INNER JOIN product p
               ON sc.product_id = p.product_id
  WHERE      sc.cart_id = inCartId AND NOT sc.buy_now;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_get_total_amount`(IN inCartId CHAR(32))
BEGIN
  SELECT     SUM(COALESCE(NULLIF(p.discounted_price, 0), p.price)
                 * sc.quantity) AS total_amount
  FROM       shopping_cart sc
  INNER JOIN product p
               ON sc.product_id = p.product_id
  WHERE      sc.cart_id = inCartId AND sc.buy_now;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_move_product_to_cart`(IN inItemId INT)
BEGIN
  UPDATE shopping_cart
  SET    buy_now = true, added_on = NOW()
  WHERE  item_id = inItemId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_remove_product`(IN inItemId INT)
BEGIN
  DELETE FROM shopping_cart WHERE item_id = inItemId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_save_product_for_later`(IN inItemId INT)
BEGIN
  UPDATE shopping_cart
  SET    buy_now = false, quantity = 1
  WHERE  item_id = inItemId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `shopping_cart_update`(IN inItemId INT, IN inQuantity INT)
BEGIN
  IF inQuantity > 0 THEN
    UPDATE shopping_cart
    SET    quantity = inQuantity, added_on = NOW()
    WHERE  item_id = inItemId;
  ELSE
    CALL shopping_cart_remove_product(inItemId);
  END IF;
END//
DELIMITER ;

