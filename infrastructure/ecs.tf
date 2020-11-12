resource "aws_ecs_cluster" "demo" {
  name = "rsherman_${terraform.workspace}"

  tags = {
    env = terraform.workspace,
    Creator = "rick.sherman",
    "terraform.managed" = "True"
  }
}
