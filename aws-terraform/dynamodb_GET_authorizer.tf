resource "aws_dynamodb_table" "dynamodb_get_authorizer" {
  name           = "vuln_get_authorizer_table"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Client"

  attribute {
    name = "Client"
    type = "S"
  }

  server_side_encryption {  
    enabled = "true"
    kms_key_arn = aws_kms_key.kms_key.arn
  }

}

resource "aws_dynamodb_table_item" "dynamodb_get_authorizer_item" {
  count = length(var.OU_with_GET_authorization)

  table_name = aws_dynamodb_table.dynamodb_get_authorizer.name
  hash_key   = aws_dynamodb_table.dynamodb_get_authorizer.hash_key

  item = <<ITEM
  {
    "Client": { "S": "${var.OU_with_GET_authorization[count.index].client_OU}" },
    "Org": {"SS": ${jsonencode(var.OU_with_GET_authorization[count.index].org)}}
  }
  ITEM

}