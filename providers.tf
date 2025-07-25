# Terraform Block
terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}
# Datasource: EKS Cluster Auth 
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}


# Kubernetes Provider
provider "kubernetes" {
  alias                   = "eks"
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  depends_on = [
    module.eks
  ]
}

# HELM Provider
provider "helm" {
  alias = "eks"
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
  depends_on = [
    module.eks
  ]
}

provider "aws" {
  region  = var.region
  #profile = "devops"
}
