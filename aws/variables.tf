variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "m3.large"
}
variable "key_name" {
  description = "SSH Key Used To Connect"
  type        = string
  default     = "clientkey"
}
