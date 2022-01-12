# Creation of REST API with openapi definition in yaml file
resource "aws_api_gateway_rest_api" "vuln_api" {
  name = "Vuln API"
  description = "Demo Serverless API to interact with vulnerability database"
  body = templatefile("./openapi.yaml", {
    region = data.aws_region.current.name,
    lambda_get_authorizer = aws_lambda_function.lambda_get_authorizer.arn,
    lambda_post_authorizer = aws_lambda_function.lambda_post_authorizer.arn,
    lambda_api_backend_post = aws_lambda_function.lambda_api_backend_post.arn,
    lambda_api_backend = aws_lambda_function.lambda_api_backend.arn,
    api_invoke_role = aws_iam_role.invocation_role.arn
  })
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [
    aws_lambda_function.lambda_get_authorizer,
    aws_lambda_function.lambda_post_authorizer,
    aws_lambda_function.lambda_api_backend_post,
    aws_lambda_function.lambda_api_backend,
    aws_api_gateway_account.cloudwatch
  ]
}

#Use a resource policy to allow only certain IP addresses to access the API Gateway REST API
resource "aws_api_gateway_rest_api_policy" "ip_policy" {

  count = (var.source_ip_address == "" ? 0 : 1)
  rest_api_id = aws_api_gateway_rest_api.vuln_api.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "${aws_api_gateway_rest_api.vuln_api.execution_arn}/*/*/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "${var.source_ip_address}"
        }
      }
    }
  ]
}
EOF
}

# We can deploy the API now!
resource "aws_api_gateway_deployment" "vuln_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.vuln_api.id
  description = "Deploy methods for test"
}

# Creating a stage now with enabled logging
resource "aws_api_gateway_stage" "vuln_api_stage" {
  depends_on = [aws_cloudwatch_log_group.vuln_api_log_group]

  stage_name = var.stage_name
  rest_api_id = aws_api_gateway_rest_api.vuln_api.id
  deployment_id = aws_api_gateway_deployment.vuln_api_deployment.id
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.vuln_api_log_group.arn
    format          = <<EOF
{ "requestId":"$context.requestId", "ip": "$context.identity.sourceIp", "caller":"$context.identity.caller", "user":"$context.identity.user","requestTime":"$context.requestTime", "httpMethod":"$context.httpMethod","resourcePath":"$context.resourcePath", "status":"$context.status","protocol":"$context.protocol", "responseLength":"$context.responseLength" }
EOF 
  }
}

# Creating logging and metrics for stage
resource "aws_api_gateway_method_settings" "vuln_api_stage_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.vuln_api.id
  stage_name  = aws_api_gateway_stage.vuln_api_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}