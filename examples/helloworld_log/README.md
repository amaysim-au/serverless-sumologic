# HelloWorld Log

This example shows how to connect to a SumoLogic Lambda using the `resources` section of `serverless.yml`.

## Environment variables

Make sure you have set your environment variables properly or create a file `.env`. The file `.env.template` contains the environment variables that are used by the application.

## Usage

```bash
# using .env.example for .env as an example
$ make dotenv DOTENV=.env.example
# deploy
$ make deploy
# remove
$ make remove
```