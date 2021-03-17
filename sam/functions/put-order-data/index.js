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
exports.lambdaHandler = async (event) => {
	console.log(event);
	// if(event.Group !== 'customer-group'){
	//     return "Sorry! Customers only can place orders!"
	// }

	// Create JSON object with parameters for DynamoDB and store in a variable
	let params = {
		TableName: process.env.TERRAFORM_ORDERS_TABLE,
		Item: {
			'OrderId': uuidv4(),
			'UserId': event.UserId,
			'Items': event.Items,
			'Status': 'Order Placed'
		}
	};

	// Using await, make sure object writes to DynamoDB table before continuing execution
	await dynamodb.put(params).promise();
	// Create a JSON object with our response and store it in a constant
	const response = {
		statusCode: 200,
		body: `Order updated successfully`
	};
	// Return the response constant
	return response;
};