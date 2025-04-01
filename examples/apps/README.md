# Apps example

An end-to-end apps example that will provision the following:
- A new resource group if one is not passed in.
- Code Engine project
- Code Engine App
- Code Engine Config Map
- Code Engine TLS Secret
- Code Engine Domain Mapping
- Secrets Manager Resources (Public Engine, Group, Public Certificate)
- A Virtual Private Cloud (VPC).
- A context-based restriction (CBR) rule to allow Code Engine to be accessible from VPC and Schematics.
