resource "aws_lambda_function" "process_cars_lambda" {
  function_name    = "process-cars"
  runtime          = "nodejs22.x"
  handler          = "index.handler"
  filename         = data.archive_file.process_cars_lambda_file.output_path
  role             = aws_iam_role.process_cars_lambda_role.arn
  source_code_hash = data.archive_file.process_cars_lambda_file.output_base64sha256
}

resource "aws_iam_role" "process_cars_lambda_role" {
  name               = "process-cars-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "process_cars_lambda_role_policies" {
  role   = aws_iam_role.process_cars_lambda_role.name
  policy = data.aws_iam_policy_document.policies.json
}

data "archive_file" "process_cars_lambda_file" {
  source_dir  = "init_code"
  type        = "zip"
  output_path = "process_cars_lambda_payload.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policies" {
  statement {
    effect = "Allow"
    sid    = "LogToCloudwatch"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]

    resources = [
      aws_dynamodb_table.cars.stream_arn
    ]
  }
}
