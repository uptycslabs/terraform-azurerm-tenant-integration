# Terraform Azure module - Tenant Integration for Uptycs

This module provides the required Azure resources to integrate an Azure Tenant with Uptycs.

It integrates multiple child subscriptions available under the Azure Tenant.

## Prerequisites [Do Not Skip]

Ensure you have the following privileges before you execute the Terraform Script:

- Administrative roles:
  - `Privileged Role Administrator` (AD Role)
  - `Application Administrator` (AD Role)
- `Owner` role at the Root Management Group scope

  For more information visit: [https://learn.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin]

Absence of the above privileges will result in Access related issues when trying to run the Terraform.

## What does the Terraform do?

Terraform is going to create a new <u>**Service Principal**</u> corresponding to our Multi-Tenant App Registration and assign below Roles/Permissions/Policies to it. Uptycs requires these set of Roles/Permissions to be able to fetch the required information from your Tenant:

**Roles**:

- Reader
- Key Vault Reader
- Storage Blob Data Reader
- Storage Account Key Operator Service Role
- Custom read-only access for required resources

**API permissions**:

- Directory.Read.All
- Organization.Read.All
- User.Read.All
- Group.Read.All
- OnPremisesPublishingProfiles.ReadWrite.All
- Application.Read.All
- UserAuthenticationMethod.Read.All
- Policy.Read.All

**Policies**:

- Key Vault Access Policy (certificate_permissions : List, Get)

## Authentication

To authenticate Azure tenant, use the following command:

```
$ az login --tenant "tenant id"
```

## Terraform Script

To execute the Terraform script:

### 1. Prepare .tf file

Create a `main.tf` file in a new folder. Copy and paste the following configuration and modify as required:

```
module "azure-org-config" {
    source = "uptycslabs/tenant-integration/azurerm"

    # modify as per your requirement
    resource_name = "UptycsIntegration-123"

    # Set this to true if you want to give permission at organization level for auto-integration of new accounts
    # Set this to false if you want to give permissions per child subscription

    set_tenant_level_permissions = true

    root_management_group_id = "ID of the root management group in a tenant"

    # Find the client_id on Azure Integration page of Uptycs Web
    uptycs_app_client_id = "Client ID from Azure Integration page"
}

output "tenant_id" {
    value = module.azure-org-config.tenantId
}
```

### 2. Init, Plan and Apply

**Inputs**

| Name                         | Description                                                          | Type     | Default                 |
| ---------------------------- | -------------------------------------------------------------------- | -------- | ----------------------- |
| resource_name                | The names of the new resources                                       | `string` | `UptycsIntegration-123` |
| set_tenant_level_permissions | The flag to choose permissions at tenant level or subscription level | `bool`   | `true`                  |
| root_management_group_id     | The ID of the root management group                                  | `string` | Required                |
| uptycs_app_client_id         | The Client ID of Uptycs multi-tenant app                             | `string` | Required                |

```
$ terraform init --upgrade
$ terraform plan  # Please verify before applying
$ terraform apply
# Wait until successfully completed
```

### 3.Outputs

| Name     | Description |
| -------- | ----------- |
| tenantId | Tenant ID   |
