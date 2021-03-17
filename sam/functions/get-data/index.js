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
exports.lambdaHandler = async () => {

	// Create JSON object with parameters for DynamoDB and store in a variable
	let params = {
		TableName: process.env.TERRAFORM_ITEMS_TABLE,
	};

	let data = await dbRead(params);

	async function dbRead(params) {
		let promise = dynamodb.scan(params).promise();
		let result = await promise;
		let data = result.Items;
		if (result.LastEvaluatedKey) {
			params.ExclusiveStartKey = result.LastEvaluatedKey;
			data = data.concat(await dbRead(params));
		}
		return data;
	}
	const response = {
		statusCode: 200,
		body: data
	};
	return response
};