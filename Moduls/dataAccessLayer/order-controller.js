const nodemailer = require('nodemailer');

const CreateOrder = (request, response) => {
    try {

        const user = request.body.User;
        const cart = request.body.Cart;
        const remark = request.body.Remarks;
        const totalAmount = request.body.TotalAmount;

        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: 'avs123@gmail.com',
                pass: 'Ste1234'
            }
            
        });

        let mailOptions = {
            from: 'avs123@gmail.com',
            to: `${user.Email}`,
            subject: "Congratulations! Your order placed succesfully.", 
            text: `Hello ${user.Name}`, 
            html: `<b>Hello  ${user.Name} </b>`
        }
        
        transporter.sendMail(mailOptions, function (error, info) {
            if (error) {
                console.log(error);
                return response.json(error);
            } else {
                console.log('Email sent: ' + info.response);

                let query = `INSERT INTO orders
                                (total_amount, created_on, shipped_on, status, comments, customer_id, auth_code, reference, shipping_id)
                            VALUES
                            (
                                ${totalAmount}, 
                                CURDATE(), 
                                CURDATE(), 
                                1, 
                                '${remark}', 
                                ${user.CustomerId}, 
                                '', 
                                '', 
                                1, 
                                1
                            );`; 

                
                db.query(query, (err, result) => {
                    if (err != null) response.status(500).send({ error: error.message });
                    let values = [];
                    cart.forEach(element => {
                        let row = '';
                        row = `(
                            ${result.insertId},
                            ${element.ProductId},
                            '',
                            ${element.Quantity},
                            ${element.Price}
                        )`;
                        values.push(row);
                    });
                    let rows = values.toString();

                    let subQuery = `INSERT INTO order_detail
                                        (order_id, product_id, attributes, product_name, quantity, unit_cost)
                                    values ${rows};`; 
                    db.query(subQuery, (err, result) => {
                        if (err != null) response.status(500).send({ error: err.message });
                        return response.json(result);
                    });

                    return response.json(result);
                });
            }
        });


    } catch (error) {
        if (error != null) response.status(500).send({ error: error.message });
    }
};

const SendTestMail = async ()=> {
    let remark = 'test mail';

    let testAccount = await nodemailer.createTestAccount();

     
    let transporter = nodemailer.createTransport({
        service: 'gmail',
            auth: {
                user: 'avs123@gmail.com',
                pass: 'Ste1234' 
            }
    });

    

    let mailOptions = {
        from: '"Stefan" <no-reply@stefan.com>',
        to: 'random@gmail.com',
        subject: "Order Details",
        text: "test purpose", 
        html: `<b>test account ${remark} </b>`
    }

    await transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            console.log(error);
            return response.json(error);
        } else {
            console.log('Email sent: ' + info.response);
        }
    });
};

const order = {
    CreateOrder,
    SendTestMail
};

module.exports = order;