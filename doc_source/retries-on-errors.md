# Error Handling and Automatic Retries in AWS Lambda<a name="retries-on-errors"></a>

When you invoke a function, two types of error can occur\. Invocation errors occur when the invocation request is rejected before your function receives it\. Function errors occur when your function's code or [runtime](lambda-runtimes.md) returns an error\. Depending on the type of error, the type of invocation, and the client or service that invokes the function, retry behavior and the strategy for managing errors varies\.

Issues with the request, caller, or account can cause invocation errors\. Invocation errors include an error type and status code in the response that indicate the cause of the error\.

**Common Invocation Errors**
+ **Request** – The request event is too large or is not valid JSON; the function does not exist; a parameter value is the wrong type\.
+ **Caller** – The user or service does not have permission to invoke the function\.
+ **Account** – The maximum number of function instances are already running, or requests are being made too quickly\.

Clients such as the AWS CLI and the AWS SDK retry on client timeouts, throttling errors \(429\) and other errors not caused by a bad request \(500 series\)\. For a full list of invocation errors, see [the Invoke API reference documentation](API_Invoke.md#API_Invoke_Errors)\.

Function errors occur when your function code or the runtime that it uses return an error\.

**Common Function Errors**
+ **Function** – Your function's code throws an exception or returns an error object\.
+ **Runtime** – The runtime terminated your function because it ran out of time, detected a syntax error, or failed to marshal the response object into JSON\. The function exited with an error code\.

Unlike invocation errors, function errors do not cause Lambda to return a 400\-series or 500\-series status code\. If the function returns an error, Lambda indicates this by including a header named `X-Amz-Function-Error`, and a JSON\-formatted response with the error message and other details\. For examples of function errors in each language, see the following topics\.
+  [AWS Lambda Function Errors in Node\.js](nodejs-prog-mode-exceptions.md) 
+  [AWS Lambda Function Errors in Python](python-exceptions.md) 
+  [AWS Lambda Function Errors in Ruby](ruby-exceptions.md) 
+  [AWS Lambda Function Errors in Java](java-exceptions.md) 
+  [AWS Lambda Function Errors in Go](go-programming-model-errors.md) 
+  [AWS Lambda Function Errors in C\#](dotnet-exceptions.md) 
+  [AWS Lambda Function Errors in PowerShell](powershell-exceptions.md) 

When you invoke a function directly, you determine the strategy for handling errors\. You can retry, send the event to a queue for debugging, or ignore the error\. Your function's code may have run completely, partially, or not at all\. If you retry, ensure that your function's code can handle the same event multiple times without causing duplicate transactions or other unwanted side effects\.

When you invoke a function indirectly, you need to be aware of the retry behavior of the invoker and any service that the request encounters along the way\. This includes the following scenarios\.
+ **Asynchronous Invocation** – Lambda retries function errors twice\. If the function doesn't have enough capacity to handle all incoming requests, events may wait in the queue for hours or days to be sent to the function\. You can configure a dead\-letter queue on the function to capture events that were not successfully processed\. For more information, see [Asynchronous Invocation](invocation-async.md)\.
+ **Event Source Mappings** – Event source mappings that read from streams retry the entire batch of items\. Repeated errors block processing of the affected shard until the error is resolved or the items expire\. To detect stalled shards, you can monitor the [Iterator Age](monitoring-functions-metrics.md) metric\.

  For event source mappings that read from a queue, you determine the length of time between retries and destination for failed events by configuring the visibility timeout and redrive policy on the source queue\. For more information, see [AWS Lambda Event Source Mapping](invocation-eventsourcemapping.md) and the service\-specific topics under [Using AWS Lambda with Other Services](lambda-services.md)\.
+ **AWS Services** – AWS services may invoke your function [synchronously](invocation-sync.md) or asynchronously\. For synchronous invocation, the service is responsible for retries\. For asynchronous invocation, the behavior is the same as when you invoke the function asynchronously\. For more information, see the service\-specific topics under [Using AWS Lambda with Other Services](lambda-services.md) and the invoking service's documentation\.
+ **Other Accounts and Clients** – When you grant access to other accounts, you can use [resource\-based policies](access-control-resource-based.md) to restrict the services or resources they can configure to invoke your function\. To protect your function from being overloaded, consider putting an API layer in front of your function with [Amazon API Gateway](with-on-demand-https.md)\.

To help you deal with errors in Lambda applications, Lambda integrates with services like Amazon CloudWatch and AWS X\-Ray\. You can use a combination of logs, metrics, alarms, and tracing to quickly detect and identify issues in your function code, API, or other resources that support your application\. For more information, see [Monitoring and Troubleshooting Lambda Applications](troubleshooting.md)\.

For a sample application that uses a CloudWatch Logs subscription, X\-Ray tracing, and a Lambda function to detect and process errors, see [Error Processor Sample Application for AWS Lambda](sample-errorprocessor.md)\.