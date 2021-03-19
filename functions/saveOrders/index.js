const { v4: uuidv4 } = require('uuid');
// Include the AWS SDK module
const AWS = require('aws-sdk');
// Instantiate a DynamoDB document client with the SDK
let dynamodb = new AWS.DynamoDB.DocumentClient();
// Use built-in module to get current date & time
let date = new Date();
// Store date and time in human-readable format in a variable
let now = date.toISOString();
// Define handler function, the entry point to our code for the Lambda service
// We receive the object that triggers the function as a parameter
exports.handler = async (event) => {
    var user = event.requestContext.authorizer.claims['cognito:username'];
    var group = event.requestContext.authorizer.claims['cognito:groups'];
    if (group !== 'customer-group') {
        return {
            statusCode: 401,
            body: JSON.stringify(
                {
                    message: "Sorry! Customers only can place orders!"
                }
            )
        };
    }

    event = JSON.parse(event.body)

    // Create JSON object with parameters for DynamoDB and store in a variable
    let params = {
        TableName: 'OrderTableTerraform',
        Item: {
            'OrderId': uuidv4(),
            'UserId': user,
            'Items': event.Items,
            'Status': 'Order Placed'
        }
    };

    // Using await, make sure object writes to DynamoDB table before continuing execution
    await dynamodb.put(params).promise();
    // Create a JSON object with our response and store it in a constant
    const response = {
        statusCode: 200,
        body: JSON.stringify(
            {
                status: 'Success',
                message: "Order updated successfully"
            }
        )
    };
    // Return the response constant
    return response;
};