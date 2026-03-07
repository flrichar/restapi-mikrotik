data "http" "records_count" {
  url    = "${var.api_uri}/rest/ip/dns/static/print"
  method = "POST"

  request_headers = {
    Accept        = "application/json"
    Authorization = "Basic ${base64encode("${var.username}:${var.password}")}"
  }

  request_body = jsonencode({
    "count-only" = true
  })
}

locals {
  api_data   = jsondecode(data.http.records_count.response_body)
  item_count = tonumber(local.api_data.ret)
}

output "total_records" {
  value = local.item_count
}

