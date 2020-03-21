resource "aws_s3_bucket" "jenkins" {

  bucket = "${var.stack_name}-jenkins"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "backup"
    prefix  = "backup/"
    enabled = true

    expiration {
      days = 30
    }
  }

  tags = {
    Name             = "${var.stack_name}-jenkins"
  }
}

resource "aws_s3_bucket_policy" "jenkins_bucket_policy" {

  bucket = aws_s3_bucket.jenkins.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "JenkinsBucketPolicy",
  "Statement": [
    {
      "Sid": "ForceEncryptedWrites",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.jenkins.id}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "AllowLoadBalancerAccessLogs",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_lb_account_id}:root"
      },
      "Action": "s3:PutObject",
      "Resource": [
        "${aws_s3_bucket.jenkins.arn}/AWS",
        "${aws_s3_bucket.jenkins.arn}/AWS/*"
      ]
    },
    {
      "Sid": "AllowJenkinsServices",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.jenkins_role.arn}"
        ]
      },
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.jenkins.arn}",
        "${aws_s3_bucket.jenkins.arn}/*"
      ]
    }
  ]
}
POLICY
}