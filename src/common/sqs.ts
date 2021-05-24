import { SQS } from "aws-sdk";
import stringify from "fast-json-stable-stringify";

export class SqsService {
  private sqs: SQS;
  private queueUrl: string;

  constructor(aws: { region: string; queueUrl: string }) {
    this.queueUrl = aws.queueUrl;
    this.sqs = new SQS({ region: aws.region });
  }

  async send(message: any, queueUrl?: string) {
    return this.sqs
      .sendMessage({
        MessageBody: stringify(message),
        QueueUrl: queueUrl || this.queueUrl,
      })
      .promise();
  }
}
