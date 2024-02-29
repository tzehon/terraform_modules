resource "google_service_account" "secret_accessor" {
  account_id   = var.service_name
  display_name = "Service account for Cloud Run"
}

resource "google_secret_manager_secret_iam_member" "access_key_id_accessor" {
  secret_id = google_secret_manager_secret.access_key_id.id
  role      = "roles/secretmanager.secretAccessor"
  # Grant the new deployed service account access to this secret.
  member     = "serviceAccount:${google_service_account.secret_accessor.email}"
  depends_on = [google_secret_manager_secret.access_key_id]
}

resource "google_secret_manager_secret_iam_member" "atlas_user_id_accessor" {
  secret_id = google_secret_manager_secret.atlas_user_id.id
  role      = "roles/secretmanager.secretAccessor"
  # Grant the new deployed service account access to this secret.
  member     = "serviceAccount:${google_service_account.secret_accessor.email}"
  depends_on = [google_secret_manager_secret.atlas_user_id]
}

resource "google_secret_manager_secret_iam_member" "atlas_password_id_accessor" {
  secret_id = google_secret_manager_secret.atlas_password_id.id
  role      = "roles/secretmanager.secretAccessor"
  # Grant the new deployed service account access to this secret.
  member     = "serviceAccount:${google_service_account.secret_accessor.email}"
  depends_on = [google_secret_manager_secret.atlas_password_id]
}

resource "google_secret_manager_secret_iam_member" "atlas_connection_string_id" {
  secret_id = google_secret_manager_secret.atlas_connection_string_id.id
  role      = "roles/secretmanager.secretAccessor"
  # Grant the new deployed service account access to this secret.
  member     = "serviceAccount:${google_service_account.secret_accessor.email}"
  depends_on = [google_secret_manager_secret.atlas_connection_string_id]
}

resource "time_rotating" "current_time" {
  rotation_rfc3339 = timestamp()
  lifecycle {
    create_before_destroy = true
  }
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
            secret  = google_secret_manager_secret.access_key_id.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "ATLAS_USER"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.atlas_user_id.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "ATLAS_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.atlas_password_id.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "ATLAS_CONNECTION_STRING"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.atlas_connection_string_id.secret_id
            version = "latest"
          }
        }
      }
      env {
          name  = "REDEPLOY_TIMESTAMP"
          value = time_rotating.current_time.rotation_rfc3339
        }
    }
    service_account = google_service_account.secret_accessor.email
  }
  ingress = "INGRESS_TRAFFIC_ALL"
  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.run_api,
    google_secret_manager_secret_version.access_key_value,
    google_secret_manager_secret_version.atlas_user_value,
    google_secret_manager_secret_version.atlas_password_value,
    google_secret_manager_secret_version.atlas_connection_string_value
  ]
}

resource "google_cloud_run_service_iam_member" "default" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.default.email}"
}