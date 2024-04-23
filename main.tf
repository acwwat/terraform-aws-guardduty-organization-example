terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.5"
}

provider "aws" {
  alias   = "management"
  profile = "management"
}

provider "aws" {
  alias   = "audit"
  profile = "audit"
}

data "aws_caller_identity" "audit" {
  provider = aws.audit
}

resource "aws_guardduty_detector" "audit" {
  provider = aws.audit
}

resource "aws_guardduty_detector_feature" "audit" {
  provider    = aws.audit
  for_each    = var.guardduty_features
  detector_id = aws_guardduty_detector.audit.id
  name        = each.value.name
  status      = each.value.auto_enable == "NONE" ? "DISABLED" : "ENABLED"
  dynamic "additional_configuration" {
    for_each = coalesce(each.value.additional_configuration, [])
    content {
      status = additional_configuration.value.auto_enable == "NONE" ? "DISABLED" : "ENABLED"
      name   = additional_configuration.value.name
    }
  }
}

resource "aws_guardduty_organization_admin_account" "this" {
  provider         = aws.management
  admin_account_id = data.aws_caller_identity.audit.account_id
  depends_on       = [aws_guardduty_detector.audit]
}

resource "aws_guardduty_organization_configuration" "this" {
  provider                         = aws.audit
  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.audit.id
  depends_on                       = [aws_guardduty_organization_admin_account.this]
}

resource "aws_guardduty_organization_configuration_feature" "this" {
  provider    = aws.audit
  for_each    = var.guardduty_features
  auto_enable = each.value.auto_enable
  detector_id = aws_guardduty_detector.audit.id
  name        = each.value.name
  dynamic "additional_configuration" {
    for_each = coalesce(each.value.additional_configuration, [])
    content {
      auto_enable = additional_configuration.value.auto_enable
      name        = additional_configuration.value.name
    }
  }
  depends_on = [aws_guardduty_organization_admin_account.this]
}
