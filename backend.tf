terraform {
  backend "s3" {
    bucket         = local.selected_backend.bucket
    key            = local.selected_backend.key
    region         = local.selected_backend.region
    dynamodb_table = local.selected_backend.dynamodb_table
    encrypt        = true
  }
}