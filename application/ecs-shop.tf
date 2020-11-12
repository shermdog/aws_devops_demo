resource "aws_ecs_task_definition" "shop" {
    family                   = "rsherman_${terraform.workspace}-ecommerce-shop"
    memory                   = "14000"
    container_definitions    = jsonencode(
        [
            {
                name         = "frontend"
                image        = var.frontend_version[var.app_version]
                command      = [
                    "sh",
                    "docker-entrypoint.sh",
                ]
                cpu          = 0
                environment  = [
                    {
                        name  = "LOCAL_REQUESTS"
                        value = "false"
                    },
                    {
                        name  = "DB_PASSWORD"
                        value = var.db_password
                    },
                    {
                        name  = "DB_USERNAME"
                        value = "postgres"
                    },
                    {
                        name  = "DD_ANALYTICS_ENABLED"
                        value = "true"
                    },
                    {
                        name  = "DD_APM_ENABLED"
                        value = "true"
                    },
                    {
                        name  = "DD_ENV"
                        value = terraform.workspace
                    },
                    {
                        name  = "DD_VERSION"
                        value = tostring(var.app_version)
                    },
                    {
                        name  = "DD_LOGS_INJECTION"
                        value = "true"
                    },
                ]
                "dockerLabels": {
                  "com.datadoghq.tags.env": terraform.workspace,
                  "com.datadoghq.tags.service": "store-frontend",
                  "com.datadoghq.tags.version": tostring(var.app_version)
                }
                essential    = true
                links        = [
                    "db",
                    "discounts",
                    "advertisements",
                ]
                memory       = 1024
                portMappings = [
                    {
                        containerPort = 3000
                        hostPort      = 3000
                        protocol      = "tcp"
                    },
                ]
                startTimeout = 600
            },
            {
                name         = "discounts"
                image        = var.discounts_version[var.app_version]
                command      = [
                    "sh",
                    "docker-entrypoint.sh",
                ]
                cpu          = 0
                environment  = [
                    {
                        name  = "DD_SERVICE"
                        value = "discounts-service"
                    },
                    {
                        name  = "DD_ENV"
                        value = terraform.workspace
                    },
                    {
                        name  = "DD_VERSION"
                        value = tostring(var.app_version)
                    },
                    {
                        name  = "DD_ANALYTICS_ENABLED"
                        value = "true"
                    },
                    {
                        name  = "DD_LOGS_INJECTION"
                        value = "true"
                    },
                    {
                        name  = "DD_PROFILING_ENABLED"
                        value = "true"
                    },
                    {
                        name  = "FLASK_APP"
                        value = "discounts.py"
                    },
                    {
                        name  = "POSTGRES_PASSWORD"
                        value = var.db_password
                    },
                    {
                        name  = "POSTGRES_USER"
                        value = "postgres"
                    },
                ]
                "dockerLabels": {
                  "com.datadoghq.tags.env": terraform.workspace,
                  "com.datadoghq.tags.service": "discounts-service",
                  "com.datadoghq.tags.version": tostring(var.app_version)
                }
                essential    = true
                links        = [
                    "db",
                ]
                portMappings = [
                    {
                        containerPort = 5001
                        hostPort      = 5001
                        protocol      = "tcp"
                    },
                ]
            },
            {
                name         = "db"
                image        = "postgres:11-alpine"
                cpu          = 0
                environment  = [
                    {
                        name  = "POSTGRES_PASSWORD"
                        value = var.db_password
                    },
                    {
                        name  = "POSTGRES_USER"
                        value = "postgres"
                    },
                    {
                        name  = "DD_ENV"
                        value = terraform.workspace
                    },
                    {
                        name  = "DATADOG_SERVICE_NAME"
                        value = "database"
                    },
                    {
                        name  = "DD_VERSION"
                        value = tostring(var.app_version)
                    },
                ]
                "dockerLabels": {
                  "com.datadoghq.tags.env": terraform.workspace,
                  "com.datadoghq.tags.service": "database",
                  "com.datadoghq.tags.version": tostring(var.app_version)
                }
                essential    = true
            },
            {
                name         = "advertisements"
                image        = var.ads_version[var.app_version]
                command      = [
                    "sh",
                    "docker-entrypoint.sh",
                ]
                cpu          = 0
                environment  = [
                    {
                        name  = "DD_SERVICE"
                        value = "advertisements"
                    },
                    {
                        name  = "DD_ENV"
                        value = terraform.workspace
                    },
                    {
                        name  = "DD_VERSION"
                        value = tostring(var.app_version)
                    },
                    {
                        name  = "DD_ANALYTICS_ENABLED"
                        value = "true"
                    },
                    {
                        name  = "DD_LOGS_INJECTION"
                        value = "true"
                    },
                    {
                        name  = "DD_PROFILING_ENABLED"
                        value = "true"
                    },
                    {
                        name  = "FLASK_APP"
                        value = "ads.py"
                    },
                    {
                        name  = "POSTGRES_PASSWORD"
                        value = var.db_password
                    },
                    {
                        name  = "POSTGRES_USER"
                        value = "postgres"
                    },
                ]
                "dockerLabels": {
                  "com.datadoghq.tags.env": terraform.workspace,
                  "com.datadoghq.tags.service": "advertisements",
                  "com.datadoghq.tags.version": tostring(var.app_version)
                }
                essential    = true
                links        = [
                    "db",
                ]
                portMappings = [
                    {
                        containerPort = 5002
                        hostPort      = 5002
                        protocol      = "tcp"
                    },
                ]
            },
            {
              name         = "traffic-replay"
              image        = "shermdog/datadog-ecommerce-ecs:traffic-replay"
              command      = [
                  "sh",
                  "docker-entrypoint.sh",
              ]
                cpu          = 0
                environment  = [
                    {
                        name  = "FRONTEND_HOST"
                        value = "${local.hostname}.${local.domain}"
                    },
                    {
                        name  = "FRONTEND_PORT"
                        value = "80"
                    },
                    {
                        name  = "DATADOG_SERVICE_NAME"
                        value = "traffic-replay"
                    },
                    {
                        name  = "DD_ENV"
                        value = terraform.workspace
                    },
                    {
                        name  = "DD_VERSION"
                        value = tostring(var.app_version)
                    },
                ]
                "dockerLabels": {
                  "com.datadoghq.tags.env": terraform.workspace,
                  "com.datadoghq.tags.service": "traffic-replay",
                  "com.datadoghq.tags.version": tostring(var.app_version)
                }
                essential    = true
                links        = [
                    "frontend",
                ]
                portMappings = []
            },
        ]
    )
    requires_compatibilities = [
        "EC2",
    ]
}

data "aws_ecs_cluster" "demo" {
  cluster_name = "rsherman_${local.env}"
}

data "aws_lb" "demo" {
  name = "rsherman-${local.env}"
}

data "aws_vpc" "demo" {
  tags = {
    env = local.env,
    Creator = "rick.sherman"
  }
}

data "aws_lb_listener" "demo" {
  load_balancer_arn = data.aws_lb.demo.arn
  port              = 80
}

resource "aws_lb_target_group" "demo" {
  name     = "rsherman-${terraform.workspace}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.demo.id
  deregistration_delay = 0

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 10
  }
}

resource "aws_lb_listener_rule" "demo" {
  listener_arn = data.aws_lb_listener.demo.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo.arn
  }

  condition {
    host_header {
      values = ["${local.hostname}.${local.domain}"]
    }
  }
}

resource "aws_ecs_service" "shop" {
  name            = "rsherman_${terraform.workspace}-shop"
  cluster         = data.aws_ecs_cluster.demo.arn
  task_definition = aws_ecs_task_definition.shop.arn
  force_new_deployment = true
  desired_count   = 1
  health_check_grace_period_seconds = 600

  load_balancer {
    target_group_arn = aws_lb_target_group.demo.arn
    container_name   = "frontend"
    container_port   = 3000
  }
}

resource "aws_route53_record" "demo" {
  zone_id = var.r53_zone
  name    = local.hostname
  type    = "A"

  alias {
    name                   = data.aws_lb.demo.dns_name
    zone_id                = data.aws_lb.demo.zone_id
    evaluate_target_health = false
  }
}

output "fqdn" {
  value = aws_route53_record.demo.fqdn
}
