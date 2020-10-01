resource "datadog_monitor" "apm_service_high_error_rate" {
  for_each           = var.monitors ? var.services : {}
  name               = "Service ${each.key} has a high error rate on env:${terraform.workspace}"
  type               = "query alert"
  message            = "Service ${each.key} has a high error rate. ${local.env == "production" ? "@slack-alerts" : ""}"
  escalation_message = local.env == "production" ? "Service ${each.key} has a high error rate!! @pagerduty-${each.key}" : null
  renotify_interval  = local.env == "production" ? 30 : null

  query = "sum(last_10m):( sum:trace.${each.value.framework}.request.errors{env:${terraform.workspace},service:${each.key}}.as_count() / sum:trace.${each.value.framework}.request.hits{env:${terraform.workspace},service:${each.key}}.as_count() ) > ${each.value.high_error_rate_critical}"

  thresholds = {
    warning  = each.value.high_error_rate_warning
    critical = each.value.high_error_rate_critical
  }

  notify_no_data    = false

  notify_audit = false
  timeout_h    = 0
  include_tags = true

  tags = ["service:${each.key}", "env:${terraform.workspace}"]
}

resource "datadog_monitor" "apm_service_high_avg_latency" {
  for_each           = var.monitors ? var.services : {}
  name               = "Service ${each.key} has a high average latency on env:${terraform.workspace}"
  type               = "query alert"
  message            = "Service ${each.key} has a high average latency. ${local.env == "production" ? "@slack-alerts" : ""}"
  escalation_message = local.env == "production" ? "Service ${each.key} has a high average latency!! @pagerduty-${each.key}" : null
  renotify_interval  = local.env == "production" ? 30 : null

  query = "avg(last_10m):( sum:trace.${each.value.framework}.request.duration{env:${terraform.workspace},service:${each.key}}.rollup(sum).fill(zero) / sum:trace.${each.value.framework}.request.hits{env:${terraform.workspace},service:${each.key}}.rollup(sum).fill(zero) ) > ${each.value.high_avg_latency_critical}"

  thresholds = {
    warning  = each.value.high_avg_latency_warning
    critical = each.value.high_avg_latency_critical
  }

  notify_no_data    = false

  notify_audit = false
  timeout_h    = 0
  include_tags = true

  tags = ["service:${each.key}", "env:${terraform.workspace}"]
}

resource "datadog_monitor" "apm_service_high_p90_latency" {
  for_each           = var.monitors ? var.services : {}
  name               = "Service ${each.key} has a high p90 latency on env:${terraform.workspace}"
  type               = "query alert"
  message            = "Service ${each.key} has a high p90 latency. ${local.env == "production" ? "@slack-alerts" : ""}"
  escalation_message = local.env == "production" ? "Service ${each.key} has a high p90 latency!! @pagerduty-${each.key}" : null
  renotify_interval  = local.env == "production" ? 30 : null

  query = "avg(last_10m):avg:trace.${each.value.framework}.request.duration.by.service.90p{env:${terraform.workspace},service:${each.key}} > ${each.value.high_p90_latency_critical}"

  thresholds = {
    warning  = each.value.high_p90_latency_warning
    critical = each.value.high_p90_latency_critical
  }

  notify_no_data    = false

  notify_audit = false
  timeout_h    = 0
  include_tags = true

  tags = ["service:${each.key}", "env:${terraform.workspace}"]
}
