data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

resource "aws_s3_bucket" "storage" {
  bucket = "spacelift-events-${random_string.suffix.result}"
  count  = var.s3_bucket_name == "" ? 1 : 0
}

resource "aws_s3_bucket_lifecycle_configuration" "cleanup" {
  bucket = aws_s3_bucket.storage[0].id
  count  = var.s3_bucket_name == "" ? 1 : 0

  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }

  rule {
    id     = "delete-old-events"
    status = "Enabled"

    expiration {
      days = var.events_expiration_days
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket.storage[0].id
  count  = var.s3_bucket_name == "" ? 1 : 0

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_alias.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
