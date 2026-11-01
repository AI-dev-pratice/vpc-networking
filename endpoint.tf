# VPC Endpoints — private path from app-subnet pods to AWS regional APIs
# (S3, Secrets Manager, Bedrock, STS, ECR, SSM, KMS) so that traffic never
# leaves the VPC via NAT/IGW. See CLAUDE.md "Two separate access paths need
# two separate solutions" decision. RDS/DocumentDB need no endpoint — they're
# already VPC-resident and resolve via the VPC's default DNS.
# The Security Group these endpoints use (aws_security_group.vpc_endpoints)
# lives in security_groups.tf alongside the app/db tier Security Groups.

locals {
  app_subnet_ids = [
    for key, subnet in var.names[var.env].subnets : aws_subnet.main[key].id
    if subnet.tier == "app"
  ]
}

# S3 — Gateway Endpoint (free, route-table based). Covers every bucket,
# current and future, with no extra resource needed per bucket.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = merge(var.tags, { Name = "labs-shared-services-s3-endpoint", Environment = var.env })
}

# Interface Endpoints — one per regional API service, covers every resource
# of that service (every secret, every model, every repo/image) with no
# extra resource per resource. private_dns_enabled overrides the service's
# standard public hostname to resolve to this endpoint's ENI inside the VPC —
# no SDK/code changes needed on the pod side.
resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.interface_endpoint_services)

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.app_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = merge(var.tags, {
    Name        = "labs-shared-services-${replace(each.value, ".", "-")}-endpoint"
    Environment = var.env
  })
}
