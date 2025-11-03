module "cw_logs_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "cw-logs-permissions"
  path        = "/"
  description = "Policy for CW Agent on EC2"

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "logs:PutLogEvents",
                    "logs:DescribeLogStreams",
                    "logs:CreateLogStream",
                    "logs:CreateLogGroup"
                ],
                "Effect": "Allow",
                "Resource": "*",
                "Sid": "WriteLogs"
            }
        ]
    }
  EOF

  tags = {
    Terraform   = "true"
  }
}

module "s3_backup_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "s3-backup-permissions"
  path        = "/"
  description = "Policy for accesing S3 from EC2"

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "s3:GetBucketLocation",
                "Effect": "Allow",
                "Resource": "arn:aws:s3:::pg-dumps-from-ec2-pg-tf",
                "Sid": "BucketMeta"
            },
            {
                "Action": [
                    "s3:PutObjectTagging",
                    "s3:PutObject",
                    "s3:AbortMultipartUpload"
                ],
                "Effect": "Allow",
                "Resource": "arn:aws:s3:::pg-dumps-from-ec2-pg-tf/*",
                "Sid": "WriteObjects"
            }
        ]
    }
  EOF

  tags = {
    Terraform   = "true"
  }
}


module "ec2_ghostofolio_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"

  name = "ec2-ghostofolio-role"

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole",
      ]
      principals = [{
        type = "Service"
        identifiers = [
          "ec2.amazonaws.com",
        ]
      }]
    }
  }

  policies = {
    s3-backup-permissions      = module.s3_backup_policy.arn
    cw-logs-permissions = module.cw_logs_policy.arn
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}