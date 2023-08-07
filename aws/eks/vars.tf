variable "env" {
  description = "Environment"
}

variable "vpc" {
  description = "VPC"
}

variable "keypair" {
  description = "Key pair for EC2"
}

variable "clustername" {
  description = "Name of EKS Cluster"
}

variable "num_node" {
  description = "Number of node"
}

variable "min_node" {
  description = "Minimum of node group"
}

variable "max_node" {
  description = "Maximum of node group"
}
