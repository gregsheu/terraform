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

variable "eks_version" {
  default = "1.27"
  description = "default eks version"
}
