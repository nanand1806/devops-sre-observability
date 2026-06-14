variable "subscription_id" {
  description = "Azure subscription ID to deploy the landing zone into"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "centralindia"
}

variable "project_name" {
  description = "Short name used to prefix and tag resources"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "hub_address_space" {
  description = "Address space for the hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_address_space" {
  description = "Address space for the spoke VNet"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "allowed_locations" {
  description = "Regions allowed by the governance policy assignment"
  type        = list(string)
  default     = ["centralindia", "southindia"]
}

variable "log_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    Project   = "landing-zone-demo"
    ManagedBy = "Terraform"
  }
}
