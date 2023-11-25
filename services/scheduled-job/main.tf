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

resource "google_cloud_run_v2_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    containers {
      image = var.url
    }
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.run_api
  ]
}

resource "google_service_account" "default" {
  account_id   = "scheduler-sa"
  description  = "Cloud Scheduler service account; used to trigger scheduled Cloud Run jobs."
  display_name = "scheduler-sa"

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
  name             = "scheduled-cloud-run-job"
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