terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Recomendación: Usar S3 backend en el futuro para state locking
  # backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
