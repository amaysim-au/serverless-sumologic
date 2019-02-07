// This scripts is to clean up Lambda Policy by adding a generic lambda permission
// that allows CloudWatch Logs to invoke the lambda FUNCTION_NAME and removing all
// other permissions.
// This was created because the function's policy size exceeded the limit due to
// serverless-log-forward plugin adding the same permission whenever a new stack
// was creted. https://github.com/amplify-education/serverless-log-forwarding/pull/22
const AWS = require('aws-sdk')

const getEnvironmentVariableValue = (name) => {
  if (!process.env[name]) {
    throw new Error(`Environment variable "${name}" is required and must not be empty`)
  }
  return process.env[name]
}

// addGenericPermissionForCloudWatchLogs creates a generic permission with a
// unique statementID that allows CloudWatch Logs of a specific aws region in
// a specific account to invoke lambda functionName
const addGenericPermissionForCloudWatchLogs = (awsAccountId, awsRegion, lambda,
  functionName, statementId) => {
  const params = {
    StatementId: statementId,
    Action: 'lambda:InvokeFunction',
    FunctionName: functionName,
    Principal: 'logs.ap-southeast-2.amazonaws.com',
    SourceArn: `arn:aws:logs:${awsRegion}:${awsAccountId}:*`,
    SourceAccount: awsAccountId,
  }
  return lambda.addPermission(params).promise()
}

const wait = milleseconds => new Promise(resolve => setTimeout(resolve, milleseconds))

// removePermissions removes all permission of lambda functionName and leaves
// permission with statementId exceptGenericPermissionSid untouched.
const removePermissions = async (lambda, functionName, exceptGenericPermissionSid) => {
  const data = await lambda.getPolicy({ FunctionName: functionName }).promise()
  const policy = JSON.parse(data.Policy)

  for (let i = 0; i < policy.Statement.length; i += 1) {
    if (policy.Statement[i].Sid !== exceptGenericPermissionSid) {
      console.log(`removing permission ${policy.Statement[i].Sid}`)

      // eslint-disable-next-line no-await-in-loop
      await lambda.removePermission({ FunctionName: functionName,
        StatementId: policy.Statement[i].Sid }).promise()
      // delay to avoid "TooManyRequestsException: Rate exceeded" error
      await wait(2000) // eslint-disable-line no-await-in-loop
    }
  }
}

(async () => {
  const lambda = new AWS.Lambda()
  const statementId = `GenericInvokePermissionForCloudWatchLogs-${Date.now()}`
  const functionName = getEnvironmentVariableValue('FUNCTION_NAME')
  const awsAccountId = getEnvironmentVariableValue('AWS_ACCOUNT_ID')
  const awsRegion = getEnvironmentVariableValue('AWS_REGION')
  await addGenericPermissionForCloudWatchLogs(awsAccountId, awsRegion, lambda,
    functionName, statementId)
  await removePermissions(lambda, functionName, statementId)
})()
