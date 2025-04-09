provider "aws" {
  region = "us-east-1"
  # profile = "aaron-profile" 
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
  }
}