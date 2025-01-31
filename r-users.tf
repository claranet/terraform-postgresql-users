resource "random_password" "db_password" {
  count = var.password == null ? 1 : 0

  special = "false"
  length  = 32
}

resource "postgresql_role" "db_user" {
  name        = local.user
  login       = true
  password    = coalesce(var.password, one(random_password.db_password[*].result))
  create_role = true
  roles       = var.roles
  search_path = compact([var.database, "$user", var.user_search_path])
}

# Grant the newly created role to the administrator
resource "postgresql_grant_role" "db_user" {
  role       = var.administrator_login
  grant_role = local.user
}
