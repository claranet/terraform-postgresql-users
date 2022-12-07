variable "azure_region" {
  description = "Azure region to use."
  type        = string
}

variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "administrator_login" {
  description = "Administrator login for MariaDB server"
  type        = string
}

variable "administrator_password" {
  description = "Administrator password for MariaDB server"
  type        = string
}
