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
exports.handler = async () => {

    // Create JSON object with parameters for DynamoDB and store in a variable
    let params = {
        TableName: 'OrderTableTerraform',
    };

    async function itemRead(item) {
        if (!item.ItemId) {
            return
        }
        console.log(item);
        let params = {
            TableName: 'ItemsTableTerraform',
            ProjectionExpression: "#ItemId, ItemName, UnitPrice",
            FilterExpression: "#ItemId = :ItemId",
            ExpressionAttributeNames: {
                "#ItemId": "ItemId"
            },
            ExpressionAttributeValues: {
                ":ItemId": item.ItemId
            }
        }

        let itemPromise = dynamodb.scan(params).promise();
        let itemResult = await itemPromise;
        console.log(itemResult);
        return itemResult.Items[0]


    }

    async function dbRead(params) {
        let promise = dynamodb.scan(params).promise();
        let result = await promise;
        let data = result.Items;
        if (result.LastEvaluatedKey) {
            params.ExclusiveStartKey = result.LastEvaluatedKey;
            data = data.concat(await dbRead(params));
        }
        return data
    }

    let data = await dbRead(params);

    for (const record of data) {
        for (const item of record.Items) {
            let itemResult = await itemRead(item);
            item.ItemName = itemResult.ItemName;
            item.UnitPrice = itemResult.UnitPrice;
        }
    }

    const response = {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(data)
    };
    return response
};