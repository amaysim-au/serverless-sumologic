# serverless-sumologic

Create a SumoLogic Lambda function which publishes the CloudWatch logs to SumoLogic.

## Prerequisites

- Docker
- Docker Compose
- Make
- AWS Admin Access

## Environment variables

Make sure you have set your environment variables properly or create a file `.env`. The file `.env.template` contains the environment variables that are used by the application.

## Usage

```bash
# using .env.example for .env as an example
$ make dotenv DOTENV=.env.example
# Deploy the lambda stack
$ make deploy
# Remove the lambda stack
$ make remove
```

## Scrips

### clean_policy.js

This script removes all permissions of the sumologic lambda and adds a generic one that looks like the following:

```json
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "GenericInvokePermissionForCloudWatchLogs-1549531551541",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.awsregion.amazonaws.com"
      },
      "Action": "lambda:InvokeFunction",
      "Resource": "your:lambda:function:arn",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "awsaccount"
        },
        "ArnLike": {
          "AWS:SourceArn": "arn:aws:logs:awsregion:awsaccount:*"
        }
      }
    }
  ]
}
```

Make sure your environment variables are set properly and run `$ make deps cleanPolicy`.