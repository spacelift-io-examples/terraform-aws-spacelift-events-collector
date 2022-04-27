provider "aws" {
  region = "us-east-1"
}

module "collector" {
  source = "github.com/spacelift-io-examples/terraform-aws-spacelift-events-collector"

  delete_events_when_destroying_stack = true # Required for the automated tests to succeed
}
