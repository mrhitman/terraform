import {SQSHandler} from "aws-lambda";
import * as AWS from "aws-sdk";
import {readFromEnv} from "common";

const dynamo = new AWS.DynamoDB.DocumentClient();
const tableName = "device-connections";
const apigatewaymanagementapi = new AWS.ApiGatewayManagementApi({
  endpoint: readFromEnv("invokeUrl").replace("wss", "https"),
});

export const handler: SQSHandler = async (event, _context) => {
  const command = JSON.parse(event.Records[0].body);
  const {Items: items} = await dynamo
    .scan({
      TableName: tableName,
      FilterExpression: "deviceId = :deviceId",
      ExpressionAttributeValues: {
        ":deviceId": command.deviceId.toString(),
      },
    })
    .promise();

  if (!items?.length) {
    throw new Error(`No active connection for device:${command.deviceId}`);
  }

  const item = items[0];
  const params = {
    ConnectionId: item.connectionId,
    Data: JSON.stringify(command),
  };

  await apigatewaymanagementapi.postToConnection(params).promise();
};
