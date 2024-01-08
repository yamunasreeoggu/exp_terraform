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
  source            = "./modules/alb"
  env               = var.env
  alb-type          = "public"
  alb_sg_allow_cidr = ["0.0.0.0/0"]
  internal          = false
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.public_subnets
}

module "private-lb" {
  source            = "./modules/alb"
  env               = var.env
  alb-type          = "private"
  alb_sg_allow_cidr = [var.vpc_cidr]
  internal          = true
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.private_subnets
}

module "frontend" {
  source           = "./modules/app"
  app-port         = 80
  component        = "frontend"
  desired_capacity = var.desired_capacity
  env              = var.env
  instance_type    = var.instance_type
  max_size         = var.max_size
  min_size         = var.min_size
  vpc_cidr         = [var.vpc_cidr]
  vpc_id           = module.vpc.vpc_id
  subnets          = module.vpc.private_subnets
  workstation_node_cidr = var.workstation_node_cidr
}

module "backend" {
  source           = "./modules/app"
  app-port         = 8080
  component        = "backend"
  desired_capacity = var.desired_capacity
  env              = var.env
  instance_type    = var.instance_type
  max_size         = var.max_size
  min_size         = var.min_size
  vpc_cidr         = [var.vpc_cidr]
  vpc_id           = module.vpc.vpc_id
  subnets          = module.vpc.private_subnets
  workstation_node_cidr = var.workstation_node_cidr
}

module "mysql" {
  source = "./modules/rds"

  azs       = var.azs
  component = "mysql"
  env       = var.env
  subnets   = module.vpc.private_subnets
  vpc_cidr  = var.vpc_cidr
  vpc_id    = module.vpc.vpc_id
}