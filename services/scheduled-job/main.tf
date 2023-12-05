resource "google_project_service" "run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "scheduler_api" {
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secret_manager_api" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "secret" {
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
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret_value
}

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
    service_account = google_service_account.secret_accessor.email
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.run_api, google_secret_manager_secret_version.secret_id
  ]
}

resource "google_service_account" "default" {
  account_id   = var.scheduler_name
  description  = "Cloud Scheduler service account; used to trigger scheduled Cloud Run jobs."
  display_name = var.scheduler_name

  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_cloud_run_service_iam_member" "default" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.default.email}"
}

# Run every Sunday at 6am SGT
resource "google_cloud_scheduler_job" "default" {
  name             = var.scheduler_name
  region           = var.region
  description      = "Invoke a Cloud Run container on a schedule."
  schedule         = "0 6 * * SUN"
  time_zone        = "Asia/Singapore"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = google_cloud_run_v2_service.default.uri

    oidc_token {
      service_account_email = google_service_account.default.email
    }
  }

  depends_on = [
    google_project_service.scheduler_api
  ]
}
