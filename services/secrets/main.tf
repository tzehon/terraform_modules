resource "google_project_service" "secret_manager_api" {
  service = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "secret_id" {
  secret_id = var.secret_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_id" {
  secret      = google_secret_manager_secret.secret_id.id
  secret_data = var.secret_value
}