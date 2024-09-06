locals {
  target_group_name = "${var.cluster_name}-tg"
  container_name    = "sample-app"
  container_port    = 3000
}

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = var.cluster_name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = var.tags
}

################################################################################
# Service
################################################################################

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"
  
  # Service
  name        = var.cluster_name
  cluster_arn = module.ecs_cluster.arn

  # Enables ECS Exec
  enable_execute_command = true

  cpu    = 512
  memory = 1024

  # Container definition(s)
  container_definitions = {
    (local.container_name) = {
      image  = "896644348821.dkr.ecr.us-east-1.amazonaws.com/joeandjoe-temp:overflow-marketing-booking-8965e0fe0cb66bc8dff19518de40a42ca20f658a"
      cpu    = 512
      memory = 1024
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]


      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      enable_cloudwatch_logging              = true
      create_cloudwatch_log_group            = true
      cloudwatch_log_group_name              = "/aws/ecs/${var.cluster_name}/${local.container_name}"
      cloudwatch_log_group_retention_in_days = 7

      log_configuration = {
        logDriver = "awslogs"
      }
    }
  }

  autoscaling_policies = {
    cpu_scale_out = {
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type         = "ChangeInCapacity"
        cooldown                = 60
        metric_aggregation_type = "Maximum"
        step_adjustment = [
          {
            metric_interval_lower_bound = 0
            scaling_adjustment          = 1
          }
        ]
      }
    }
    cpu_scale_in = {
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type         = "ChangeInCapacity"
        cooldown                = 300
        metric_aggregation_type = "Maximum"
        step_adjustment = [
          {
            metric_interval_upper_bound = 0
            scaling_adjustment          = -1
          }
        ]
      }
    }
    memory_scale_out = {
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type         = "ChangeInCapacity"
        cooldown                = 60
        metric_aggregation_type = "Maximum"
        step_adjustment = [
          {
            metric_interval_lower_bound = 0
            scaling_adjustment          = 1
          }
        ]
      }
    }
    memory_scale_in = {
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type         = "ChangeInCapacity"
        cooldown                = 300
        metric_aggregation_type = "Maximum"
        step_adjustment = [
          {
            metric_interval_upper_bound = 0
            scaling_adjustment          = -1
          }
        ]
      }
    }
  }


  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.container_name
      }
      port_name      = local.container_name
      discovery_name = local.container_name
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["${local.target_group_name}"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_http_ingress = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  service_tags = {
    "ServiceTag" = "Tag on service level"
  }

  tags = var.tags

}
# TODO: need to look into getting rid of and/or modifying default autoscaling alarms. People saying it may have to do with having auto scaling enabled?

################################################################################
# Supporting Resources
################################################################################

resource "aws_service_discovery_http_namespace" "this" {
  name        = var.cluster_name
  description = "CloudMap namespace for ${var.cluster_name}"
  tags        = var.tags
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = var.cluster_name

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = local.target_group_name
      }
    }
  }

  target_groups = {
    (local.target_group_name) = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        matcher             = "200-399"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        interval            = 15
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = var.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.cluster_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = var.tags
}

################################################################################
# Alarms
################################################################################

### Custom CPU AlarmHigh
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.cluster_name}/${module.ecs_service.name}-service/cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "30"  # 30 seconds
  statistic           = "Maximum"  
  threshold           = "65"
  alarm_description   = "This metric monitors ECS CPU high utilization"
  
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = module.ecs_service.name
  }

  alarm_actions = [module.ecs_service.autoscaling_policies["cpu_scale_out"].arn]
}


### Custom CPU AlarmLow
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.cluster_name}/${module.ecs_service.name}-service/cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "600" # 7.5 minutes
  statistic           = "Maximum"
  threshold           = "30"
  alarm_description   = "This metric monitors ECS CPU low utilization"
  
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = module.ecs_service.name
  }

  alarm_actions = [module.ecs_service.autoscaling_policies["cpu_scale_in"].arn]
}

### Custom Memory AlarmHigh
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.cluster_name}/${module.ecs_service.name}-service/memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "30" # 30 seconds
  statistic           = "Maximum"
  threshold           = "65"
  alarm_description   = "This metric monitors ECS memory high utilization"
  
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = module.ecs_service.name
  }

  alarm_actions = [module.ecs_service.autoscaling_policies["memory_scale_out"].arn]
}

### Custom Memory AlarmLow
resource "aws_cloudwatch_metric_alarm" "memory_low" {
  alarm_name          = "${var.cluster_name}/${module.ecs_service.name}-service/memory-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "600" # 7.5 minutes
  statistic           = "Maximum"
  threshold           = "30"
  alarm_description   = "This metric monitors ECS memory low utilization"
  
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = module.ecs_service.name
  }

  alarm_actions = [module.ecs_service.autoscaling_policies["memory_scale_in"].arn]
}
