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
      // newest provider 2026_0309
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

// check for existing records
data "restapi_object" "ipdns_existingrecords" {
  for_each = toset(var.existing_records)

  path         = "/rest/ip/dns/static"
  search_key   = "name"
  search_value = each.key
  id_attribute = "name"
}


##// search one record at a time
##data "restapi_object" "ipdns_staticrecord" {
##
##  path         = "/rest/ip/dns/static"
##  search_key   = "dynamic"
##  search_value = "false"
##  id_attribute = ".id"
##}


// read out static records
data "http" "ipdns_staticrecords" {
  url    = "${var.api_uri}/rest/ip/dns/static/print"
  method = "POST"

  request_headers = {
    Accept        = "application/json"
    Authorization = "Basic ${base64encode("${var.username}:${var.password}")}"
  }
}

resource "local_file" "all_records" {

  content         = data.http.ipdns_staticrecords.response_body
  filename        = "${path.module}/output/ipdns_staticrecords_${formatdate("YYYY-MM-DD", plantimestamp())}.json"
  file_permission = "0644"
}

# outputs.tf

output "searched_records" {
  description = "IP DNS Searched Static Record Data"
  value       = data.http.ipdns_staticrecords.response_body
}

