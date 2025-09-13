# Terraform Modules Monorepo

This repository contains multiple Terraform modules that can be reused across your projects for infrastructure automation. Each module is located in its own directory and can be used independently.

## Usage

To use one of the modules in your project, you can include it in your Terraform configuration as follows:

```hcl
module "app_configuration" {
  source = "git::https://github.com/riftonix/terraform-shared.git//modules/helm-release?ref=helm-release/1.0.0"
  ...
}
```

### Example

Here's an example of how to use the `gitlab-project` module in your project:

1. Include the module in your Terraform project:

    ```hcl
    module "my_gitlab_repo" {
      source = "git::https://github.com/riftonix/terraform-shared.git//modules/helm-release?ref=helm-release/1.0.0"
      ...
    }
    ```

2. Run `terraform init` to initialize the module.
3. Set the required variables used in the module in your project's variable files or through the command line.
4. Apply the changes using `terraform apply`.
