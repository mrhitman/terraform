import { APIGatewayProxyHandler } from 'aws-lambda';
import { SqsService } from './sqs';

export const handler: APIGatewayProxyHandler = async (event, _context) => {
  const sqs = new SqsService({
    region: process.env.region!,
    queueUrl: 'https://sqs.eu-central-1.amazonaws.com/616174815271/terraform-example-queue', //process.env.sqs!,
  });

  await sqs.send(event);
  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: 'lambda 2',
        input: event,
      },
      null,
      2,
    ),
  };
};
