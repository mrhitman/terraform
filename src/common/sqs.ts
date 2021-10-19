import {SQS} from "aws-sdk";
import stringify from "fast-json-stable-stringify";
import {createHash} from "crypto";

export interface SendMessageOptions {
  queueUrl?: string;
  messageGroupId?: string;
}
export class SqsService {
  private sqs: SQS;
  private queueUrl: string;

  constructor(aws: {region: string; queueUrl: string}) {
    this.queueUrl = aws.queueUrl;
    this.sqs = new SQS({region: aws.region});
  }

  async send(message: any, options: SendMessageOptions = {}) {
    const body = stringify(message);
    return this.sqs
      .sendMessage({
        MessageBody: body,
        QueueUrl: options.queueUrl || this.queueUrl,
        MessageGroupId: options.messageGroupId,
        MessageDeduplicationId: createHash("md5").update(body).digest("hex"),
      })
      .promise();
  }
}
