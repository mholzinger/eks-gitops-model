# Fetch the IAM policy for the EBS CSI Driver
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Create an IAM role for the EBS CSI Driver using IRSA (IAM Roles for Service Accounts)
module "irsa-ebs-csi" {
  # Use the shared IAM module
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.53.0"        # Use version 5.53.0 of the IAM module

  create_role = true                                               # Create a new IAM role
  role_name   = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}" # Unique role name based on the cluster name

  # Use the OIDC provider URL from the EKS cluster
  provider_url = module.eks.oidc_provider

  # Attach the EBS CSI Driver policy to the role
  role_policy_arns = [data.aws_iam_policy.ebs_csi_policy.arn]

  # Define the service account that will assume this role
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

