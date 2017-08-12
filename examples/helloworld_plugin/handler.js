'use strict';

module.exports.helloWorld = (event, context, callback) => {
  console.log('Hello World');
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
}
