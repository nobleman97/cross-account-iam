data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid     = "AllowEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_cross_account_role" {
  statement {
    sid = "AssumeRoleInOtherAccount"

    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.access_s3_bucket.arn]
  }
}

data "aws_iam_policy_document" "allow_role_assumption_a" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cross_account_role.arn]
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
