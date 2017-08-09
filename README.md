# serverless-sumologic

Create a SumoLogic Lambda function which publishes the CloudWatch logs to SumoLogic.

## Prerequisites

- Docker
- Docker Compose
- Make
- AWS Admin Access

## Environment variables

Make sure you have set your environment variable properly or create a file `.env`.

`.env.template` contains the environment variables that are used by the application.

`.env.local` contains an example of environment variables with values

## Usage

```bash
# Create a `.env` file with `.env.local`
$ make dotenv DOTENV=.env.local
# Deploy the lambda stack
$ make deploy
# Remove the lambda stack
$ make remove
```