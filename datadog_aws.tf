resource "datadog_integration_aws" "rick_demo" {
    account_id = var.aws_account_id
    role_name = "rsherman_DatadogAWSIntegrationRole"
    filter_tags = ["Creator:rick.sherman"]
}

data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }
    condition {
      test = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        datadog_integration_aws.rick_demo.external_id
      ]
    }
  }
}

resource "aws_iam_policy" "datadog_aws_integration" {
  name = "rsherman_DatadogAWSIntegrationPolicy"
  policy = file("${path.module}/datadog_iam_all.json")
}

resource "aws_iam_role" "datadog_aws_integration" {
  name = datadog_integration_aws.rick_demo.role_name
  description = "Role for Datadog AWS Integration"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_integration_assume_role.json
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}
