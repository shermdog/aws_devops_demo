data "aws_ami" "azl_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "rsherman_ecs-instance-profile"
}

resource "aws_launch_template" "demo" {
  name = "rsherman_${terraform.workspace}"
  image_id = data.aws_ami.azl_ecs.id
  instance_type = "m5a.xlarge"
  instance_initiated_shutdown_behavior = "terminate"
  key_name = var.key_pair

  iam_instance_profile {
    arn = data.aws_iam_instance_profile.ecs_instance_profile.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.alb_to_shop.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=rsherman_${terraform.workspace} >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
    EOF
    )

  tags = {
    env = terraform.workspace,
    Creator = "rick.sherman",
    "terraform.managed" = "True"
  }
}

resource "aws_autoscaling_group" "demo" {
  name                 = "rsherman_${terraform.workspace}"
  vpc_zone_identifier  = aws_subnet.demo.*.id
  min_size             = 0
  desired_capacity     = terraform.workspace == "development" ? 4 : 2
  max_size             = 4

  launch_template {
    id      = aws_launch_template.demo.id
    version = "$Latest"
  }

  # mixed_instances_policy {
  #   instances_distribution {
  #     on_demand_base_capacity = 0
  #     on_demand_percentage_above_base_capacity = 0
  #     spot_max_price = 0.008
  #   }
  #
  #   launch_template {
  #     launch_template_specification {
  #       launch_template_id = aws_launch_template.demo.id
  #       version = "$Latest"
  #     }
  #     override {
  #       instance_type = "t3a.small"
  #     }
  #
  #     override {
  #       instance_type = "t3a.medium"
  #     }
  #   }
  # }


  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "Creator"
    value               = "rick.sherman"
    propagate_at_launch = true
  }
}
