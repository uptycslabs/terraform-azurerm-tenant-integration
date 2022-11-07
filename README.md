# Terraform Azure module - Organization Integration for Uptycs

This module provides the required Azure resources to integrate an Azure Tenant with Uptycs.

It integrates multiple child subscriptions available under the Azure Tenant.

It creates the following resources:
* Application
* Service principal to the application
* It attaches the following roles and permissions to the service principal:
  
  **Roles**:
  - Reader
  - Key Vault Reader
  - Storage Account Key Operator Service Role
  - Custom read-only access for required resources
  
  **API permissions**:
  - Directory.Read.All
  - Organization.Read.All
  
  **Policies**:
  - Key Vault Access Policy (secret_permissions : List)

## Prerequisites

Ensure you have the following privileges before you execute the Terraform Script:

* User Access Administrator Role to the Root
* Administrative roles:
  * Application administrator
  * Directory readers
  * Global administrator

## Authentication

To authenticate Azure tenant, use the following command:

```
$ az login --tenant <tenant id>
```

## Terraform Script

To execute the Terraform script:

1. **Prepare .tf file**

   Create a `main.tf` file in a new folder. Copy and paste the following configuration and modify as required:

   ```
   module "azure-org-config" {
       source = "github.com/uptycslabs/terraform-azurerm-tenant-integration"

       # modify as per your requirement
       resource_name = "uptycs-cloudquery-integration-123"

       # Set this to true if you want to give permission at organization level
       # Set this to false if you want to give permissions per child subscription

       set_org_level_permissions = false

       parent_management_group_name = "<ID of the parent management group in a tenant>"
   }

   output "tenant_id" {
       value = module.azure-org-config.tenantId
   }
   ```

2. **Init, Plan and Apply**

   **Inputs**

   | Name                         | Description                                                          | Type     | Default                             |
   | ---------------------------- | -------------------------------------------------------------------- | -------- | ----------------------------------- |
   | resource_name                | The names of the new resources                                       | `string` | `uptycs-cloudquery-integration-123` |
   | set_org_level_permissions    | The flag to choose permissions at tenant level or subscription level | `bool`   | `true`                              |
   | parent_management_group_name | The ID of the root management group                                  | `string` | Required                            |

   ### Outputs

   | Name     | Description |
   | -------- | ----------- |
   | tenantId | Tenant ID   |

   ```
   $ terraform init
   $ terraform plan  # Please verify before applying
   $ terraform apply
   # Once terraform successfully applied, it will create "credentials.json" file
   ```
