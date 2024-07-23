provider "aws" {
  region = "eu-west-1"
}

provider "helm" {
  kubernetes {
    config_path = "/mnt/c/Users/Lucas/.kube/.kubeconfig-AWS-LOCALTEST"
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #provider "kubernetes" {
  config_path = var.kubeconfig_path
#}
}

terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}