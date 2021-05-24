import { APIGatewayProxyHandler } from "aws-lambda";
import { SqsService } from "common/sqs";

const config = {
  region: process.env.region!,
  queueUrl: process.env.sqs!,
};

export const handler: APIGatewayProxyHandler = async (event) => {
  const sqs = new SqsService({
    region: config.region,
    queueUrl: config.queueUrl,
  });

  await sqs.send(event);
  console.log("THISK IS LAMBDA 2", event);

  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: "lambda 2",
        input: event,
      },
      null,
      2
    ),
  };
};
