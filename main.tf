module "vpc" {
  source         = "./modules/terraform-aws-vpc"
  vpc_cidr       = var.vpc_cidr
  pub_sub_count  = var.pub_sub_count
  priv_sub_count = var.priv_sub_count
  nat_count      = var.nat_count
}
# module "alb" {
#   source = "./modules/terraform-aws-alb"
#   public_subnet_ids = module.vpc.public_subnet_ids
#   environment = var.environment
#   vpc_id = module.vpc.vpc_id
# }

module "eks" {
  source                      = "./modules/terraform-aws-eks"
  private_subnet_ids          = module.vpc.private_subnet_ids
  public_subnet_ids           = module.vpc.public_subnet_ids
  cluster_role_arn            = module.iam.eks_cluster_role_arn
  node_role_arn               = module.iam.eks_node_role_arn
  eks_oidc_root_ca_thumbprint = var.eks_oidc_root_ca_thumbprint
  cluster_role_dependency     = module.iam.eks_role_depends_on
  vpc_id                      = module.vpc.vpc_id
  depends_on = [module.vpc]
}

resource "kubernetes_config_map" "aws_auth" {
  depends_on = [module.eks]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<YAML
- rolearn: ${module.iam.eks_node_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
# (optional) your debug role:
- rolearn: arn:aws:iam::012889719104:role/admin_role
  username: admin
  groups:
    - system:masters
YAML
  }
}


#module "apps" {
#  source = "./modules/terraform-aws-apps"
#}


module "iam" {
  source                                           = "./modules/terraform-aws-iam"
  aws_iam_openid_connect_provider_arn              = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_extract_from_arn = module.eks.aws_iam_openid_connect_provider_extract_from_arn
}


module "helm" {
  source                             = "./modules/terraform-aws-helm"
  cluster_id                         = module.eks.cluster_id
  #cluster_endpoint                   = module.eks.cluster_endpoint
  #cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  lbc_iam_depends_on                 = module.iam.lbc_iam_depends_on
  lbc_iam_role_arn                   = module.iam.lbc_iam_role_arn
  vpc_id                             = module.vpc.vpc_id
  region                             = var.region
  #depends_on = [module.eks]
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
}
