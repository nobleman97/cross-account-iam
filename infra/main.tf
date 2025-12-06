locals {
  bucket_name = "iss-reporting-24534576df"
}

################
# IAM resources
################

# Roles
resource "aws_iam_role" "cross_account_role" {
  name               = "connect-to-bridge"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "Bridge Connect Role"
  }
}

resource "aws_iam_role" "access_s3_bucket" {
  provider = aws.account_b

  name               = "access-s3-bucket"
  assume_role_policy = data.aws_iam_policy_document.allow_role_assumption_a.json

  tags = {
    Name = "Access S3 Bucket Role"
  }
}

# Policies
resource "aws_iam_policy" "assume_cross_account_role" {
  name        = "assume-bridge-worker-role"
  description = "Allows AWS services assume a role in another AWS account"
  policy      = data.aws_iam_policy_document.assume_cross_account_role.json
}

resource "aws_iam_policy" "s3_bucket_access" {
  provider    = aws.account_b
  name        = "s3-bucket-full-access"
  description = "Allows full access to S3 bucket"
  policy      = data.aws_iam_policy_document.s3_bucket_access.json
}

# Attachments
resource "aws_iam_role_policy_attachment" "ec2_assume_cross_account" {
  role       = aws_iam_role.cross_account_role.name
  policy_arn = aws_iam_policy.assume_cross_account_role.arn
}

resource "aws_iam_role_policy_attachment" "add_ssm_access" {
  role       = aws_iam_role.cross_account_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_bucket_access_attachment" {
  provider   = aws.account_b
  role       = aws_iam_role.access_s3_bucket.name
  policy_arn = aws_iam_policy.s3_bucket_access.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "connect-to-bridge-profile"
  role = aws_iam_role.cross_account_role.name
}

##############
# S3 Bucket  (in Account B)
##############
module "reporting-bucket" {
  providers = {
    aws = aws.account_b
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = local.bucket_name
}

#################
# Lambda Function (in Account A)
#################

resource "aws_lambda_function" "cross_account_s3_lambda" {
  filename      = "${path.module}/../app/lambda_deployment.zip"
  function_name = "write-report-to-crossaccount-s3"
  role          = aws_iam_role.cross_account_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30

  environment {
    variables = {
      ACCOUNT2_ROLE_ARN = aws_iam_role.access_s3_bucket.arn
      BUCKET_NAME       = module.reporting-bucket.s3_bucket_id
      BUCKET_REGION     = module.reporting-bucket.s3_bucket_region
    }
  }

  lifecycle {
    replace_triggered_by = [ 
        terraform_data.lambda_zip_md5.input
    ]
  }

  tags = {
    Name = "Cross Account S3 Access Lambda"
  }
}

#################
# EventBridge Trigger (5-minute interval)
#################

resource "aws_cloudwatch_event_rule" "lambda_5min_trigger" {
  name                = "lambda-5min-trigger"
  description         = "Trigger Lambda every 5 minutes"
  schedule_expression = "rate(5 minutes)"

  tags = {
    Name = "Lambda 5-Minute Trigger"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_5min_trigger.name
  target_id = "CrossAccountS3Lambda"
  arn       = aws_lambda_function.cross_account_s3_lambda.arn

  depends_on = [ 
    aws_lambda_function.cross_account_s3_lambda
   ]
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cross_account_s3_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_5min_trigger.arn
}


