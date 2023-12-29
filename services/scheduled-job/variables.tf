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

variable "secret_id" {
  description = "The secret id"
  type        = string
}

variable "secret_value" {
  description = "The secret value"
  type        = string
}

variable "connector_name" {
  description = "The serverless VPC connector name"
  type        = string
}

variable "cidr_range" {
  description = "The CIDR range"
  type        = string
}

variable "ip_name" {
  description = "The IP address name"
  type        = string
}

variable "router_name" {
  description = "The Cloud Router Name"
  type        = string
}