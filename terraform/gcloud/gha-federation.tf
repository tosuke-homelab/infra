locals {
  github_pool_name = google_iam_workload_identity_pool.github.name
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Pool"
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.job_workflow_ref" = "assertion.job_workflow_ref"
  }
  attribute_condition = "assertion.repository.startsWith('tosuke-homelab/')"
}

resource "google_service_account" "gha_terraform_plan" {
  account_id   = "gha-terraform-plan"
  display_name = "GitHub Actions that runs terraform plan"
}

resource "google_service_account_iam_member" "gha_terraform_plan_infra_repo" {
  service_account_id = google_service_account.gha_terraform_plan.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${local.github_pool_name}/attribute.repository/tosuke-homelab/infra"
}

resource "google_service_account" "gha_terraform_apply" {
  account_id   = "gha-terraform-apply"
  display_name = "GitHub Actions that runs terraform apply"
}

resource "google_service_account_iam_member" "gha_terraform_apply_infra_repo" {
  service_account_id = google_service_account.gha_terraform_apply.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${local.github_pool_name}/attribute.repository/tosuke-homelab/infra"
}
