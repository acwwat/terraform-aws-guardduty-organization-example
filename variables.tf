variable "guardduty_features" {
  description = "An object map that defines the GuardDuty organization configuration."
  type = map(object({
    auto_enable = string
    name        = string
    additional_configuration = optional(list(object({
      auto_enable = string
      name        = string
    })))
  }))
  default = {
    s3 = {
      auto_enable = "NONE"
      name        = "S3_DATA_EVENTS"
    }
    eks = {
      auto_enable = "NONE"
      name        = "EKS_AUDIT_LOGS"
    }
    eks_runtime_monitoring = {
      # EKS_RUNTIME_MONITORING is deprecated and should thus be explicitly disabled
      auto_enable = "NONE"
      name        = "EKS_RUNTIME_MONITORING"
      additional_configuration = [
        {
          auto_enable = "NONE"
          name        = "EKS_ADDON_MANAGEMENT"
        },
      ]
    }
    runtime_monitoring = {
      auto_enable = "NONE"
      name        = "RUNTIME_MONITORING"
      additional_configuration = [
        {
          auto_enable = "NONE"
          name        = "EKS_ADDON_MANAGEMENT"
        },
        {
          auto_enable = "NONE"
          name        = "ECS_FARGATE_AGENT_MANAGEMENT"
        },
        {
          auto_enable = "NONE"
          name        = "EC2_AGENT_MANAGEMENT"
        }
      ]
    }
    malware = {
      auto_enable = "NONE"
      name        = "EBS_MALWARE_PROTECTION"
    }
    rds = {
      auto_enable = "NONE"
      name        = "RDS_LOGIN_EVENTS"
    }
    lambda = {
      auto_enable = "NONE"
      name        = "LAMBDA_NETWORK_LOGS"
    }
  }
}
