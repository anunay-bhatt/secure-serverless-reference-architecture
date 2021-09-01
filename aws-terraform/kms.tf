#Secure KMS key to be used for encryption of DynamoDB data, Lamabda environment variables, S3 objects, etc. 

resource "aws_kms_key" "kms_key" {
  description              = "KMS key for encryption of resources for refarch serverless app"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  is_enabled               = "true"
  enable_key_rotation      = "true"
}

resource "aws_kms_alias" "kms_key_alias" {
  name          = "alias/vuln_api_key_alias"
  target_key_id = aws_kms_key.kms_key.key_id
}