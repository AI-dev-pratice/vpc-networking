# Only used to build VPC-endpoint service names (com.amazonaws.<region>.<service>)
# without hardcoding region a second time anywhere outside locals.cfg.
data "aws_region" "current" {}

# create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.names[var.env].vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { "Name" = "LABS-SHARED-SERVICES", "Environment" = var.env })
}


resource "aws_subnet" "main" {
  for_each                = var.names[var.env].subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.tier == "pub" ? true : false

  tags = merge(var.tags, {
    Name        = "labs-shared-services-${each.key}"
    Environment = var.env
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "labs-shared-services-igw", Environment = var.env })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, { Name = "labs-shared-services-public-rt", Environment = var.env })
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "labs-shared-services-nat-eip", Environment = var.env })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main["pub-a"].id
  tags          = merge(var.tags, { Name = "labs-shared-services-nat", Environment = var.env })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(var.tags, { Name = "labs-shared-services-private-rt", Environment = var.env })
}

resource "aws_route_table_association" "main" {
  for_each = var.names[var.env].subnets

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = each.value.tier == "pub" ? aws_route_table.public.id : aws_route_table.private.id
}
