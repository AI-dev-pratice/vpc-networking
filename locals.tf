locals {
  backend_config = {
    dev = {
      bucket         = "devtfstate-733717814172-ap-south-1-an"
      key            = "tfstate/vpc-networking.tfstate"
      region         = "ap-south-1"
      dynamodb_table = "test-tfstate-lock"
    }
    prod = {
      bucket         = "prodtfstate"
      key            = "tfstate/vpc-networking.tfstate"
      region         = "ap-south-1"
      dynamodb_table = "test-tfstate-lock"
    }
  }
  selected_backend = local.backend_config[var.env]
}