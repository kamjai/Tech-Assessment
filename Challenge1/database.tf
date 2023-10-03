module "cloudsql" {
  source             = "git::https://github.com/terraform-google-modules/terraform-google-sql-db.git//modules/mysql?ref=v9.0.0"
  project_id         = var.project_id
  name               = var.cloudsql_instance_name
  database_version   = var.database_version
  region             = var.region
  tier               = var.cloudsql_machine_type
  zone               = var.zone
  disk_size          = var.cloudsql_disk_size  
}
