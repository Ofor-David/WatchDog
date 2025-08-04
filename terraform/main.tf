module "vpc"{
    source = "./modules/vpc"
    name = var.app_name
}

module "security_group"{
    source = "./modules/security_group"
    vpc_id = module.vpc.vpc_id
    name = var.app_name  
}
