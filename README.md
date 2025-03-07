# PostgreSQL users module
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/users/postgresql/)

Terraform module using `PostgreSQL` provider to create users and manage their roles on an existing database.
This module will be used combined with others PostgreSQL modules (like [`azure-db-postgresql-flexible`](https://registry.terraform.io/modules/claranet/db-postgresql-flexible/azurerm/) or [`postgresql-database-configuration`](https://registry.terraform.io/modules/claranet/database-configuration/postgresql/) for example).


<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | OpenTofu version | AzureRM version |
| -------------- | ----------------- | ---------------- | --------------- |
| >= 8.x.x       | **Unverified**    | 1.8.x            | >= 4.0          |
| >= 7.x.x       | 1.3.x             |                  | >= 3.0          |
| >= 6.x.x       | 1.x               |                  | >= 3.0          |
| >= 5.x.x       | 0.15.x            |                  | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   |                  | >= 2.0          |
| >= 3.x.x       | 0.12.x            |                  | >= 2.0          |
| >= 2.x.x       | 0.12.x            |                  | < 2.0           |
| <  2.x.x       | 0.11.x            |                  | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

⚠️ Since modules version v8.0.0, we do not maintain/check anymore the compatibility with
[Hashicorp Terraform](https://github.com/hashicorp/terraform/). Instead, we recommend to use [OpenTofu](https://github.com/opentofu/opentofu/).

```hcl
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

module "db_pg_flex" {
  source  = "claranet/db-postgresql-flexible/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  allowed_cidrs = {}

  databases = {
    mydatabase = {
      collation = "en_US.utf8"
      charset   = "UTF8"
    }
  }


  logs_destinations_ids = []
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
  source  = "claranet/users/postgresql"
  version = "x.x.x"

  for_each = toset(module.db_pg_flex.postgresql_flexible_databases_names)

  administrator_login = module.db_pg_flex.postgresql_flexible_administrator_login

  user     = each.key
  database = each.key
}

module "postgresql_configuration" {
  source  = "claranet/database-configuration/postgresql"
  version = "x.x.x"

  for_each = toset(module.db_pg_flex.postgresql_flexible_databases_names)

  administrator_login = module.db_pg_flex.postgresql_flexible_administrator_login

  database_admin_user = module.postgresql_users[each.key].user
  database            = each.key
  schema_name         = each.key
}
```

## Providers

| Name | Version |
|------|---------|
| postgresql | >= 1.14 |
| random | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [postgresql_grant_role.db_user](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant_role) | resource |
| [postgresql_role.db_user](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| administrator\_login | Server administrator user name, used to allow it on the created roles. | `string` | n/a | yes |
| database | Database in which create the user. | `string` | n/a | yes |
| password | User password, generated if not set. | `string` | `null` | no |
| roles | User database roles list. | `list(string)` | `[]` | no |
| user | Name of the user to create. Defaults to `<database>_user` if not set. | `string` | `null` | no |
| user\_search\_path | User search path. | `string` | `null` | no |
| with\_admin\_option | Giving ability to grant membership to others or not for the role. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| database | Database name |
| password | Password |
| user | User |
<!-- END_TF_DOCS -->
