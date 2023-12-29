resource "google_service_account" "secret_accessor" {
  account_id   = var.service_name
  display_name = "Service account for Cloud Run"
}

resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  secret_id = google_secret_manager_secret.secret.id
  role      = "roles/secretmanager.secretAccessor"
  # Grant the new deployed service account access to this secret.
  member     = "serviceAccount:${google_service_account.secret_accessor.email}"
  depends_on = [google_secret_manager_secret.secret]
}

resource "google_cloud_run_v2_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    containers {
      image = var.url
      env {
        name = "ACCESS_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secret.secret_id
            version = "latest"
          }
        }
      }
    }
    vpc_access {
      # connector = module.serverless_connector.default.id
      connector = tolist(module.serverless_connector.connector_ids)[0]
      egress    = "ALL_TRAFFIC"
    }
    service_account = google_service_account.secret_accessor.email
  }
  ingress = "INGRESS_TRAFFIC_ALL"
  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.run_api, google_secret_manager_secret_version.secret_id
  ]
}

resource "google_cloud_run_service_iam_member" "default" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.default.email}"
}