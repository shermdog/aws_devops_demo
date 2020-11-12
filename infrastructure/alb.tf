resource "aws_lb" "demo" {
  name               = "rsherman-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rick.id]
  subnets            = aws_subnet.demo.*.id

  tags = {
    env = terraform.workspace,
    Creator = "rick.sherman"
  }
}

resource "aws_lb_listener" "demo" {
  load_balancer_arn = aws_lb.demo.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}
