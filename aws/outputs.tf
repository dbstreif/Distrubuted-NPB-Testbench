
output "node1_pubip" {
  description = "Public IP of Node 1"
  value       = aws_instance.Node1.public_ip
}

output "node2_pubip" {
  description = "Public IP of Node 2"
  value       = aws_instance.Node2.public_ip
}

output "node3_pubip" {
  description = "Public IP of Node 3"
  value       = aws_instance.Node3.public_ip
}
