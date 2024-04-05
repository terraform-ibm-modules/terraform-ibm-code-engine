
terraform {
  required_version = ">= 1.3.0, <1.7.0"
  # Ensure that there is always 1 example locked into the lowest provider version of the range defined in the main
  # module's version.tf (this example), and 1 example that will always use the latest provider version (jobs examples).
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.63.0"
    }
  }
}
