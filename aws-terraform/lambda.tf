# Lambda function definitions for GET authorizer, GET integration, POST authorizer, POST integration

resource "aws_lambda_function" "lambda_get_authorizer" {
  filename         = "./GET_authorizer_lambda/my-deployment-package.zip"
  function_name    = "vuln_api_lambda_get_authorizer"
  role             = aws_iam_role.role_api_backend.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("./GET_authorizer_lambda/my-deployment-package.zip")
  runtime          = "python3.8"
  kms_key_arn      = aws_kms_key.kms_key.arn
  vpc_config {
    subnet_ids         = [aws_subnet.private-a.id]
    security_group_ids = [aws_security_group.lambda-sg.id]
  }

  environment {
    variables = {
      GET_AUTHORIZER_TABLE_NAME = aws_dynamodb_table.dynamodb_get_authorizer.name
    }
  }
}

resource "aws_lambda_function" "lambda_api_backend" {
  filename         = "./GET_backend_lambda/my-deployment-package.zip"
  function_name    = "vuln_api_lambda_function"
  role             = aws_iam_role.role_api_backend.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("./GET_backend_lambda/my-deployment-package.zip")
  runtime          = "python3.8"
  kms_key_arn      = aws_kms_key.kms_key.arn
  vpc_config {
    subnet_ids         = [aws_subnet.private-a.id]
    security_group_ids = [aws_security_group.lambda-sg.id]
  }

  environment {
    variables = {
      BACKEND_TABLE_NAME = aws_dynamodb_table.dynamodb_backend.name
    }
  }
}

resource "aws_lambda_function" "lambda_post_authorizer" {
  filename         = "./POST_authorizer_lambda/my-deployment-package.zip"
  function_name    = "vuln_api_lambda_post_authorizer"
  role             = aws_iam_role.role_api_backend_post.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("./POST_authorizer_lambda/my-deployment-package.zip")
  runtime          = "python3.8"
  kms_key_arn      = aws_kms_key.kms_key.arn
  vpc_config {
    subnet_ids         = [aws_subnet.private-a.id]
    security_group_ids = [aws_security_group.lambda-sg.id]
  }

  environment {
    variables = {
      POST_AUTHORIZER_TABLE_NAME = aws_dynamodb_table.dynamodb_post_authorizer.name
    }
  }
}

resource "aws_lambda_function" "lambda_api_backend_post" {
  filename         = "./POST_backend_lambda/my-deployment-package.zip"
  function_name    = "vuln_api_lambda_function_post"
  role             = aws_iam_role.role_api_backend_post.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("./POST_backend_lambda/my-deployment-package.zip")
  runtime          = "python3.8"
  kms_key_arn      = aws_kms_key.kms_key.arn
  vpc_config {
    subnet_ids         = [aws_subnet.private-a.id]
    security_group_ids = [aws_security_group.lambda-sg.id]
  }

  environment {
    variables = {
      BACKEND_TABLE_NAME = aws_dynamodb_table.dynamodb_backend.name
    }
  }  
}


