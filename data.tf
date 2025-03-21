locals {
  api_gw_enabled = local.is_govcloud || var.api_gw_enabled = true
  is_govcloud     = data.aws_partition.current.partition == "aws-us-gov"
  each_govcloud   = local.is_govcloud ? toset(["enabled"]) : []
  each_commercial = local.is_govcloud || var.api_gw_enabled = true ? [] : toset(["enabled"])
}

data "aws_partition" "current" {}