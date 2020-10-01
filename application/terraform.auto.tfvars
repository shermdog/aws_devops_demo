services = {
  store-frontend = {
    framework                 = "rack"
    high_error_rate_critical  = 0.05
    high_error_rate_warning   = 0.01
    high_avg_latency_critical = 3
    high_avg_latency_warning  = 1
    high_p90_latency_critical = 5
    high_p90_latency_warning  = 3
  }
  discounts-service = {
    framework                 = "flask"
    high_error_rate_critical  = 0.05
    high_error_rate_warning   = 0.01
    high_avg_latency_critical = 2
    high_avg_latency_warning  = 1
    high_p90_latency_critical = 4
    high_p90_latency_warning  = 2
  }
  advertisements = {
    framework                 = "flask"
    high_error_rate_critical  = 0.05
    high_error_rate_warning   = 0.01
    high_avg_latency_critical = 2
    high_avg_latency_warning  = 1
    high_p90_latency_critical = 4
    high_p90_latency_warning  = 2
  }

}
