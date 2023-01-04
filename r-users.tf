resource "random_password" "db_password" {
  special = "false"
  length  = 32
}

resource "postgresql_role" "db_user" {
  name        = coalesce(var.user, format("%s_user", var.database))
  login       = true
  password    = coalesce(var.password, random_password.db_password.result)
  create_role = true
  roles       = var.roles
  search_path = compact([var.database, "$user", var.database_user_search_path])
}
