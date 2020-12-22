import { APIGatewayProxyHandler } from 'aws-lambda';
import map from 'lodash/map';

export const handler: APIGatewayProxyHandler = async (event, _context) => {
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'lambda 1',
            map: map([1, 2, 3], v => v * 2),
            input: event,
        }, null, 2),
    };
}