output "cloud_run_url" {
    value = google_cloud_run_v2_service.default.uri
    description = "Cloud Run URL"
}

output "external_ip_address" {
  value = google_compute_address.ip_address.address
  description = "The external IP address for Cloud Run"
}