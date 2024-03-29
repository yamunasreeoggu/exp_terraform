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
  dns_name          = "frontend-${var.env}.yamunadevops.online"
  zone_id           = var.zone_id
  tg_arn            = module.frontend.tg_arn
}

module "private-lb" {
  source            = "./modules/alb"
  env               = var.env
  alb-type          = "private"
  alb_sg_allow_cidr = [var.vpc_cidr]
  internal          = true
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.private_subnets
  dns_name          = "backend-${var.env}.yamunadevops.online"
  zone_id           = var.zone_id
  tg_arn            = module.backend.tg_arn
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
  depends_on       = [module.mysql]
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
  env       = var.env
  component = "mysql"
  subnets   = module.vpc.private_subnets
  vpc_cidr  = [var.vpc_cidr]
  vpc_id    = module.vpc.vpc_id
  rds_instance_class = var.rds_instance_class
}
