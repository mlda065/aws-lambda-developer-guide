# AWS Lambda Function Handler in Node\.js<a name="nodejs-prog-model-handler"></a>

The handler is the method in your Lambda function that processes events\. When you invoke a function, the [runtime](lambda-runtimes.md) runs the handler method\. When the handler exits or returns a response, it becomes available to handle another event\.

The following example function logs the contents of the event object and returns the location of the logs\.

**Example index\.js File**  

```
exports.handler =  async function(event, context) {
  console.log("EVENT: \n" + JSON.stringify(event, null, 2))
  return context.logStreamName
}
```

When you [configure a function](resource-model.md), the value of the handler setting is the file name and the name of the exported handler module, separated by a dot\. The default in the console and for examples in this guide is `index.handler`\. This indicates the `handler` module that's exported by `index.js`\.

The runtime passes three arguments to the handler method\. The first argument is the `event` object, which contains information from the invoker\. The invoker passes this information as a JSON\-formatted string when it calls [Invoke](API_Invoke.md)\. When an AWS service invokes your function, the event structure [varies by service](lambda-services.md)\.

The second argument is the [context object](nodejs-prog-model-context.md), which contains information about the invocation, function, and execution environment\. In the preceding example, the function gets the name of the [log stream](nodejs-prog-model-logging.md) from the context object and returns it to the invoker\.

The third argument, `callback`, is a function that you can call in [non\-async functions](#nodejs-handler-sync) to send a response\. The callback function takes two arguments: an `Error` and a response\. The response object must be compatible with `JSON.stringify`\.

For async functions, you return a response, error, or promise to the runtime instead of using `callback`\.

## Async Functions<a name="nodejs-handler-async"></a>

For async functions, you can use `return` and `throw` to send a response or error, respectively\. Functions must use the `async` keyword to use these methods to return a response or error\.

If your code performs an asynchronous task, return a promise to make sure that it finishes running\. When you resolve or reject the promise, Lambda sends the response or error to the invoker\.

**Example index\.js File – HTTP Request with Async Function and Promises**  

```
const https = require('https')
let url = "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html"

exports.handler = async function(event) {
  const promise = new Promise(function(resolve, reject) {
    https.get(url, (res) => {
        resolve(res.statusCode)
      }).on('error', (e) => {
        reject(Error(e))
      })
    })
  return promise
}
```

For libraries that return a promise, you can return that promise directly to the runtime\.

**Example index\.js File – AWS SDK with Async Function and Promises**  

```
const AWS = require('aws-sdk')
const s3 = new AWS.S3()

exports.handler = async function(event) {
  return s3.listBuckets().promise()
}
```

## Non\-Async Functions<a name="nodejs-handler-sync"></a>

The following example function checks a URL and returns the status code to the invoker\.

**Example index\.js File – HTTP Request with Callback**  

```
const https = require('https')
let url = "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html"

exports.handler =  function(event, context, callback) {
  https.get(url, (res) => {
    callback(null, res.statusCode)
  }).on('error', (e) => {
    callback(Error(e))
  })
}
```

For non\-async functions, function execution continues until the [event loop](https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/) is empty or the function times out\. The response isn't sent to the invoker until all event loop tasks are finished\. If the function times out, an error is returned instead\. You can configure the runtime to send the response immediately by setting [context\.callbackWaitsForEmptyEventLoop](nodejs-prog-model-context.md) to false\.

In the following example, the response from Amazon S3 is returned to the invoker as soon as it's available\. The timeout running on the event loop is frozen, and it continues running the next time the function is invoked\.

**Example index\.js File – callbackWaitsForEmptyEventLoop**  

```
const AWS = require('aws-sdk')
const s3 = new AWS.S3()

exports.handler = function(event, context, callback) {
  context.callbackWaitsForEmptyEventLoop = false
  s3.listBuckets(null, callback)
  setTimeout(function () {
    console.log('Timeout complete.')
  }, 5000)
}
```