terraform {
  backend "s3" {
    bucket         = "terraform-remote-state"
    key            = "test/ec2-elb-instance.tfstate"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:676256863214:alias/tf-s3-state-bucket-kms-key"
    dynamodb_table = "terraform-state-lock"
    region         = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30"
    }
  }

  required_version = "~> 1.2"
}

provider "aws" {
  region = "us-east-1"
}
