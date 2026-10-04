# Terraform Input Variables for Scalable Infrastructure

variable "instance_count" {
  description = "Number of backend web servers to create"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "Host port for accessing the load balancer"
  type        = number
  default     = 8080
}
