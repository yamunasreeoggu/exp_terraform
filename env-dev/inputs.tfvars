env = "dev"

vpc_cidr = ["10.0.0.0/16"]
public_subnets = ["10.0.0.0/24" , "10.0.1.0/24"]
private_subnets = ["10.0.2.0/24" , "10.0.3.0/24"]
azs = ["us-east-1a" , "us-east-1b"]
default_vpc_cidr = "172.31.0.0/16"
default_vpc_id = "vpc-0f69303a5ee298d49"
account_id = "492681564023"
default_rt_id = "rtb-0cd5d19506508373c"
instance_type = "t3.micro"
desired_capacity = 1
min_size = 1
max_size = 1
