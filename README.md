# Spacelift Events Collector for AWS

Terraform module setting up a collector that receives Audit Trail events sent by Spacelift and stores them in AWS S3.

## Usage

```hcl
provider "aws" {
  region = "us-east-1" # Change if you want to use a different region
}

module "collector" {
  source = "github.com/spacelift-io-examples/terraform-aws-spacelift-events-collector"

	# Add inputs described below as needed
}
```

## Architecture

The main resources for this module are:

- **Courier**: A Lambda function that exposes a URL (see the `courier_url` output) and forwards incoming events to a Kinesis Firehose Delivery Stream.
- **Stream**: A Kinesis Firehose Delivery Stream that buffers events forwarded by the Courier and eventually sends them in batches to the Storage.
- **Storage**: An S3 bucket that stores the events (see the `storage_bucket_name` output).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| archive | ~> 2.2 |
| aws | >= 5.51.1 |
| random | ~> 3.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| buffer\_interval | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination | `number` | `300` | no |
| buffer\_size | Buffer incoming events to the specified size, in MBs, before delivering it to the destination | `number` | `5` | no |
| delete\_events\_when\_destroying\_stack | Whether to delete stored events when destroying the stack | `bool` | `false` | no |
| events\_expiration\_days | Keep the events for this number of days | `number` | `365` | no |
| logs\_retention\_days | Keep the logs for this number of days | `number` | `14` | no |
| logs\_verbose | Include debug information in the logs | `bool` | `false` | no |
| python\_version | AWS Lambda Python runtime version | `string` | `"3.9"` | no |
| s3_bucket_name | Name of existing bucket for logs | `string` | `null` | no |
| secret | Secret to be expected by the collector | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| courier\_function\_arn | The ARN for the Lambda function for the courier |
| courier\_url | The HTTP URL endpoint for the courier |
| storage\_bucket\_name | The name for the S3 bucket that stores the events |
| stream\_name | The name for the Kinesis Firehose Delivery Stream |
<!-- END_TF_DOCS -->
