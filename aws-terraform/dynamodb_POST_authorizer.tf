resource "aws_dynamodb_table" "dynamodb_post_authorizer" {
  name           = "vuln_post_authorizer_table"
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
    
resource "aws_dynamodb_table_item" "dynamodb_post_authorizer_item1" {
  count = length(var.OU_with_POST_authorization)

  table_name = aws_dynamodb_table.dynamodb_post_authorizer.name
  hash_key   = aws_dynamodb_table.dynamodb_post_authorizer.hash_key

  item = <<ITEM
  {
    "Client": {"S": "${var.OU_with_POST_authorization[count.index]}"}
  }
  ITEM

}