

resource "kubernetes_storage_class" "ebs_aws" {
  metadata {
    name = "aws-sc" # Replace with a unique name for the StorageClass
  }

  storage_provisioner = "kubernetes.io/aws-ebs" # The provisioner for Amazon EBS PVs

  parameters = {
    type      = "gp2"   # The storage type, e.g., gp2, io1, etc.
    fsType    = "ext4"  # The file system type for the volume
    encrypted = "false" # Whether the volume should be encrypted (true or false)
  }

  depends_on = [aws_eks_node_group.main_nodegroup]
}