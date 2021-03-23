// Include the AWS SDK module
const AWS = require('aws-sdk');
const {
    CognitoUserPool,
    CognitoUserAttribute,
    CognitoUser,
    AuthenticationDetails,
    CognitoUserSession
} = require("amazon-cognito-identity-js");

// Use built-in module to get current date & time
let date = new Date();
// Store date and time in human-readable format in a variable
let now = date.toISOString();
// Define handler function, the entry point to our code for the Lambda service
// We receive the object that triggers the function as a parameter
exports.handler = async (event) => {

    event = JSON.parse(event.body)

    const POOL_DATA = {
        UserPoolId: process.env.userPoolId,
        ClientId: process.env.appClientId
    };
    const userPool = new CognitoUserPool(POOL_DATA);

    console.log(userPool);

    var username = event.name;
    var password = event.password;
    console.log(username, password);

    const loginCognitoUser = () => {

        const authData = {
            Username: username,
            Password: password
        };
        const authDetails = new AuthenticationDetails(authData);
        console.log(authDetails);
        const userData = {
            Username: username,
            Pool: userPool
        };
        const cognitoUser = new CognitoUser(userData);

        return new Promise((resolve, reject) =>
            cognitoUser.authenticateUser(authDetails, {
                onSuccess: result => {
                    console.log(result); return resolve({
                        statusCode: 200,
                        body: JSON.stringify(
                            {
                                status: 'Success',
                                message: "Logged in successfully",
                                token: result.getIdToken().getJwtToken()
                            }
                        )
                    })
                },
                onFailure: err => { console.log(err); return reject(err) }
            })
        );
    }

    return loginCognitoUser();

};