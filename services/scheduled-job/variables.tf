variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "service_name" {
  description = "The Cloud Run service name"
  type        = string
}

variable "scheduler_name" {
  description = "The Cloud Scheduler service name"
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

variable "access_key_id" {
  description = "The URA access key secret ID"
  type        = string
}

variable "access_key_value" {
  description = "The URA access key secret value"
  type        = string
}

variable "atlas_user_id" {
  description = "The Atlas user secret ID"
  type        = string
}

variable "atlas_user_value" {
  description = "The Atlas user secret value"
  type        = string
}

variable "atlas_password_id" {
  description = "The Atlas password secret ID"
  type        = string
}

variable "atlas_password_value" {
  description = "The Atlas password secret value"
  type        = string
}

variable "atlas_connection_string_id" {
  description = "The Atlas connection string ID"
  type        = string
}

variable "atlas_connection_string_value" {
  description = "The Atlas connection string value"
  type        = string
}