# Restapi-Mikrotik
Manage Mikrotik routers and devices using the Mastercard rest-api terraform provider.

## Description
The purpose of this terraform plan is to automate DNS settings on Mikrotik devices.  There are other Mikrotik providers [like this one from DDelano](https://github.com/ddelnano/terraform-provider-mikrotik), and it worked well, however it turns out Routeros has a basic REST API manageable via a normal curl-type operations.

Mastercard has their own [terraform provider for standard restapi](https://github.com/Mastercard/terraform-provider-restapi) which in simplest terms is what was needed above, emulating curl with terraform.  It is stable and well tested.

This evloved from a conversation about managing kube-vip dns records, and [this gist](https://gist.github.com/flrichar/9bc14ddfb517ab79cc02e3b6c19a36dc), where the question to answer was: _Can terraform operate like curl on a standard rest-api, without using a tool like `local-exec`?_

Note this is not limited to DNS records, it can handle any Mikrotik configuration operation, this project is focused on DNS records as a learning and evaluation example. 

### General Benefits
* still very much a work in progress
* simple basic-auth
* insecure mode for self-signed certificates
* `exsisting-records` list for pre-existing records outside of terraform
* import optional because of pre-existing records list

### Operation
Right now it just reads local records by name and puts them into the tfstate, in a local statefile for example. The field `name` was chosen over `.id` because Mikrotik tracks records internally with each records' `.id` ... it made sense to choose the name field to prevent collisions.

### Pre-Exsiting Records
We needed a quick way to add in records which may have existed prior to managing them with Terraform.  The list in the environment or `terraform.tfvars` file allows spliting into two groups, between records managed by terraform, and those that are not.  
Instead of counting exising records, it does rely on knowing how many are currently available and placing them in the variable list.

## TODO
* CRUD operations with each record resource
* backup and restore records
* count of existing records
* categorize by tf-managed and tf-unmanaged records

## What is the purpose?
* demonstrate simple REST-API terraform calls
* alternative to `curl` or `local-exec` commands
* quick way to adjust isolated Mikrotik configs, ie DNS Records
