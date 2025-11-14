output "node_privips" {
  description = "A list of the priv IP addresses for all 3 nodes."
  value       = aws_instance.Node[*].private_ip
}

output "node_pubips" {
  description = "A list of the priv IP addresses for all 3 nodes."
  value       = aws_instance.Node[*].public_ip
}
