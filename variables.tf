variable "tags" {
  type        = map(string)
  description = <<-EOF
  Map of tags to apply to each resource.
  EOF
  default = {
    "terraform" : "aws-shared-services"
    "Client" : "Internal"
    "BU" : "Corporate"
    "Owner" : "test"
    "App" : "aws-shared-services"
    "accelerator" : "aws-shared-services"
    "Account" : "new"
  }
}

variable "env" {
  type        = string
  description = "Environment to deploy to - dev or prod"
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "Environment must be one of 'dev' or 'prod'"
  }
}

variable "names" {
  type = map(object({
    region   = string
    vpc_cidr = string
    subnets = map(object({
      cidr = string
      az   = string
      tier = string
    }))
  }))
  description = "Names and network config for dev/prod - because of legacy they're slightly different."
}

# variable "azure_vpn_gateway_public_ip" {
#   type        = string
#   description = "Public IP of the Azure Hub VPN Gateway (customer gateway side)"
#   default     = "0.0.0.0" # Replace with the actual public IP of the Azure Hub VPN Gateway
# }

# variable "azure_bgp_asn" {
#   type        = number
#   description = "BGP ASN used on the Azure side (AWS requires this even for static routing)"
#   default     = 65000
# }

# variable "azure_hub_cidr" {
#   type        = string
#   description = "CIDR block of the Azure Hub VNet that needs to reach AWS private subnets"
#   default     = "172.17.80.0/16" # Replace with the actual CIDR block of the Azure Hub VNet
# }

variable "interface_endpoint_services" {
  type        = list(string)
  description = "AWS service names to create Interface VPC Endpoints for, one per entry regardless of how many resources (secrets, models, repos) that service holds. ECR needs both 'ecr.api' and 'ecr.dkr'."
  default     = ["secretsmanager", "bedrock-runtime", "ecr.api", "ecr.dkr"]
}
