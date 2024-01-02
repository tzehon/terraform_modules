resource "google_secret_manager_secret" "access_key_id" {
  secret_id = var.access_key_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "access_key_value" {
  secret      = google_secret_manager_secret.access_key_id.id
  secret_data = var.access_key_value
}

resource "google_secret_manager_secret" "atlas_user_id" {
  secret_id = var.atlas_user_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "atlas_user_value" {
  secret      = google_secret_manager_secret.atlas_user_id.id
  secret_data = var.atlas_user_value
}

resource "google_secret_manager_secret" "atlas_password_id" {
  secret_id = var.atlas_password_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "atlas_password_value" {
  secret      = google_secret_manager_secret.atlas_password_id.id
  secret_data = var.atlas_password_value
}

resource "google_secret_manager_secret" "atlas_connection_string_id" {
  secret_id = var.atlas_connection_string_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "atlas_connection_string_value" {
  secret      = google_secret_manager_secret.atlas_connection_string_id.id
  secret_data = var.atlas_connection_string_value
}