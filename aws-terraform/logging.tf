# CloudTrail enablement
resource "aws_cloudtrail" "cloudtrail" {
  name                          = "serverless-refarch-trail"
  s3_bucket_name                = aws_s3_bucket.logging_bucket.id
  s3_key_prefix                 = "cloudtrail"
  #For capturing events from services like IAM, include_global_service_events must be enabled
  include_global_service_events = true
  #Audit events must be logged for all AWS regions
  is_multi_region_trail = true
  #Encrypt logs created by CloudTrail
  kms_key_id = aws_kms_key.kms_key.arn
  #CloudTrail can log Data Events for certain services such as S3 objects and Lambda function invocations
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      #Log data events for all Lambda functions in the account
      values = ["arn:aws:lambda"]
    }
    data_resource {
      type   = "AWS::S3::Object"
      #Log data events for all S3 bucket in the account
      values = ["arn:aws:s3"]
    }
    data_resource {
      type   = "AWS::DynamoDB::Table"
      #Log data events for all DynamoDB tables in the account
      values = ["arn:aws:dynamodb"]
    }
  }
}

resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "serverless-refarch-logging-bucket"
  force_destroy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::tf-test-trail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::tf-test-trail/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

# Network Flow logs are enabled below for the VPC
resource "aws_flow_log" "flowlogs" {
  iam_role_arn    = aws_iam_role.flowlogs_role.arn
  log_destination = aws_cloudwatch_log_group.flowlogs_loggroup.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "flowlogs_loggroup" {
  name = "refarch-serverless-flowlogs_loggroup"
}

resource "aws_iam_role" "flowlogs_role" {
  name = "refarch-serverless-flowlogs_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flowlogs_policy" {
  name = "refarch-serverless-flowlogs_policy"
  role = aws_iam_role.example.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# S3 access logs are enabled as part of the bucket creation and stored in the same bucket

# Lambda logs are automaticaly created by AWS when Lambda is created
# The only requirement from AWS is the proper IAM permissions be assigned to Lambda for CloudWatch log creation

# Cloudwatch log group creation for API Gateway logs and related IAM role/policy
resource "aws_cloudwatch_log_group" "vuln_api_log_group" {
  name              = "cloudwatch_log_group_vuln_api"
  retention_in_days = 30
}

# Below IAM role is for API Gateway to be able to store logs in CloudWatch
resource "aws_iam_role" "cloudwatch" {
  name                 = "api_gateway_cloudwatch_serverless"
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "iam_role_refarch_cloudwatch"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_account" "cloudwatch" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn

  depends_on = [aws_kms_key.kms_key]
}