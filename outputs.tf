output "user" {
  description = "User"
  value       = postgresql_role.db_user.name
}

output "password" {
  description = "Password"
  value       = coalesce(var.password, random_password.db_password.result)
  sensitive   = true
}

output "database" {
  description = "Database name"
  value       = var.database
}
