
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.79.2"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
  }
}
