const  firebase = require("firebase/app");
const auth = require("firebase/auth");

var firebaseConfig = {
    apiKey: "///",
    authDomain: "///",
    databaseURL: "///",
    projectId: "///",
    storageBucket: "",
    messagingSenderId: "///",
    appId: "///"
  };

firebase.initializeApp(firebaseConfig);

const RegisterCustomer = (request, response) => {
    try {

        let params = request.body;

        firebase.auth()
                .createUserWithEmailAndPassword(params.Email, params.Password)
                .then(function(res){
                    let query = `INSERT INTO customer
                    (address_1, address_2, city, country, credit_card, email, mob_phone, name, password, postal_code, region, shipping_region_id)
                    values
                    (
                        '${params.AddressOne}', 
                        '${params.AddressTwo}', 
                        '${params.Town}', 
                        '${params.Country}', 
                        '${params.CreditCard}', 
                        '', 
                        '${params.Email}', 
                        '', 
                        '${params.Mobile}', 
                        '${params.FirstName}', 
                        '', 
                        '${params.ZipCode}', 
                        '',
                        ${params.RegionId});`; 
            
                    
                    db.query(query, (err, result) => {
                       if (err != null) response.status(500).send({ error: err.message });
            
                       return response.json(true);
                   });
                })
                .catch(function(error) {
                    
                    var errorCode = error.code;
                    var errorMessage = error.message;
                    return response.status(500).send({ error: error.message });
                    
                });
    } catch (error) {
        if (error != null) response.status(500).send({ error: error.message });
    }
};

const AuthenticateLogin = (request, response) => {
    try {
        let params = request.body;
        SignInRegular(params.Username, params.Password)
            .then((res) => {
                let query = `SELECT 
                    A.email AS 'Email',
                    A.password AS 'Password',
                    A.address_1 AS 'AddressOne',
                    A.address_2 AS 'AddressTwo',
                    A.city AS 'Town',
                    A.country AS 'Country',
                    A.credit_card AS 'CreditCard',
                    A.customer_id AS 'CustomerId',
                    A.mob_phone AS 'Mobile',
                    A.name AS 'FullName',
                    A.postal_code AS 'ZipCode',
                    A.shipping_region_id AS 'RegionId'
                    FROM  customer A
                    WHERE A.email = '${params.Username}';`; 

                
                db.query(query, (err, result) => {
                    if (err != null) response.status(500).send({ error: err.message });
                    return response.json(result);
                });
            })
            .catch((error) => {
                return response.status(500).send({ error: error.message });
            });
    } catch (error) {
        if (error != null) response.status(500).send({ error: error.message });
    }
};

const Logout = (request, response) => {
    try {
        firebase.auth().signOut().then(res => {
            return response.json(res);
        })
    } catch (error) {
        if (error != null) response.status(500).send({ error: error.message });
    }
};

const SignInRegular = (email, password) => {
    return firebase.auth().signInWithEmailAndPassword(email, password);
}

const customer = {
    RegisterCustomer,
    AuthenticateLogin,
    Logout
};

module.exports = customer;