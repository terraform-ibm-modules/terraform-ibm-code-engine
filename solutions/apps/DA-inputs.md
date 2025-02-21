# Configuring complex inputs for Code Engine in IBM Cloud projects

Several optional input variables in the IBM Cloud [Code Engine deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure deployable architecture.

* Domain Mappings (`domain_mappings`)
* Config Maps (`config_maps`)
* Secrets (`secrets`)

## Domain Mappings <a name="domain_mappings"></a>

The `domain_mappings` input variable allows you to provide the URL route to your Code Engine application or function within a project.

- Variable name: `domain_mappings`.
- Type: A map of objects. Allows multiple objects representing domain mappings to be created.
- Default value: An empty map (`{}`).

### Options for Domain Mappings

  - `component` (required): (List) A reference to another component.
  	- `name` (required): The name of the referenced component.
  	- `resource_type` (required): The type of the referenced resource.
  - `tls_secret` (required): The name of the TLS secret that includes the certificate and private key of this domain mapping.
  
### Example for Domain Mapping

```hcl
domain_mappings = {
  "www.example.com" = {
    components  = {
        name = "my-app-1"
        resource_type = "app_v2"
    }
    tls_secret = "my-tls-secret"
  }
}
```


## Config Maps <a name="config_maps"></a>

The `config_maps` input variable allows you to provide a method to include non-sensitive data information to your deployment.

- Variable name: `config_maps`.
- Type: A map of objects. Allows multiple objects representing config maps to be created.
- Default value: An empty map (`{}`).

### Options for Config Maps

  - `data` (required): (Map) The key-value pair for the config map.
  
### Example for Config Maps

```hcl
config_maps = {
  "your-config-name" = {
    data = { "key_1" : "value_1", "key_2" : "value_2" }
  }
}
```


## Secrets <a name="secrets"></a>

The `secrets` input variable allows you to provide a method to include sensitive configuration information, such as passwords or SSH keys, to your deployment.

- Variable name: `secrets`.
- Type: A map of objects. Allows multiple objects representing secrets to be created.
- Default value: An empty map (`{}`).

### Options for Secrets

 - `data` (required): (Map) The key-value pair for the secret.
 - `format` (required): (Map) Specify the format of the secret.
  

### Example for Secrets

```hcl
secrets = {
  "your-secret-name" = {
    format = "generic"
    data   = { "key_1" : "value_1", "key_2" : "value_2" }
  }
}
```