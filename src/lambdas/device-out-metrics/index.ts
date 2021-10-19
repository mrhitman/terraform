import {APIGatewayProxyHandler} from "aws-lambda";

export const handler: APIGatewayProxyHandler = async (event, _context) => {
  console.log("THIS IS TRIGGERED LAMBDA FROM DEVICE OUT METRICS", event);

  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: "device out metrics",
        input: event,
      },
      null,
      2
    ),
  };
};
