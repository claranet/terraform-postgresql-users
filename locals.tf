locals {
  user = coalesce(var.user, format("%s_user", var.database))
}
