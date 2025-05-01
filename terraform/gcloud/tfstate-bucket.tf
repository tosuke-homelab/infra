data "google_storage_bucket" "tf_backend" {
  name = "tosuke-homelab-tfstate"
}

resource "google_storage_bucket_iam_member" "tf_backend_plan_sa_object_viewer" {
  bucket = data.google_storage_bucket.tf_backend.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gha_terraform_plan.email}"
}

resource "google_storage_bucket_iam_member" "tf_backend_apply_sa_object_admin" {
  bucket = data.google_storage_bucket.tf_backend.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.gha_terraform_apply.email}"
}
