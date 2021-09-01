resource "aws_api_gateway_domain_name" "vuln_domain" {
    domain_name     = var.domain_name
    regional_certificate_arn = var.domain_certificate_arn
    security_policy = "TLS_1_2"
    mutual_tls_authentication {
        truststore_uri = "s3://${aws_s3_bucket.bucket_truststore.bucket}/${aws_s3_bucket_object.object_truststore.key}"
    }
    endpoint_configuration {
        types  = ["REGIONAL"]
    }
}

resource "aws_api_gateway_base_path_mapping" "vuln_domain_mapping" {
  api_id      = aws_api_gateway_rest_api.vuln_api.id
  stage_name  = var.stage_name
  domain_name = aws_api_gateway_domain_name.vuln_domain.domain_name

  depends_on = [
    aws_api_gateway_stage.vuln_api_stage
  ]
}

resource "aws_s3_bucket" "bucket_truststore" {
  bucket = "vuln-api-truststore"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_object" "object_truststore" {
  bucket = aws_s3_bucket.bucket_truststore.id
  key    = "certificates.pem"
  source = "./truststore/certificates.pem"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("./truststore/certificates.pem")
}