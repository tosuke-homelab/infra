# IAM関連の権限
# IAM 操作権限
resource "google_project_iam_member" "plan_sa_iam_reviewer" {
  project = local.project_id
  role    = "roles/iam.securityReviewer"
  member  = "serviceAccount:${google_service_account.gha_terraform_plan.email}"
}

resource "google_project_iam_member" "apply_sa_iam_admin" {
  project = local.project_id
  role    = "roles/iam.securityAdmin"
  member  = "serviceAccount:${google_service_account.gha_terraform_apply.email}"
}

## Workload Identity Pool関連の権限
resource "google_project_iam_member" "plan_sa_workload_identity_pool_viewer" {
  project = local.project_id
  role    = "roles/iam.workloadIdentityPoolViewer"
  member  = "serviceAccount:${google_service_account.gha_terraform_plan.email}"
}

resource "google_project_iam_member" "apply_sa_workload_identity_pool_admin" {
  project = local.project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.gha_terraform_apply.email}"
}

## サービスアカウント関連の権限
resource "google_project_iam_member" "plan_sa_service_account_viewer" {
  project = local.project_id
  role    = "roles/iam.serviceAccountViewer"
  member  = "serviceAccount:${google_service_account.gha_terraform_plan.email}"
}

resource "google_project_iam_member" "apply_sa_service_account_admin" {
  project = local.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.gha_terraform_apply.email}"
}

# ストレージ関連の権限
resource "google_project_iam_member" "plan_sa_storage_bucket_viewer" {
  project = local.project_id
  role    = "roles/storage.bucketViewer"
  member  = "serviceAccount:${google_service_account.gha_terraform_plan.email}"
}

resource "google_project_iam_member" "apply_sa_storage_admin" {
  project = local.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.gha_terraform_apply.email}"
}
