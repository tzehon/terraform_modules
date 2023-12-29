module "serverless_connector" {
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  version    = "~> 8.0"
  project_id = var.project_id
  vpc_connectors = [{
    name          = var.connector_name
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

# module "cloud_router" {
#   source  = "terraform-google-modules/cloud-router/google"
#   version = "~> 6.0"

#   name    = var.router_name
#   region  = var.region

#   bgp = {
#     # The ASN (16550, 64512 - 65534, 4200000000 - 4294967294) can be any private ASN
#     # not already used as a peer ASN in the same region and network or 16550 for Partner Interconnect.
#     asn = "65001"
#   }

#   project = var.project_id
#   network = "default"
# }

resource "google_compute_address" "ip_address" {
  name   = var.ip_name
  region = var.region
}

# module "cloud-nat" {
#   source        = "terraform-google-modules/cloud-nat/google"
#   version       = "~> 5.0"
#   project_id    = var.project_id
#   region        = var.region
#   router        = var.router_name
#   network       = "default"
#   create_router = true
#   nat_ips       = [google_compute_address.ip_address.name]
# }

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 5.0"
  project_id                         = var.project_id
  region                             = var.region
  router                             = var.router_name
  network                            = "default"
  create_router                      = true
  nat_ips                            = [google_compute_address.ip_address.self_link]
}
