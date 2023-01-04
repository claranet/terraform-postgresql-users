module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "logs" {
  source  = "claranet/run-common/azurerm//modules/logs"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
}

module "db_pg_flex" {
  source  = "claranet/db-postgresql-flexible/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  tier               = "GeneralPurpose"
  size               = "D2s_v3"
  storage_mb         = 32768
  postgresql_version = 13

  allowed_cidrs = {
    "1" = "1.2.3.4/29"
    "2" = "12.34.56.78/32"
  }

  backup_retention_days        = 14
  geo_redundant_backup_enabled = true

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  databases_names     = ["mydatabase"]
  databases_collation = { mydatabase = "en_US.UTF8" }
  databases_charset   = { mydatabase = "UTF8" }

  maintenance_window = {
    day_of_week  = 3
    start_hour   = 3
    start_minute = 0
  }

  logs_destinations_ids = [
    module.logs.logs_storage_account_id,
    module.logs.log_analytics_workspace_id
  ]

  extra_tags = {
    foo = "bar"
  }
}

provider "postgresql" {
  host      = module.db_pg_flex.postgresql_flexible_fqdn
  port      = 5432
  username  = module.db_pg_flex.postgresql_flexible_administrator_login
  password  = var.administrator_password
  sslmode   = "require"
  superuser = false
}

module "postgresql_users" {
  # source  = "claranet/users/postgresql"
  # version = "x.x.x"
  source = "git::ssh://git@git.fr.clara.net/claranet/projects/cloud/azure/terraform/postgresql-users.git?ref=AZ-930_postgresql_users_module"

  for_each = toset(module.db_pg_flex.postgresql_flexible_databases_names)

  user     = each.key
  database = each.key
}

module "postgresql_configuration" {
  # source  = "claranet/hardening/postgresql"
  # version = "x.x.x"
  source = "git::ssh://git@git.fr.clara.net/claranet/projects/cloud/azure/terraform/postgresql-hardening.git?ref=AZ-930_postgresql_hard"

  for_each = toset(module.db_pg_flex.postgresql_flexible_databases_names)

  administrator_login = module.db_pg_flex.postgresql_flexible_administrator_login

  user        = module.postgresql_users[each.key].user
  database    = each.key
  schema_name = each.key
}
