provider "aws" {
  region = "us-east-1"
}

resource "random_password" "secret" {
  length = 16
}

module "collector" {
  source = "../.."

  secret                              = random_password.secret.result
  delete_events_when_destroying_stack = true # Required for the automated tests to succeed
}

resource "spacelift_audit_trail_webhook" "this" {
  endpoint     = module.collector.courier_url
  enabled      = false
  secret       = random_password.secret.result
}
