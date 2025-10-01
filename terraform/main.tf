module "ecr" {
  source = "./modules/ecr"
  name   = var.app_name
}

module "vpc" {
  source = "./modules/vpc"
  name   = var.app_name
}

module "security_group" {
  source        = "./modules/security_group"
  vpc_id        = module.vpc.vpc_id
  name          = var.app_name
  allowed_ips   = ["${module.bastion.bastion_private_ip}/32"]
  your_local_ip = var.your_local_ip

}

module "bastion" {
  source      = "./modules/bastion"
  name_prefix = var.app_name
  key_name    = var.key_name
  subnet_id   = module.vpc.public_subnet_ids[0]
  alb_sg_id   = module.security_group.alb_sg_id
}


module "ecs_cluster" {
  source                  = "./modules/ecs_cluster"
  name                    = var.app_name
  instance_type           = var.instance_type
  key_name                = var.key_name
  instance_profile_name   = module.iam.ecs_instance_profile_name
  public_subnet_id        = module.vpc.public_subnet_ids[0]
  security_group_id       = module.security_group.ecs_sg_id
  ecs_service             = module.ecs_service.ecs_service
  volume_size             = var.instance_volume_size
  security_group_name     = module.security_group.alb_sg_name
  falco_bucket_name       = module.falco.falco_bucket_name
  custom_rules_object_key = "custom_rules.yaml"
  falco_log_group_name    = module.falco.falco_log_group_name
  cron_schedule           = var.cron_schedule
}

module "iam" {
  source           = "./modules/iam"
  name             = var.app_name
  falco_bucket_arn = module.falco.falco_bucket_arn
}

module "ecs_service" {
  source               = "./modules/ecs_service"
  family               = "watchdog-task"
  cpu                  = var.cpu_per_task
  memory               = var.memory_per_task
  execution_role_arn   = module.iam.ecs_execution_role_arn
  task_role_arn        = module.iam.ecs_task_role_arn
  image_uri            = "${module.ecr.repo_url}:latest"
  container_name       = var.app_name
  cluster_id           = module.ecs_cluster.cluster_id
  lb_tg                = module.alb.target_group_arn
  ecs_cp_name          = module.asg.ecs_cp_name
  cluster_name         = module.ecs_cluster.cluster_name
  service_min_capacity = var.service_min_capacity
  desired_count        = var.service_desired_capacity
  service_max_capacity = var.service_max_capacity
  service_cpu_target   = var.service_cpu_target
  instance_cpu_target  = var.instance_cpu_target
  asg_name             = module.asg.asg_name
}

module "alb" {
  source            = "./modules/alb"
  name              = var.app_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  health_check_path = var.healtcheck_path
  alb_sg_id         = module.security_group.alb_sg_id
  domain_name       = var.domain_name
}

module "asg" {
  source                = "./modules/asg"
  name                  = var.app_name
  launch_template_id    = module.ecs_cluster.launch_template_id
  ecs_cluster_name      = module.ecs_cluster.cluster_name
  subnet_ids            = module.vpc.public_subnet_ids
  lb_target_group_arns  = [module.alb.target_group_arn]
  ecs_cluster           = module.ecs_cluster.ecs_cluster
  instance_min_count    = var.instance_min_count
  instance_max_count    = var.instance_max_count
  max_instance_lifetime = var.max_instance_lifetime
}

module "falco" {
  source            = "./modules/falco"
  name_prefix       = var.app_name
  retention_in_days = var.falco_log_retention_duration
}
