# radnomness providers
resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}

resource "random_password" "sqlpassword" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

