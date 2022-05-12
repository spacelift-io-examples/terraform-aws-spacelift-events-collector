provider "aws" {
  region = "us-east-1"
}

module "collector" {
  source = "../.."

  delete_events_when_destroying_stack = true # Required for the automated tests to succeed
}
