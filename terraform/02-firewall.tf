# IP público de quem roda o terraform
data "http" "meu_ip" {
  url = "https://api.ipify.org"
}

# Faixas de origem dos webhooks do GitHub
data "http" "github_meta" {
  url = "https://api.github.com/meta"
}

locals {
  meu_ip       = "${chomp(data.http.meu_ip.response_body)}/32"
  github_hooks = [for c in jsondecode(data.http.github_meta.response_body).hooks : c if !strcontains(c, ":")]
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${local.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  # SSH, SonarQube e app: só do meu IP
  security_rule {
    name                       = "admin"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "9000", "8000"]
    source_address_prefix      = local.meu_ip
    destination_address_prefix = "*"
  }

  # Jenkins: meu IP + webhooks do GitHub
  security_rule {
    name                       = "jenkins"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefixes    = concat([local.meu_ip], local.github_hooks)
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}
