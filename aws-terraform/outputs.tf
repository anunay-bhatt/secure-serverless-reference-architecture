output "api_gateway_endpoint" {
  value = aws_api_gateway_deployment.vuln_api_deployment.invoke_url
}