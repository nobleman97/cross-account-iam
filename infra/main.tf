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
  provider           = aws.account_b
  name               = "access-s3-bucket"
  assume_role_policy = data.aws_iam_policy_document.allow_role_assumption_a.json

  tags = {
    Name = "Access S3 Bucket Role"
  }
}

# Policies
resource "aws_iam_policy" "assume_cross_account_role" {
  name        = "assume-bridge-tf-role"
  description = "Allows EC2 to assume a role in another AWS account"
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
# S3 Bucket
##############
module "reporting-bucket" {
  providers = {
    aws = aws.account_b
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = local.bucket_name
}





