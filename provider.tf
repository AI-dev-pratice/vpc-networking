# Credentials come from the GitHub OIDC role the pipeline assumes
# (aws-actions/configure-aws-credentials) — see CLAUDE.md
# "CI/CD credentials: OIDC only, no static AWS keys". The provider block only
# needs a region.
provider "aws" {
  region = var.names[var.env].region
}