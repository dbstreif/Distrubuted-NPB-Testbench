variable "instance1_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "NPBTest1"
}
variable "instance2_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "NPBTest2"
}
variable "instance3_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "NPBTest3"
}

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
