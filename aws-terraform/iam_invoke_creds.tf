#AWS IAM permission for API Gateway to invoke Authorizer and Integration Lambda functions

resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation_get"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "invocation_policy_get" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": [
          "${aws_lambda_function.lambda_get_authorizer.arn}",
          "${aws_lambda_function.lambda_post_authorizer.arn}",
          "${aws_lambda_function.lambda_api_backend_post.arn}",
          "${aws_lambda_function.lambda_api_backend.arn}"
          ]
    }
  ]
}
EOF
}