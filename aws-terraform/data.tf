data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_subnet_ids" "subnets_ids" {
  vpc_id = "vpc-0ecadacbe91e42196"

  tags = {
    SFDCSecurityGroup = "Restricted"
  }
}

data "aws_subnet" "subnets_for_lambda" {
  for_each = data.aws_subnet_ids.subnets_ids.ids
  id       = each.value
}

data "aws_security_group" "sg_for_lambda" {
  tags = {
    internal = "true"
  }
}

#Fetching route tables, needed for VPC endpoint association
data "aws_route_table" "routes_for_endpoint" {
  for_each = data.aws_subnet_ids.subnets_ids.ids
  subnet_id = each.value
}