variable "user" {
  type        = string
  description = "Name of the user to create. Defaults to `<database>_user` if not set."
  default     = null
}

variable "password" {
  type        = string
  default     = null
  description = "User password, generated if not set."
}

variable "database" {
  type        = string
  description = "Database in which create the user."
}

variable "roles" {
  description = "User database roles list."
  type        = list(string)
  default     = []
}

variable "database_user_search_path" {
  description = "User search path."
  type        = string
  default     = null
}
