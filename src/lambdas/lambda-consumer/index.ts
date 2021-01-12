import { APIGatewayProxyHandler } from 'aws-lambda';

export const handler: APIGatewayProxyHandler = async (event, _context) => {
  console.log('THISK IS LAMBDA 1', event);
  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: 'lambda 1 assadasdas ',
        input: event,
      },
      null,
      2,
    ),
  };
};
