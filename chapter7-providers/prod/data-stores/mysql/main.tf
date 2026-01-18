module "mysql_primary" {
  source = "../../modules/data-stores/mysql"
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  backup_retention_period = 1
  replicate_source_db     = true
}