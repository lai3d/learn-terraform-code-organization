/*
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.73.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "random_pet" "petname" {
  length    = 3
  separator = "-"
}
*/

resource "aws_s3_bucket" "prod" {
  bucket = "${var.prod_prefix}-${random_pet.petname.id}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  force_destroy = true
}

resource "aws_s3_bucket_policy" "prod" {
  bucket = aws_s3_bucket.dev.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.prod_prefix}-${random_pet.petname.id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket_object" "prod" {
  acl          = "public-read"
  key          = "index.html"
  bucket       = aws_s3_bucket.prod.id
  content      = file("${path.module}/assets/index.html")
  content_type = "text/html"

}
