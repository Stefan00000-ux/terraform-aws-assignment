vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]
ami_id               = "ami-0440d3b780d96b29d" # Standard Amazon Linux 2
instance_type        = "t2.micro"
desired_capacity     = 2