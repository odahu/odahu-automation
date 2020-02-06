########################################################
# Bastion host
########################################################

# We could't provide multiple SSH public keys during VM host creation.
# So, we'll generate key for deployment and add one more key later.
resource "tls_private_key" "bastion_deploy" {
  count     = var.bastion_enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = "2048"
}

locals {
  deploy_pubkey = var.bastion_enabled ? tls_private_key.bastion_deploy[0].public_key_openssh : null
}

# We going to create bastion host in AKS subnet
resource "azurerm_network_interface" "aks_bastion_nic" {
  count               = var.bastion_enabled ? 1 : 0
  name                = "${var.cluster_name}-${var.bastion_hostname}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.cluster_name}-bastion-ip"
    subnet_id                     = var.aks_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.bastion_ip_id
  }
}

resource "azurerm_virtual_machine" "aks_bastion" {
  count                 = var.bastion_enabled ? 1 : 0
  name                  = "${var.cluster_name}-${var.bastion_hostname}"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.aks_bastion_nic[0].id]
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
    name              = "${var.cluster_name}-${var.bastion_hostname}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-${var.bastion_hostname}"
    admin_username = var.bastion_ssh_user
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.bastion_ssh_user}/.ssh/authorized_keys"
      key_data = local.deploy_pubkey
    }
  }

  tags = var.bastion_labels
}
