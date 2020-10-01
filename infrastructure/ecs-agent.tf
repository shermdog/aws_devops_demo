resource "aws_ecs_task_definition" "agent" {
  family = "${terraform.workspace}-datadog-agent"
  requires_compatibilities = ["EC2"]
  container_definitions    = jsonencode(
      [
          {
              name            = "datadog-agent"
              image           = "datadog/agent:latest"              
              cpu             = 10
              environment     = [
                  {
                      name  = "DD_API_KEY"
                      value = var.dd_api_key
                  },
                  {
                      name  = "DD_ECS_COLLECT_RESOURCE_TAGS_EC2"
                      value = "true"
                  },
                  {
                      name  = "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL"
                      value = "true"
                  },
                  {
                      name  = "DD_LOGS_ENABLED"
                      value = "true"
                  },
                  {
                      name  = "DD_PROCESS_AGENT_ENABLED"
                      value = "true"
                  },
                  {
                      name  = "DD_SITE"
                      value = "datadoghq.com"
                  },
                  {
                      name  = "DD_SYSTEM_PROBE_ENABLED"
                      value = "true"
                  },
              ]
              essential       = true
              linuxParameters = {
                  capabilities = {
                      add = [
                          "SYS_ADMIN",
                          "SYS_RESOURCE",
                          "SYS_PTRACE",
                          "NET_ADMIN",
                      ]
                  }
              }
              memory          = 256
              mountPoints     = [
                  {
                      containerPath = "/var/run/docker.sock"
                      readOnly      = true
                      sourceVolume  = "docker_sock"
                  },
                  {
                      containerPath = "/host/sys/fs/cgroup"
                      readOnly      = true
                      sourceVolume  = "cgroup"
                  },
                  {
                      containerPath = "/host/proc"
                      readOnly      = true
                      sourceVolume  = "proc"
                  },
                  {
                      containerPath = "/opt/datadog-agent/run"
                      readOnly      = false
                      sourceVolume  = "pointdir"
                  },
                  {
                      containerPath = "/etc/passwd"
                      readOnly      = true
                      sourceVolume  = "passwd"
                  },
                  {
                      containerPath = "/sys/kernel/debug"
                      sourceVolume  = "debug"
                  },
              ]
              portMappings    = [
                  {
                      containerPort = 8126
                      hostPort      = 8126
                      protocol      = "tcp"
                  },
                  {
                      containerPort = 8125
                      hostPort      = 8125
                      protocol      = "tcp"
                  },
              ]
          },
      ]
  )

  volume {
    name      = "docker_sock"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name      = "proc"
    host_path = "/proc/"
  }

  volume {
    name      = "cgroup"
    host_path = "/sys/fs/cgroup/"
  }

  volume {
    name      = "pointdir"
    host_path = "/opt/datadog-agent/run"
  }

  volume {
    name      = "passwd"
    host_path = "/etc/passwd"
  }

  volume {
    name      = "debug"
    host_path = "/sys/kernel/debug"
  }
}

resource "aws_ecs_service" "agent" {
  name            = "${terraform.workspace}-agent"
  cluster         = aws_ecs_cluster.demo.id
  task_definition = aws_ecs_task_definition.agent.arn
  scheduling_strategy = "DAEMON"
}
