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



provider "aws" {
  region  = var.region
  #profile = "devops"
}

# 2) Kubernetes provider, driven off those data sources
provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(
                             data.aws_eks_cluster.cluster
                               .certificate_authority[0].data
                           )
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

# 3) Helm provider, pointed at that same Kubernetes provider
provider "helm" {
  alias = "eks"

  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(
                               data.aws_eks_cluster.cluster
                                 .certificate_authority[0].data
                             )
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}
