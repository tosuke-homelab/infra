terraform {
  backend "gcs" {
    bucket = "tosuke-homelab-tfstate"
    prefix = "gcloud"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = "tosuke-dev"
  region  = "asia-northeast1"
}
