resource "random_password" "db_password" {
  count = var.password == null ? 1 : 0

  special = "false"
  length  = 32
}

resource "postgresql_role" "db_user" {
  name        = coalesce(var.user, format("%s_user", var.database))
  login       = true
  password    = coalesce(var.password, one(random_password.db_password[*].result))
  create_role = true
  roles       = var.roles
  search_path = compact([var.database, "$user", var.user_search_path])
}
