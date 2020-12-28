import { handler } from './';

describe('lambda emitter', () => {
  describe('happy path', () => {
    test('success', async () => {
      const event = {} as any;
      const response: any = await handler(event, null as any, null as any);
      expect(response).toMatchSnapshot();
    });

    test('success2', async () => {
      const event = {} as any;
      const response: any = await handler(event, null as any, null as any);
      expect(response).toMatchSnapshot();
    });
  });
});
