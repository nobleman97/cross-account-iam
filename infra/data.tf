data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid     = "AllowEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"] # Allow EC2 service to assume the role
    }
  }

  statement {
    sid     = "AllowLambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"] # Allow Lambda service to assume the role
    }
  }
}

data "aws_iam_policy_document" "assume_cross_account_role" {
  statement {
    sid = "AssumeRoleInOtherAccount"

    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.access_s3_bucket.arn] # Allow assuming the role in Account B
  }
}

data "aws_iam_policy_document" "allow_role_assumption_a" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cross_account_role.arn] # Allow the cross-account role to assume this role
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "s3_bucket_access" {
  statement {
    sid    = "S3BucketAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      module.reporting-bucket.s3_bucket_arn,
      "${module.reporting-bucket.s3_bucket_arn}/*"
    ]
  }
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../app"
  output_path = "../app/lambda_deployment.zip" # Or "../app/lambda_function.py"
}

resource "terraform_data" "lambda_zip_md5" {
  depends_on = [data.archive_file.lambda_zip]
  input      = data.archive_file.lambda_zip.output_md5
}