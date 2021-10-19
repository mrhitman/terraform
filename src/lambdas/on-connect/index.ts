import {APIGatewayProxyHandler} from "aws-lambda";
import * as AWS from "aws-sdk";
import {readFromEnv} from "common";

const dynamo = new AWS.DynamoDB.DocumentClient();
const apigatewaymanagementapi = new AWS.ApiGatewayManagementApi({
  endpoint: readFromEnv("invokeUrl").replace("wss", "https"),
});

async function closeConnection(connectionId: string): Promise<void> {
  await apigatewaymanagementapi
    .deleteConnection({ ConnectionId: connectionId })
    .promise().catch(e => console.log(JSON.stringify(e, null, 2)));
}

export const handler: APIGatewayProxyHandler = async (event, _context) => {
  console.log("THISK IS LAMBDA ONCONNECT", event);

  const deviceId = event.queryStringParameters?.id;

  if (!deviceId) {
    await closeConnection(event.requestContext.connectionId!);
    return { statusCode: 400, body: 'No required param' };
  }


  await dynamo
    .put({
      Item: {
        deviceId,
        connectionId: event.requestContext.connectionId,
      },
      ConditionExpression: "attribute_not_exists(deviceId)",
      TableName: "device-connections",
    })
    .promise();

  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: "DEVICE CONNECTED",
        input: event,
      },
      null,
      2
    ),
  };
};
