resource "azurerm_user_assigned_identity" "aks" {
  name                = "${terraform.workspace}-aks-usi"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_role_assignment" "owner" {
  principal_id   = azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Owner"
  scope          = data.azurerm_subscription.greg.id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "aks_admin" {
  principal_id   = azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  scope          = data.azurerm_subscription.greg.id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "rbac_admin" {
  principal_id   = azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope          = data.azurerm_subscription.greg.id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "contributor" {
  principal_id   = azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Contributor"
  scope          = data.azurerm_subscription.greg.id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "user_admin" {
  principal_id   = azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "User Access Administrator"
  scope          = data.azurerm_subscription.greg.id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "net_admin" {
  principal_id   = azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Network Contributor"
  scope          = data.azurerm_subscription.greg.id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "vault_admin" {
  principal_id   = azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Key Vault Contributor"
  scope          = data.azurerm_subscription.greg.id
  principal_type       = "ServicePrincipal"
}
