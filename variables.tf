variable "resource_name" {
  description = "Used to naming the new resources"
  type        = string
  default     = "UptycsIntegration-123"
}
variable "set_tenant_level_permissions" {
  description = "The flag to choose permissions to be attached to the application at tenant level or subscription level"
  type        = bool
  default     = true
}
variable "parent_management_group_name" {
  description = "ID of the Root Management Group"
  type        = string
}
