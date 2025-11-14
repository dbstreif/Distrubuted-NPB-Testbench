output "node_privips" {
  description = "A list of the private IP addresses for all 3 nodes."
  value       = azurerm_network_interface.npb-Nic[*].private_ip_address
}

output "node_pubips" {
  description = "A list of the public IP addresses for all 3 nodes."
  value       = azurerm_public_ip.npb-PubIp[*].ip_address
}
