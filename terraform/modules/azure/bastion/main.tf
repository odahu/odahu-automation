########################################################
# Bastion host
########################################################

# We could't provide multiple SSH public keys during VM host creation.
# So, we'll generate key for deployment and add one more key later.
resource "tls_private_key" "bastion_deploy" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

locals {
  deploy_pubkey = tls_private_key.bastion_deploy.public_key_openssh
}

# We going to create bastion host in AKS subnet
resource "azurerm_network_interface" "aks_bastion_nic" {
  name                = "${var.bastion_hostname}-${var.cluster_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "bastion-public-ip"
    subnet_id                     = var.aks_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

resource "azurerm_virtual_machine" "aks_bastion" {
  name                  = "${var.bastion_hostname}-${var.cluster_name}"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [ azurerm_network_interface.aks_bastion_nic.id ]
  vm_size               = var.bastion_machine_type

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  storage_os_disk {
    name              = "${var.bastion_hostname}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  
  os_profile {
    computer_name  = "${var.bastion_hostname}-${var.cluster_name}"
    admin_username = var.bastion_ssh_user
  }
  
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.bastion_ssh_user}/.ssh/authorized_keys"
      key_data = local.deploy_pubkey
    }
  }
  
  tags = var.bastion_tags
}