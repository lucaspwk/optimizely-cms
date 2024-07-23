variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "logifuture-eks"
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "The desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "The maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "The minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "kubeconfig_path" {
  description = "Kubeconfig profile"
  type        = string
  default     = "/mnt/c/Users/Lucas/.kube/.kubeconfig-AWS-LOCALTEST"
}