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

resource "postgresql_grant" "revoke_public" {
  database    = var.database
  role        = "public"
  schema      = "public"
  object_type = "schema"
  privileges  = []
}

resource "postgresql_schema" "db_schema" {
  name     = var.database
  database = var.database
  owner    = postgresql_role.db_user.name
}

resource "postgresql_default_privileges" "user_tables_privileges" {
  role     = postgresql_role.db_user.name
  database = var.database
  schema   = postgresql_schema.db_schema.name

  object_type = "table"
  owner       = var.administrator_login
  privileges = coalescelist(var.tables_privileges, [
    "SELECT",
    "INSERT",
    "UPDATE",
    "DELETE",
    "TRUNCATE",
    "REFERENCES",
    "TRIGGER",
  ])
}

resource "postgresql_default_privileges" "user_sequences_privileges" {
  role     = postgresql_role.db_user.name
  database = var.database
  schema   = postgresql_schema.db_schema.name

  object_type = "sequence"
  owner       = var.administrator_login
  privileges = coalescelist(var.sequences_privileges, [
    "SELECT",
    "UPDATE",
    "USAGE",
  ])
}

resource "postgresql_default_privileges" "user_functions_privileges" {
  role     = postgresql_role.db_user.name
  database = var.database
  schema   = postgresql_schema.db_schema.name

  object_type = "function"
  owner       = var.administrator_login
  privileges = coalescelist(var.functions_privileges, [
    "EXECUTE",
  ])
}
