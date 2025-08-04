module "vpc"{
    source = "./modules/vpc"
    name = var.app_name
}

module "security_group"{
    source = "./modules/security_group"
    vpc_id = module.vpc.vpc_id
    name = var.app_name  
}

module "ecs_cluster" {
  source            = "./modules/ecs_cluster"
  name      = var.app_name
  subnet_id = module.vpc.public_subnet_id
  instance_type = var.instance_type
  key_name        = var.key_name
  instance_profile_name = module.iam.ecs_instance_profile_name
  public_subnet_id  = module.vpc.public_subnet_id
  security_group_id = module.security_group.security_group_id
}
module "iam"{
    source = "./modules/iam"
    name = var.app_name
}
