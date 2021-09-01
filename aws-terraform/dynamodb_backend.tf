resource "aws_dynamodb_table" "dynamodb_backend" {
  name           = "vuln_table"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "VulnID"

  attribute {
    name = "VulnID"
    type = "S"
  }

  attribute {
    name = "Org"
    type = "S"
  }

  global_secondary_index {
    name               = "OrgIndex"
    hash_key           = "Org"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "ALL"
  }

  server_side_encryption {  
    enabled = "true"
    kms_key_arn = aws_kms_key.kms_key.arn
  }

}

#Adding demo data into this database at creation time

resource "random_uuid" "test1" {
}

resource "aws_dynamodb_table_item" "dynamodb_backend_item1" {
  table_name = aws_dynamodb_table.dynamodb_backend.name
  hash_key   = aws_dynamodb_table.dynamodb_backend.hash_key

  item = <<ITEM
  {
    "VulnID": {"S": "${random_uuid.test1.result}"},
    "Org": {"S": "org1"},
    "Priority": {"S": "P2"},
    "AssetName": {"S": "lax3-org-g.internal.org.com"},
    "PluginId": {"N": "15446"},
    "PluginName": {"S": "Cisco ADE-OS Local File Inclusion (cisco-sa-ade-xcvAQEOZ)"},
    "DueDate": {"S": "05-06-2022"}
  }
  ITEM

}

resource "random_uuid" "test2" {
}

resource "aws_dynamodb_table_item" "dynamodb_backend_item2" {
  table_name = aws_dynamodb_table.dynamodb_backend.name
  hash_key   = aws_dynamodb_table.dynamodb_backend.hash_key

  item = <<ITEM
  {
    "VulnID": {"S": "${random_uuid.test2.result}"},
    "Org": {"S": "org2"},
    "Priority": {"S": "P2"},
    "AssetName": {"S": "lax2-org2-g.internal.org.com"},
    "PluginId": {"N": "13452"},
    "PluginName": {"S": "Cisco ADE-OS Local File Inclusion (cisco-sa-ade-xcvAQEOZ)"},
    "DueDate": {"S": "05-06-2022"}
  }
  ITEM

}

resource "random_uuid" "test3" {
}

resource "aws_dynamodb_table_item" "dynamodb_backend_item3" {
  table_name = aws_dynamodb_table.dynamodb_backend.name
  hash_key   = aws_dynamodb_table.dynamodb_backend.hash_key

  item = <<ITEM
  {
    "VulnID": {"S": "${random_uuid.test3.result}"},
    "Org": {"S": "org3"},
    "Priority": {"S": "P2"},
    "AssetName": {"S": "lax2-org2-g.internal.org.com"},
    "PluginId": {"N": "13452"},
    "PluginName": {"S": "Cisco ADE-OS Local File Inclusion (cisco-sa-ade-xcvAQEOZ)"},
    "DueDate": {"S": "05-06-2022"}
  }
  ITEM

}

resource "random_uuid" "test4" {
}

resource "aws_dynamodb_table_item" "dynamodb_backend_item4" {
  table_name = aws_dynamodb_table.dynamodb_backend.name
  hash_key   = aws_dynamodb_table.dynamodb_backend.hash_key

  item = <<ITEM
  {
    "VulnID": {"S": "${random_uuid.test4.result}"},
    "Org": {"S": "org4"},
    "Priority": {"S": "P2"},
    "AssetName": {"S": "lax2-org2-g.internal.org.com"},
    "PluginId": {"N": "13452"},
    "PluginName": {"S": "Cisco ADE-OS Local File Inclusion (cisco-sa-ade-xcvAQEOZ)"},
    "DueDate": {"S": "05-06-2022"}
  }
  ITEM

}

resource "random_uuid" "test5" {
}

resource "aws_dynamodb_table_item" "dynamodb_backend_item5" {
  table_name = aws_dynamodb_table.dynamodb_backend.name
  hash_key   = aws_dynamodb_table.dynamodb_backend.hash_key

  item = <<ITEM
  {
    "VulnID": {"S": "${random_uuid.test5.result}"},
    "Org": {"S": "org5"},
    "Priority": {"S": "P2"},
    "AssetName": {"S": "lax2-org2-g.internal.org.com"},
    "PluginId": {"N": "13452"},
    "PluginName": {"S": "Cisco ADE-OS Local File Inclusion (cisco-sa-ade-xcvAQEOZ)"},
    "DueDate": {"S": "05-06-2022"}
  }
  ITEM

}

resource "random_uuid" "test6" {
}

resource "aws_dynamodb_table_item" "dynamodb_backend_item6" {
  table_name = aws_dynamodb_table.dynamodb_backend.name
  hash_key   = aws_dynamodb_table.dynamodb_backend.hash_key

  item = <<ITEM
  {
    "VulnID": {"S": "${random_uuid.test6.result}"},
    "Org": {"S": "org6"},
    "Priority": {"S": "P2"},
    "AssetName": {"S": "lax2-org2-g.internal.org.com"},
    "PluginId": {"N": "13452"},
    "PluginName": {"S": "Cisco ADE-OS Local File Inclusion (cisco-sa-ade-xcvAQEOZ)"},
    "DueDate": {"S": "05-06-2022"}
  }
  ITEM

}