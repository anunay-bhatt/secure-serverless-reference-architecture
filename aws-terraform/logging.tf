# Cloudwatch log group creation for API Gateway logs and related IAM role/policy

resource "aws_cloudwatch_log_group" "vuln_api_log_group" {
  name              = "cloudwatch_log_group_vuln_api"
  retention_in_days = 30
}

resource "aws_iam_role" "cloudwatch" {
  name                 = "api_gateway_cloudwatch_global_refarch_test"
  permissions_boundary = "arn:aws:iam::259963121161:policy/PCSKPermissionsBoundary"
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
        }
    ]
}
EOF
}