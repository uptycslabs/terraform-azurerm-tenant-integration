# Terraform Azure module - Tenant Integration for Uptycs

This module provides the required Azure resources to integrate an Azure Tenant with Uptycs.

It integrates multiple child subscriptions available under the Azure Tenant.

## Prerequisites [Do Not Skip]

Ensure you have the following privileges before you execute the Terraform Script:

- Administrative roles:
  - `Privileged Role Administrator` (AD Role)
  - `Application Administrator` (AD Role)
- `Owner` role at the Root Management Group scope

  For more information on how to enable Access Control (IAM) for Root Management Group, refer to [this link](https://learn.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin).

Absence of the above privileges may result in access related issues when trying to run the Terraform.

## What does the Terraform do?

Running the Terraform creates a new **Service Principal** corresponding to Uptycs's Multi-Tenant App Registration. It assigns below Roles/Permissions/Policies to it at the scope of the Root Management Group. Uptycs requires these set of Roles/Permissions to be able to fetch the required information from your Tenant:

**Roles**:

- Reader
- Key Vault Reader
- Storage Blob Data Reader
- Azure Event Hubs Data Receiver
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

**Policy**:

- Key Vault Access Policy (certificate_permissions : List, Get)

## Authentication

To authenticate Azure tenant, use the following command:

```
$ az login --tenant "tenant id"
```

## Terraform Script

To execute the Terraform script:

### Step-1: Prepare .tf file

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

Specify the following parameters in the Terraform file:

| Name                         | Description                                                          | Type     | Default                 |
| ---------------------------- | -------------------------------------------------------------------- | -------- | ----------------------- |
| resource_name                | The names of the new resources                                       | `string` | `UptycsIntegration-123` |
| set_tenant_level_permissions | The flag to choose permissions at tenant level or subscription level | `bool`   | `true`                  |
| root_management_group_id     | The ID of the root management group                                  | `string` | Required                |
| uptycs_app_client_id         | The Client ID of Uptycs multi-tenant app                             | `string` | Required                |

### Step-2: Terraform Init, Plan and Apply

Execute the below commands in your terminal:

```
$ terraform init --upgrade
$ terraform plan  # Please verify before applying
$ terraform apply
# Wait until successfully completed
```

### Step-3: Outputs

After running the Terraform, the following outputs are generated, which you need to add in the Uptycs Integration Page:

| Name     | Description |
| -------- | ----------- |
| tenantId | Tenant ID   |
