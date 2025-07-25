variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "region" {
  description = "The region for our services"
  type        = string

}
# variable "environment" {
#   description = "The Environment we are using"
#   type = string
# }
#
variable "pub_sub_count" {
  description = "Number of public subnets"
  type        = number
}

variable "priv_sub_count" {
  description = "Number of private subnets"
  type        = number
}

variable "nat_count" {
  description = "Number of NAT gateways"
  type        = number
}
variable "eks_oidc_root_ca_thumbprint" {
  description = "eks_oidc_root_ca_thumbprint"
  type        = string
}
variable "eks_cluster_role_arn" {
  description = "eks_oidc_root_ca_thumbprint"
  type        = string
}
variable "eks_node_role_arn" {
  description = "eks_oidc_root_ca_thumbprint"
  type        = string
}
#variable "lbc_iam_role_arn" {
#  description = "eks_oidc_root_ca_thumbprint"
#  type        = string
#  default   = "arn:aws:iam::012889719104:role/admin_role"
#}
 


