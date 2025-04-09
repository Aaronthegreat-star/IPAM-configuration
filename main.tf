locals {
  cidr_blocks = ["fd00::/56", "fd00:1::/56"]
  subnets     = ["fd00:0:0:1::/64", "fd00:0:1:1::/64"]
  locale = var.region
}

data "aws_region" "current" {
    name = var.region
}

resource "aws_vpc_ipam" "ipam" {
  description = "IPAM IPv6"
  operating_regions {
    region_name = local.locale
  }

  tags = {
    Name = "IPAM IPv6"
  }
}

resource "aws_vpc_ipam_pool" "private" {
  address_family = "ipv6"
  locale         = local.locale
  ipam_scope_id  = aws_vpc_ipam.ipam.private_default_scope_id
}

resource "aws_vpc_ipam_pool_cidr" "cidr" {
  ipam_pool_id = aws_vpc_ipam_pool.private.id
  cidr = "fd00::/48"
  # netmask_length = 48
  /* define the IPv6 cidr block and the IPAM pool if
  */
}

resource "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"
  # define the IPv4 cidr block for the default VPC
}

resource "aws_vpc_ipv6_cidr_block_association" "ipv6_assoc" {
  count             = 2
  ipv6_ipam_pool_id = aws_vpc_ipam_pool.private.id
  ipv6_cidr_block   = local.cidr_blocks[count.index]
  vpc_id            = aws_vpc.vpc.id
  depends_on        = [aws_vpc_ipam_pool_cidr.cidr]
}

data "aws_availability_zones" "azs" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]  # exclude local zones
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = 2
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index) 
  ipv6_cidr_block   = local.subnets[count.index]

}