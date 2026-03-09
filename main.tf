## terraform.tfvars, or environment.tf

variable "username" {
  description = "basic-auth user"
  default     = "default-user"
  type        = string
}

variable "password" {
  description = "basic-auth pass"
  default     = "default-pass"
  type        = string
}

variable "api_uri" {
  description = "restapi-uri"
  default     = "https://some-fake-host.local"
  type        = string
}

variable "insecure" {
  description = "insecure-tls"
  default     = "true"
  type        = bool
}

variable "existing_records" {
  description = "previous existing-records"
  default     = ["NA"]
  type        = list(string)
}

# versions.tf 

terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "3.0.0"
      // refactor of provider 2026_0126
    }
  }

  backend "pg" {
    schema_name = "restapi-mikrotik"
  }
}

## providers.tf

provider "restapi" {
  uri      = var.api_uri
  username = var.username
  password = var.password
  insecure = var.insecure
}

# main.tf

data "restapi_object" "ip-dns-static-records" {
  for_each = toset(var.existing_records)

  path         = "/rest/ip/dns/static"
  search_key   = "name"
  search_value = each.key
  id_attribute = "name"
}

resource "null_resource" "backup-records" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "curl -k -u ${var.username}:${var.password} -X POST https://hexs760.gxize.local/rest/ip/dns/static/print > backup-records-$(date -I).json"
    quiet   = true
  }
}

output "searched_records" {
  description = "IP DNS Searched Static Record Data"
  value       = data.restapi_object.ip-dns-static-records[*]
}

output "backup_records" {
  description = "IP DNS Fetched Static Record Data"
  value       = null_resource.backup-records
}

##output "cname_records" {
##  value = data.restapi_object.ip-dns-static-enabled[*]
##}

