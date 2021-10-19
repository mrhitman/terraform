import {APIGatewayProxyHandler} from "aws-lambda";
import * as AWS from "aws-sdk";

const dynamo = new AWS.DynamoDB.DocumentClient();
const tableName = "device-connections";

export const handler: APIGatewayProxyHandler = async (event, _context) => {
  console.log("THISK IS LAMBDA ONDISCONNECT", event);

  const connectionId = event.requestContext.connectionId;
  const record = await dynamo
    .scan({
      TableName: tableName,
      FilterExpression: "connectionId = :connectionId",
      ExpressionAttributeValues: {
        ":connectionId": connectionId,
      },
      ProjectionExpression: "deviceId",
    })
    .promise();

  await Promise.all(
    (record.Items as Array<{deviceId: string}>).map((item) =>
      dynamo
        .delete({
          Key: {
            deviceId: item.deviceId,
            connectionId,
          },
          TableName: tableName,
        })
        .promise()
    )
  );

  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: "lambda ondisconnect ",
        input: event,
      },
      null,
      2
    ),
  };
};
