# This code does not include creation of CloudTrail anf VPC flow logs. 
# Please include that as part of your production deployments

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