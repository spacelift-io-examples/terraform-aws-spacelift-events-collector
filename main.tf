locals {
  courier_name = "spacelift-events-collector-courier-${random_string.suffix.result}"
  stream_name  = "spacelift-events-collector-stream-${random_string.suffix.result}"
  bucket_arn   = var.s3_bucket_name == null ? aws_s3_bucket.storage[0].arn : "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_name}"
  bucket_name  = var.s3_bucket_name == null ? aws_s3_bucket.storage[0].bucket : var.s3_bucket_name
}

resource "random_string" "suffix" {
  length  = 8
  lower   = true
  special = false
  upper   = false
}

##################################################
# Courier
##################################################
data "archive_file" "lambda_function" {
  output_file_mode = "0666"
  output_path      = "${path.module}/function.zip"
  source_file      = "${path.module}/function.py"
  type             = "zip"
}

resource "aws_lambda_function" "courier" {
  filename         = data.archive_file.lambda_function.output_path
  function_name    = local.courier_name
  handler          = "function.handler"
  role             = aws_iam_role.courier.arn
  runtime          = "python${var.python_version}"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  environment {
    variables = {
      SECRET  = var.secret
      STREAM  = aws_kinesis_firehose_delivery_stream.stream.name
      VERBOSE = var.logs_verbose
    }
  }
}

moved {
  from = aws_lambda_function_url.courier
  to   = aws_lambda_function_url.courier["enabled"]
}

resource "aws_lambda_function_url" "courier" {
  for_each = local.each_commercial

  authorization_type = "NONE"
  function_name      = aws_lambda_function.courier.function_name
}

resource "aws_iam_role" "courier" {
  name = local.courier_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy" "courier" {
  role = aws_iam_role.courier.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "firehose:PutRecord"
        ],
        Resource = [aws_kinesis_firehose_delivery_stream.stream.arn]
      },
    ]
  })
}

resource "aws_cloudwatch_log_group" "courier" {
  name              = "/aws/lambda/${local.courier_name}"
  retention_in_days = var.logs_retention_days
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.courier.name
}

##################################################
# Stream
##################################################
resource "aws_cloudwatch_log_group" "stream" {
  name              = "/aws/kinesisfirehose/${local.stream_name}"
  retention_in_days = var.logs_retention_days
}

resource "aws_cloudwatch_log_stream" "destination_delivery" {
  log_group_name = aws_cloudwatch_log_group.stream.name
  name           = "DestinationDelivery"
}

resource "aws_kinesis_firehose_delivery_stream" "stream" {
  destination = "extended_s3"
  name        = local.stream_name

  extended_s3_configuration {
    buffering_interval  = var.buffer_interval
    buffering_size      = var.buffer_size
    bucket_arn          = local.bucket_arn
    error_output_prefix = "error/!{firehose:error-output-type}/"
    compression_format  = "GZIP"
    kms_key_arn         = data.aws_kms_alias.s3.arn
    prefix              = "year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    role_arn            = aws_iam_role.stream.arn

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.stream.name
      log_stream_name = aws_cloudwatch_log_stream.destination_delivery.name
    }
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }
}

resource "aws_iam_role" "stream" {
  name = local.stream_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "firehose.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy" "stream" {
  role = aws_iam_role.stream.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Resource = [
          "${local.bucket_arn}",
          "${local.bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = [
          data.aws_kms_alias.s3.arn
        ],
        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.region.amazonaws.com"
          },
          StringLike = {
            "kms:EncryptionContext:aws:s3:arn" : "${local.bucket_arn}/*"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents"
        ],
        Resource = [
          aws_cloudwatch_log_stream.destination_delivery.arn
        ]
      },
    ]
  })
}
