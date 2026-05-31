terraform {
  backend "s3" {
    bucket         = "ravula-terraform-bucket"
    key            = "bpay-etl/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
  }
}