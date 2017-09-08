
const bunyan = require('bunyan')
let logger = null

module.exports.helloWorld = (event, context, callback) => {

    try {

        logger = bunyan.createLogger({
            name: 'helloWorld API',
            'function-name': context.functionName
        })

        const html = `
          <html>
           <body>
            <h1>Hello World</h1>
           </body>
          </html>`;

        const response = {
          statusCode: 200,
            headers: {
              'Content-Type': 'text/html',
            },
          body: html,
        };

        return callback(null, response);

    } catch(err) {
        logger.error({
            'lambda-status': 'failed',
            err
        })

        callback(null, failure( { error: err } ))

    }
}
