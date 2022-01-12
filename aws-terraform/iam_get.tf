# IAM role and policy to be attached to Lambda function to "GET" items from DynamoDB

resource "aws_iam_policy" "policy_api_backend" {
  name = "vuln_api_lambda_iam_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "dynamodb:GetItem"
        ]
        Effect   = "Allow"
        Resource = [ 
          aws_dynamodb_table.dynamodb_backend.arn,
          aws_dynamodb_table.dynamodb_get_authorizer.arn
        ]
      },
      {
        Action = [
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = [ 
          "${aws_dynamodb_table.dynamodb_backend.arn}/index/OrgIndex",
        ]
      },
      {
        Action = [
          "kms:Decrypt"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.kms_key.arn
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role" "role_api_backend" {
  name = "vuln_api_lambda_iam_role"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_policy_attachment" "policy_attach1" {
  name       = "policy-attachment1"
  roles      = [aws_iam_role.role_api_backend.name]
  policy_arn = aws_iam_policy.policy_api_backend.arn
}

resource "aws_iam_policy_attachment" "policy_attach2" {
  name       = "policy-attachment2"
  roles      = [aws_iam_role.role_api_backend.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}