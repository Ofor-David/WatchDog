module "ecr" {
  source = "./modules/ecr"
  name   = var.app_name
}

module "vpc" {
  source = "./modules/vpc"
  name   = var.app_name
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  name   = var.app_name
}

module "ecs_cluster" {
  source                = "./modules/ecs_cluster"
  name                  = var.app_name
  instance_type         = var.instance_type
  key_name              = var.key_name
  instance_profile_name = module.iam.ecs_instance_profile_name
  public_subnet_id      = module.vpc.public_subnet_ids[0]
  security_group_id     = module.security_group.ecs_sg_id
  ecs_service           = module.ecs_service.ecs_service
  volume_size           = 30 # Default volume size in GB
  security_group_name   = module.security_group.alb_sg_name
}

module "iam" {
  source = "./modules/iam"
  name   = var.app_name
}

module "ecs_service" {
  source               = "./modules/ecs_service"
  family               = "watchdog-task"
  cpu                  = 256
  memory               = 512
  execution_role_arn   = module.iam.ecs_execution_role_arn
  task_role_arn        = module.iam.ecs_task_role_arn
  image_uri            = var.ecr_image_uri
  container_name       = var.app_name
  cluster_id           = module.ecs_cluster.cluster_id
  lb_tg                = module.alb.target_group_arn
  ecs_cp_name          = module.asg.ecs_cp_name
  cluster_name         = module.ecs_cluster.cluster_name
  service_min_capacity = 1
  desired_count        = 2
  service_max_capacity = 5
  service_cpu_target   = 95
}

module "alb" {
  source            = "./modules/alb"
  name              = var.app_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  health_check_path = "/api"
  alb_sg_id         = module.security_group.alb_sg_id
}

module "asg" {
  source               = "./modules/asg"
  name                 = var.app_name
  launch_template_id   = module.ecs_cluster.launch_template_id
  ecs_cluster_name     = module.ecs_cluster.cluster_name
  subnet_ids           = module.vpc.public_subnet_ids
  lb_target_group_arns = [module.alb.target_group_arn]
  ecs_cluster          = module.ecs_cluster.ecs_cluster
}

output "ecr_repo_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repo_url
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.alb_dns_name
}
