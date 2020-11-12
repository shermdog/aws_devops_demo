resource "aws_iam_role" "ecs_instance_role" {
    name                = "rsherman_ecsInstanceRole"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.ecs_instance_policy.json
}

data "aws_iam_policy_document" "ecs_instance_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

data "aws_iam_policy_document" "ecs_tag_policy" {
    statement {
        actions = ["ecs:ListTagsForResource"]

        resources = [
          "arn:aws:ecs:::*",
        ]
    }
}

resource "aws_iam_role_policy" "ecs_tag_policy" {
  name = "rsherman_ecs_tag_policy"
  role = aws_iam_role.ecs_instance_role.id

  policy = data.aws_iam_policy_document.ecs_tag_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
    role       = aws_iam_role.ecs_instance_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "session_manager_role_attachment" {
    role       = aws_iam_role.ecs_instance_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
    name = "rsherman_ecs-instance-profile"
    path = "/"
    role = aws_iam_role.ecs_instance_role.id
}
