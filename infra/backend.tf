terraform {
  backend "s3" {
    bucket         = "jungle-terraform-bucket"
    key            = "bpay-etl/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "jungle-terraform-lock"
    encrypt        = true
  }
}