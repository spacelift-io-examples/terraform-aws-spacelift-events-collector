locals {
  api_gw_enabled       = local.is_govcloud || var.api_gw_enabled ? toset(["enabled"]) : []
  is_govcloud          = data.aws_partition.current.partition == "aws-us-gov"
  each_govcloud        = local.is_govcloud ? toset(["enabled"]) : []
  function_url_enabled = local.is_govcloud || var.api_gw_enabled ? [] : toset(["enabled"])
}

data "aws_partition" "current" {}