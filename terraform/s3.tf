# Bucket
resource "aws_s3_bucket" "lacework_alerts_bucket" {
  bucket = var.aws_s3_bucket_name
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.lacework_alerts_bucket.id
  acl    = "private"
}