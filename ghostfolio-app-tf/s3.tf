resource "aws_s3_bucket" "pg_dumps" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "pg_dumps" {
  bucket = aws_s3_bucket.pg_dumps.id

  rule {
    id     = "GLACIER-then-expire"
    status = "Enabled"

    transition {
      days          = 7
      storage_class = "GLACIER"
    }

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.pg_dumps.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}