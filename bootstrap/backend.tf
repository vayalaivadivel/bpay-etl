terraform {
  backend "s3" {
    bucket         = "ravula-terraform-bucket"
    key            = "bootstrap/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
  }
}