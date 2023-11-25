variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "service_name" {
  description = "The Cloud Run service name"
  type        = string
}

variable "region" {
  description = "The preferred GCP region"
  type        = string
}

variable "url" {
  description = "The url to the image"
  type        = string
}