# Security Groups — tier-level access control on top of subnet routing.
# Subnets only decide WHERE a resource sits; these decide WHO can talk to it.

# ── App tier — EKS nodes/pods ──────────────────────────────────────────────
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "EKS nodes/pods in the app subnet"
  vpc_id      = aws_vpc.main.id

  # Pod-to-pod / node-to-node traffic within the app tier (EKS CNI, service mesh, etc.)
  ingress {
    description = "All traffic from other app-tier members"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "All outbound (NAT/IGW, VPC Endpoints, RDS, etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "app-sg", Environment = var.env })
}

# ── DB tier — RDS / DocumentDB ──────────────────────────────────────────────
# Inbound only from the app tier, on each managed database's port. No egress
# rules — a database has no business initiating outbound connections.
resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "RDS / DocumentDB in the db subnet - inbound only from the app tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from app tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    description     = "MySQL from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    description     = "DocumentDB (MongoDB-compatible) from app tier"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = merge(var.tags, { Name = "db-sg", Environment = var.env })
}

# ── VPC Endpoints tier — Interface Endpoints (Secrets Manager, Bedrock, ECR) ─
# Moved here from endpoint.tf now that the app-tier SG exists — narrowed from
# "whole VPC CIDR" to just the app tier.
resource "aws_security_group" "vpc_endpoints" {
  name        = "vpce-sg"
  description = "Allow HTTPS from the app tier to Interface VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTPS from app tier"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "vpce-sg", Environment = var.env })
}
