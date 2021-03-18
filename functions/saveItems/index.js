const { v4: uuidv4 } = require('uuid');
// Include the AWS SDK module
const AWS = require('aws-sdk');
// Instantiate a DynamoDB document client with the SDK
let dynamodb = new AWS.DynamoDB.DocumentClient();
// Use built-in module to get current date & time
let date = new Date();
// Store date and time in human-readable format in a variable
let now = date.toISOString();

const jwt_decode = require('jwt-decode');
// Define handler function, the entry point to our code for the Lambda service
// We receive the object that triggers the function as a parameter
exports.handler = async (event) => {

    var user = event.requestContext.authorizer.claims['cognito:username'];

    event = JSON.parse(event.body)
    // if(event.Group !== 'admin-group'){
    //     return "Sorry! Admin only can add items"
    // }

    // Create JSON object with parameters for DynamoDB and store in a variable
    let params = {
        TableName: 'ItemsTableTerraform',
        Item: {
            'ItemId': uuidv4(),
            'UserId': user,
            'ItemName': event.ItemName,
            'StockQuantity': event.StockQuantity,
            'SoldQuantity': event.SoldQuantity,
            'UnitPrice': event.UnitPrice,
            'IsPublished': event.IsPublished

        }
    };

    // Using await, make sure object writes to DynamoDB table before continuing execution
    await dynamodb.put(params).promise();
    // Create a JSON object with our response and store it in a constant
    const response = {
        statusCode: 200,
        body: JSON.stringify(
            {
                status: 'success',
                message: 'Item added successfully'
            }
        )
    };
    // Return the response constant
    return response;
};
