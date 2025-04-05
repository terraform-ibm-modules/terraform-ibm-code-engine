# Configuring complex inputs for Code Engine in IBM Cloud projects

Several optional input variables in the IBM Cloud [Code Engine deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure deployable architecture.

* Builds (`builds`)
* Domain Mappings (`domain_mappings`)
* Config Maps (`config_maps`)
* Secrets (`secrets`)

## Builds <a name="builds"></a>

The `builds` input variable allows you to provide details of the of builds which you would like to create within the IBM Cloud projects.

- Variable name: `builds`.
- Type: A map of objects. Allows multiple objects representing builds to be created.
- Default value: An empty map (`{}`).

### Options for Builds

  - `output_image` (required): The name of the image.
  - `output_secret` (required): The secret that is required to access the image registry.
  - `source_url` (required): The URL of the code repository.
  - `strategy_type` (required): Specifies the type of source to determine if your build source is in a repository or based on local source code.
  - `source_context_dir`(optional): The directory in the repository that contains the buildpacks file or the Dockerfile.
  - `source_revision` (optional): Commit, tag, or branch in the source repository to pull.
  - `source_secret` (optional): The name of the secret that is used access the repository source. If the var.source_type value is `local`, this field must be omitted.
  - `source_type` (optional) : Specifies the type of source to determine if your build source is in a repository or based on local source code.
  - `strategy_size` (optional): The size for the build, which determines the amount of resources used.
  - `strategy_spec_file` (optional): The path to the specification file that is used for build strategies for building an image.
  - `timeout` (optional): The maximum amount of time, in seconds, that can pass before the build must succeed or fail.

### Example for Builds

```hcl
builds = {
  "your-build-name" = {
    output_image  = "container_registry_url"
    output_secret = "secret-name" # pragma: allowlist secret
    source_url    = "https://github.com/IBM/CodeEngine"
    strategy_type = "dockerfile"
  }
}
```


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
    tls_secret = "my-tls-secret" #pragma: allowlist secret
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
