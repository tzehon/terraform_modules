module "serverless_connector" {
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  version    = "~> 8.0"
  project_id = var.project_id
  vpc_connectors = [{
    name          = "serverless-vpc-connector"
    region        = var.region
    network       = "default"
    subnet_name   = null
    ip_cidr_range = var.cidr_range
    machine_type  = "e2-micro"
    min_instances = 2
    max_instances = 3
    }
  ]
  depends_on = [
    google_project_service.vpcaccess_api
  ]
}