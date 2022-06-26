provider "aws" {
  access_key = "ASIASVBKBFY23BDOOC25"  
  secret_key = "m6SyzCTyTry6Raohb6RpsjKI5VsInVJnaYde2pUq"
  token = "FwoGZXIvYXdzEBgaDBZPB84oOIykxfggFSLVAbCctxjnDE9/NQx8U7wAWdrZlaK5XY8IkhEe3fwQ+oDjOg+fSuxrXwOw3H8fo+G6UkObMNRyPARiCETIrCIQg1yOUAA3ZmdvEUttAvP3NrqHLreZ4kyw03UXEJi8zUmjnNLQvyEQv22gUdyzuSHmmLTgry7SgGGFb1pQmkKWjQKfqNULU2YRgos0lc4p/b5j8A7Xi51pdbONI0ZKlPBw7x1w8e+s82TUhC7NRqYxzCeSPDswDu1WASVJrK6PgBzJVkKX56o4/gICjts0/9g1IOoOrtvqDSizhM6UBjItYLfcGW8SXMqZLw0RU9tGwcjKOf5wWmwT0JftmeQFFFMmBb1aJT7DyKv+pgIA"
  region                  = var.aws_region
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 3
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda_2.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role" "iam_for_lambda_2" {
  name = "iam_for_lambda_2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/greet_lambda.py"
  output_path = "${path.module}/script.zip"
}

resource "aws_lambda_function" "lambda_greeting" {
  description      = "Simple python lambda function"
  role             = aws_iam_role.iam_for_lambda_2.arn
  filename         = "script.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = var.lambda_function_name
  handler          = "${var.lambda_function_name}.lambda_handler"
  runtime          = "python3.8"

  environment {
    variables = {
      greeting = "Hello World"
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_log_group, aws_iam_role_policy_attachment.lambda_logs]
}