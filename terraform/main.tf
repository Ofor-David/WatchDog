module "vpc"{
    source = "./modules/vpc"
    name = var.app_name
}

module "security_group"{
    source = "./modules/security_group"
    vpc_id = module.vpc.vpc_id
    name = var.app_name  
    alb_security_group_id = module.alb.alb_security_group_id
}

module "ecs_cluster" {
  source            = "./modules/ecs_cluster"
  name      = var.app_name
  instance_type = var.instance_type
  key_name        = var.key_name
  instance_profile_name = module.iam.ecs_instance_profile_name
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id
}
module "iam"{
    source = "./modules/iam"
    name = var.app_name
}

module "ecr" {
  source = "./modules/ecr"
  name   = var.app_name
}

module "ecs_service" {
  source              = "./modules/ecs_service"
  family              = "watchdog-task"
  cpu                 = 256
  memory              = 512
  execution_role_arn  = module.iam.ecs_execution_role_arn
  task_role_arn       = module.iam.ecs_task_role_arn
  image_uri           = var.ecr_image_uri
  container_name      = var.app_name
  container_port      = 8000
  cluster_id          = module.ecs_cluster.cluster_id
  desired_count       = 1
}

module "alb" {
  source              = "./modules/alb"
  name                = var.app_name
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  target_port         = 8000
  health_check_path   = "/health"
}

module "asg" { 
  source = "./modules/asg"
  name = var.app_name
  launch_template_id = module.ecs_cluster.launch_template_id
  ecs_cluster_name = module.ecs_cluster.cluster_name
  subnet_ids = module.vpc.public_subnet_ids
  lb_target_group_arns = [module.alb.target_group_arn]
}