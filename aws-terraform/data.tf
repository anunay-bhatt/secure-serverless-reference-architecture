data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

#Fetching route tables, needed for VPC endpoint association
#data "aws_route_table" "routes_for_endpoint" {
#  for_each = data.aws_subnet_ids.subnets_ids.ids
#  subnet_id = each.value
#}