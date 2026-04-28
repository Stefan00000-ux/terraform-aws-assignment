provider "aws" {
  region = "us-east-1" 
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ec2" {
  source             = "./modules/ec2"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  desired_capacity   = var.desired_capacity
  alb_sg_id          = module.alb.alb_sg_id
}
#terraform {
#  backend "s3" {
#    bucket         = "stephen-final-assignment-77821" # Paste the name here
#    Key            = "terraform.tfstate"
#    region         = "us-east-1"
#    dynamodb_table = "terraform-lockid"
#    encrypt        = true
#  }
#}
