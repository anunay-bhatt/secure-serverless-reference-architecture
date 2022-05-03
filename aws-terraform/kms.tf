#Secure KMS key to be used for encryption of DynamoDB data, Lamabda environment variables, S3 objects. 

resource "aws_kms_key" "kms_key" {
  description              = "KMS key for encryption of resources for refarch serverless app"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  is_enabled               = "true"
  enable_key_rotation      = "true"
  policy                   = data.aws_iam_policy_document.secure_policy.json
}

resource "aws_kms_alias" "kms_key_alias" {
  name          = "alias/serverless_api_key_alias"
  target_key_id = aws_kms_key.kms_key.key_id
}

data "aws_iam_policy_document" "secure_policy" {
  statement {
    sid    = "DisallowRootAccess"
    effect = "Allow"
    not_actions = [
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Delete*",
      "kms:ImportKeyMaterial",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
  statement {
    sid    = "AllowAccessToKeyAdmins"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = concat(var.key_admins,[data.aws_caller_identity.current.arn])
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowAccessToCloudtrail"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"

      values = [
        "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/serverless-refarch-trail"
      ]
    }
  }

}