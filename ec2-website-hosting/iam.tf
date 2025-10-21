data "aws_iam_policy_document" "ec2_trust" {
  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_backup_role" {
  name               = "ec2-db-backup-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}


data "aws_iam_policy_document" "s3_backup_permissions" {
  # Bucket-level
  statement {
    sid       = "BucketMeta"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.pg_dumps.arn]
  }

  # Object-level: allow uploads anywhere in the bucket
  statement {
    sid = "WriteObjects"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:PutObjectTagging"
    ]
    resources = ["${aws_s3_bucket.pg_dumps.arn}/*"]
  }

}

resource "aws_iam_role_policy" "attach_s3_permissions" {
  name   = "s3-backup-permissions"
  role   = aws_iam_role.ec2_backup_role.id
  policy = data.aws_iam_policy_document.s3_backup_permissions.json
}

resource "aws_iam_instance_profile" "ec2_backup_profile" {
  name = "ec2-db-backup-profile"
  role = aws_iam_role.ec2_backup_role.name
}
