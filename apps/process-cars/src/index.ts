import type { DynamoDBStreamEvent, Handler } from 'aws-lambda';

export const handler: Handler<DynamoDBStreamEvent, void> = async (
  event: DynamoDBStreamEvent
): Promise<void> => {
  console.log('Started processing DynamoDB stream event');

  for (let record of event.Records) {
    console.log('Processing record ', record.dynamodb);
    // Add your custom processing
  }

  console.log('Finished processing DyanmoDB stream event ');
};
