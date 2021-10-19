import {APIGatewayProxyHandler} from "aws-lambda";
import {SqsService} from "common/sqs";
import {readFromEnv} from "common";

const sqs = new SqsService({
  region: readFromEnv("region"),
  queueUrl: readFromEnv("queueUrl"),
});

export const handler: APIGatewayProxyHandler = async (event, _context) => {
  console.log("THISK IS LAMBDA ONMESSAGE", event);

  const id = (Math.random() * 1e6).toString();
  await sqs.send(event, {
    messageGroupId: id,
  });

  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: "lambda ONMESSAGE",
        input: event,
      },
      null,
      2
    ),
  };
};
