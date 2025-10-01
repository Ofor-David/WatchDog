app_name = "watchdog"
aws_access_key = "xxxx"
aws_secret_key = "xxxx"
key_name = "key name for ec2"
domain_name = "domainname.com"

# Modify as desired
cpu_per_task = 256
memory_per_task = 512

service_min_capacity = 1
service_desired_capacity = 2
service_max_capacity = 4
service_cpu_target = 50 # percentage of CPU utilization before scaling
max_instance_lifetime = 604800 # 7 days

instance_min_count = 1
instance_max_count = 4
instance_cpu_target = 40 # percentage of CPU utilization before scaling

falco_log_retention_duration = 30 # in days
cron_schedule = "0 3 * * *" # How often to check for falco rule updates (default: daily at 3 AM UTC)

