# Terraform Azure module - Organization Integration for Uptycs

* This module provides the required azure resources to integrate an Azure Tenant with Uptycs.
* It integrates multiple child subscriptions available under the Azure Tenant.
* It creates the following resources:-
  * Application
  * Service principal to the application
  * It will attach the following roles and permissions to the service principal
    * **Roles** :

      1. Reader
      2. Key Vault Reader
      3. Storage Account Key Operator Service Role
      4. Custom Readonly access for required resources
    * **API permissions** :

      1. Directory.Read.All
      2. Organization.Read.All
    * **Policies** :

      1. Keyvault Access Policy( secret_permissions : List)

## Prerequisites

Ensure that you have the following privileges, before you execute the Terraform Script:

* The following privileges are required:
  * User Access Administrator Role to the Root
  * Administrative roles :
    * Application administrator
    * Directory readers
    * Global administrator

## 1. Authentication

```
$ az login --tenant <tenant id>
```

## Terraform Script

To execute the Terraform script:

1. **Prepare .tf file:**

   Create a main.tf file in a new folder. Copy and paste the following configuration and modify as required:

   ```
   module "azure-org-config" {
       source = "github.com/uptycslabs/terraform-azurerm-ad-org-integration"

       # modify as you need
       resource_name = "uptycs-cloudquery-integration-123"

       # Set this to true If you want to give permission at organization level
       # Set this to false otherwise (If you want to give permissions per child subscription)

       set_org_level_permissions = false

       parent_management_group_name = "<ID of the parent management group in a tenant>"
   }

   output "tenant_id" {
       value = module.azure-org-config.tenantId
   }
   ```

2. **Init, Plan and Apply**

### Inputs


| Name                         | Description                                                          | Type     | Default                             |
| ------------------------------ | ---------------------------------------------------------------------- | ---------- | ------------------------------------- |
| resource_name                | Used to naming the new resources                                     | `string` | `uptycs-cloudquery-integration-123` |
| set_org_level_permissions    | The flag to choose permissions at tenant level or subscription level | `bool`   | `true`                              |
| parent_management_group_name | ID of the root management group                                      | `string` | Required                            |

### Outputs


| Name     | Description |
| ---------- | ------------- |
| tenantId | TenantId    |

```
$ terraform init
$ terraform plan  # Please verify before applying
$ terraform apply
# Once terraform successfully applied, it will create "credentials.json" file
```
