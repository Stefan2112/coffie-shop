const GetShippingRegions = (request, response) => {
    try {
        let query = `SELECT 
                        A.shipping_region_id AS 'RegionId',
                        A.shipping_region AS 'Region'
                    FROM shipping_region A 
                    ORDER BY shipping_region_id ASC`; 

       
        db.query(query, (err, result) => {
           if (err != null) response.status(500).send({ error: error.message });

           return response.json(result);
       });
    } catch (error) {
        if (error != null) response.status(500).send({ error: error.message });
    }
};

const shipping = {
    GetShippingRegions
};

module.exports = shipping; 