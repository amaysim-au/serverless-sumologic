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