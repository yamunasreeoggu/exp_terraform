module "vpc" {
  source = "./modules/vpc"
  env = var.env
  vpc_cidr = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  azs = var.azs
  default_vpc_id = var.default_vpc_id
  account_id = var.account_id
  default_vpc_cidr = var.default_vpc_cidr
  default_rt_id = var.default_rt_id
}

module "public-lb" {
  source = "./modules/alb"
  env = var.env
  alb-type          = "public"
  alb_sg_allow_cidr = "0.0.0.0/0"
  internal          = "false"
  vpc_id            = module.vpc.vpc_id
}