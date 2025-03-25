output "courier_function_arn" {
  description = "The ARN for the Lambda function for the courier"
  value       = aws_lambda_function.courier.arn
}

output "courier_url" {
  description = "The HTTP URL endpoint for the courier"
  value       = length(local.api_gw_enabled) > 0 ? aws_apigatewayv2_stage.this["enabled"].invoke_url : aws_lambda_function_url.courier["enabled"].function_url
}

output "storage_bucket_name" {
  description = "The name for the S3 bucket that stores the events"
  value       = aws_s3_bucket.storage.id
}

output "stream_name" {
  description = "The name for the Kinesis Firehose Delivery Stream"
  value       = aws_kinesis_firehose_delivery_stream.stream.name
}
