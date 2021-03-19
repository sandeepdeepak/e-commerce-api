// Include the AWS SDK module
const AWS = require('aws-sdk');
const {
    CognitoUserPool,
    CognitoUserAttribute,
    CognitoIdentityServiceProvider
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
        UserPoolId: event.UserPoolId,
        ClientId: event.ClientId
    };
    const userPool = new CognitoUserPool(POOL_DATA);

    console.log(userPool);

    var username = event.name;
    var password = event.password;
    var email = event.email;
    var group = event.group

    async function saveUserGroup() {
        var params = {
            GroupName: group, /* required */
            UserPoolId: event.UserPoolId, /* required */
            Username: username /* required */
        };
        var cognitoidentityserviceprovider = new AWS.CognitoIdentityServiceProvider();
        return new Promise((resolve, reject) =>
            cognitoidentityserviceprovider.adminAddUserToGroup(params, function (err, data) {
                if (err) reject(err); // an error occurred
                else resolve({
                    statusCode: 200,
                    body: JSON.stringify(
                        {
                            status: 'Success',
                            message: "Signed up successfully"
                        }
                    )
                })
                // successful response
            })
        );
    }


    const signUpCognitoUser = () => {

        const user = {
            username: username,
            email: email,
            password: password
        };
        const attrList = [];
        const emailAttribute = {
            Name: 'email',
            Value: user.email
        };
        attrList.push(new CognitoUserAttribute(emailAttribute));

        return new Promise((resolve, reject) =>
            userPool.signUp(user.username, user.password, attrList, null, (err, result) => {
                if (err) {
                    console.log(err);
                    return reject(err);
                }
                return resolve(saveUserGroup());
            })
        );
    }


    return signUpCognitoUser();

};