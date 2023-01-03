variable "user" {
  type        = string
  description = "User name for the current database. Generated if not set `<database>_user`."
  default     = null
}

variable "administrator_login" {
  type        = string
  description = "Server administrator user name."
}

variable "password" {
  type        = string
  default     = null
  description = "User password, generated if not set."
}

variable "database" {
  type        = string
  description = "Database name"
}

variable "tables_privileges" {
  description = "List of tables privileges"
  type        = list(string)
  default     = []
}

variable "sequences_privileges" {
  description = "List of sequences privileges"
  type        = list(string)
  default     = []
}

variable "functions_privileges" {
  description = "List of sequences privileges"
  type        = list(string)
  default     = []
}

variable "roles" {
  description = "List of roles"
  type        = list(string)
  default     = []
}

variable "database_user_search_path" {
  description = "User search path"
  type        = string
  default     = null
}
