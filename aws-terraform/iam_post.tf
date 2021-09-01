# IAM role and policy to be attached to Lambda function to "GET" and "PUT" items to DynamoDB

resource "aws_iam_policy" "policy_api_backend_post" {
  name = "vuln_api_lambda_iam_policy_post"

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
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Effect   = "Allow"
        Resource = [ 
          aws_dynamodb_table.dynamodb_backend.arn
        ]
      },
      {
        Action = [
          "dynamodb:GetItem"
        ]
        Effect   = "Allow"
        Resource = [ 
          aws_dynamodb_table.dynamodb_post_authorizer.arn
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
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "role_api_backend_post" {
  name = "vuln_api_lambda_iam_role_post"
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

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PCSKPermissionsBoundary"

}

resource "aws_iam_policy_attachment" "policy_attach1_post" {
  name       = "policy-attachment1_post"
  roles      = [aws_iam_role.role_api_backend_post.name]
  policy_arn = aws_iam_policy.policy_api_backend_post.arn
}

resource "aws_iam_policy_attachment" "policy_attach2_post" {
  name       = "policy-attachment2_post"
  roles      = [aws_iam_role.role_api_backend_post.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}