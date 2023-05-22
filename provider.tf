## specifying the provider and credentials are set in configuratin file 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "sachin-hadadi-state-file"
    key            = "terraform.tfstate"  
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "lock-file"  
  }
}

provider "aws" {
 region = "ap-south-1"
 }


