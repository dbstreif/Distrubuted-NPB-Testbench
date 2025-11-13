variable "vm_size" {
  description = "The VM's size."
  type        = string
  default     = "Standard_B4ms"
}
variable "ssh_key_name" {
  description = "The name of the SSH Key resource in Azure."
  type        = string
  default     = "clientkey"
}
variable "ssh_key_rg_name" {
  description = "The name of the SSH Key resource in Azure."
  type        = string
  default     = "NpbTestbench"
}
variable "admin_username" {
  description = "Administrator username for the VM."
  default     = "ubuntu"
}
