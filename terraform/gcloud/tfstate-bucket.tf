data "google_storage_bucket" "tf_backend" {
  name = "tosuke-homelab-tfstate"
}

resource "google_storage_bucket_iam_member" "tf_backend_plan_sa_object_user" {
  bucket = data.google_storage_bucket.tf_backend.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.gha_terraform_plan.email}"
}
