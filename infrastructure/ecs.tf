resource "aws_ecs_cluster" "demo" {
  name = terraform.workspace

  tags = {
    env = terraform.workspace
  }
}
