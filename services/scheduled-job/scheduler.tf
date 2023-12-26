resource "google_service_account" "default" {
  account_id   = var.scheduler_name
  description  = "Cloud Scheduler service account; used to trigger scheduled Cloud Run jobs."
  display_name = var.scheduler_name

  depends_on = [
    google_project_service.iam_api
  ]
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
