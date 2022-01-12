resource "aws_vpc" "serverless" {
  cidr_block       = "10.0.14.0/24"

  tags = {
    Name = "serverless"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.serverless.id
  cidr_block = "10.0.14.0/27"
  availability_zone = "us-west-2a"

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id     = aws_vpc.serverless.id
  cidr_block = "10.0.14.32/27"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private-a"
  }
}

/*resource "aws_subnet" "private-b" {
  vpc_id     = aws_vpc.serverless.id
  cidr_block = "10.0.14.64/27"
  availability_zone = "us-west-2b"

  tags = {
    Name = "private-b"
  }
}
*/

#Outward connectivity to the Internet for private resources
#resource "aws_nat_gateway" "nat" {
#  connectivity_type = "private"
#  subnet_id         = aws_subnet.private-a.id
#}

/*resource "aws_security_group" "lambda-sg" {
  name        = "serverless_lambda_sg"
  description = "Allow outbound traffic to DynamoDB"
  vpc_id      = aws_vpc.serverless.id
  egress = [
    {
      description = "TLS from Lambda to VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.14.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = {
    Name = "allow_tls"
  }
}
*/

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.serverless.id
  service_name = "com.amazonaws.us-west-2.dynamodb"
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "GET_Authorization",
      "Principal": {
        "AWS": ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.role_api_backend.name}/${aws_lambda_function.lambda_get_authorizer.function_name}"]
      },
      "Action": [
        "dynamodb:GetItem"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_dynamodb_table.dynamodb_get_authorizer.arn}"]
    },
    {
      "Sid": "GET_Data1",
      "Principal": {
        "AWS": ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.role_api_backend.name}/${aws_lambda_function.lambda_api_backend.function_name}"]
      },
      "Action": [
        "dynamodb:GetItem"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_dynamodb_table.dynamodb_backend.arn}"]
    },
    {
      "Sid": "GET_Data2",
      "Principal": {
        "AWS": ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.role_api_backend.name}/${aws_lambda_function.lambda_api_backend.function_name}"]
      },
      "Action": [
        "dynamodb:Query"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_dynamodb_table.dynamodb_backend.arn}/index/OrgIndex"]
    },
    {
      "Sid": "POST_Authorization",
      "Principal": {
        "AWS": ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.role_api_backend_post.name}/${aws_lambda_function.lambda_post_authorizer.function_name}"]
      },
      "Action": [
        "dynamodb:GetItem"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_dynamodb_table.dynamodb_post_authorizer.arn}"]
    },
    {
      "Sid": "Post",
      "Principal": {
        "AWS": ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.role_api_backend_post.name}/${aws_lambda_function.lambda_api_backend_post.function_name}"]
      },
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_dynamodb_table.dynamodb_backend.arn}"]
    }
  ]
}
EOF
}

#Fetching route tables, needed for VPC endpoint association
data "aws_route_table" "rtb_for_endpoint" {
  vpc_id = aws_vpc.serverless.id
}

resource "aws_vpc_endpoint_route_table_association" "endpoint_rtb" {
  route_table_id  = data.aws_route_table.rtb_for_endpoint.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

data "aws_prefix_list" "prefix_for_endpoint" {
  name = "com.amazonaws.us-west-2.dynamodb"
}

resource "aws_security_group" "lambda-sg" {
  name        = "serverless_lambda_sg"
  description = "Allow outbound traffic to DynamoDB"
  vpc_id      = aws_vpc.serverless.id
  egress = [
    {
      description = "TLS from Lambda to VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = data.aws_prefix_list.prefix_for_endpoint.cidr_blocks
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = {
    Name = "allow_tls"
  }
}