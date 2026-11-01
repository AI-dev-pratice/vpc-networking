bucket         = "prodtfstate-<account-id>-ap-south-1-an"
key            = "tfstate/vpc-networking.tfstate"
region         = "ap-south-1"
dynamodb_table = "test-tfstate-lock"
encrypt        = true