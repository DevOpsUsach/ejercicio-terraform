resource "azurerm_resource_group" "diplomado-modulo5-s11" {
  name     = var.name
  location = var.location
  tags = {
    diplomado-terraform-ejercicio = "Sesión 11"
    owner                         = "Grupo 3 Sección 2"
  }

}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-diplomado"
  address_space       = ["12.0.0.0/16"]
  location            = azurerm_resource_group.diplomado-modulo5-s11.location
  resource_group_name = azurerm_resource_group.diplomado-modulo5-s11.name
}

resource "azurerm_subnet" "subnet-diplomado" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.diplomado-modulo5-s11.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["12.0.0.0/20"]
}


resource "azurerm_container_registry" "acr" {
  name                = "containerRegistryDiplomado"
  resource_group_name = azurerm_resource_group.diplomado-modulo5-s11.name
  location            = azurerm_resource_group.diplomado-modulo5-s11.location
  sku                 = "Basic"
  admin_enabled       = true

}

resource "azurerm_kubernetes_cluster" "kubernetescluster" {
  name                = "aksdiplomado"
  location            = azurerm_resource_group.diplomado-modulo5-s11.location
  resource_group_name = azurerm_resource_group.diplomado-modulo5-s11.name
  dns_prefix          = "aks1"
  kubernetes_version  = "1.22.4"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_D2_v2"
    vnet_subnet_id      = azurerm_subnet.subnet-diplomado.id
    enable_auto_scaling = true
    max_count           = 3
    min_count           = 1

  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  role_based_access_control_enabled = true


  service_principal {
    client_id     = "8c1b9268-b044-4e45-9a2d-66e6bad777ae"
    client_secret = "dz-8Q~acz11SFXlITOKM-6uDgM0w0OxOCRszzbfe"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "pooladicional" {

  name                  = "adicional"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetescluster.id
  vm_size               = "Standard_DS2_v2"
  max_pods              = 80

  node_labels = {
    "label" = "Adicional"
  }

  tags = {
    Environment = "Adicional"
  }
}



variable "name" {

}

variable "location" {

}

