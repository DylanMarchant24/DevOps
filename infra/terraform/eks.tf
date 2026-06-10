# ============================================================
# EKS CLUSTER - retail-microservices
# Reemplaza ec2.tf y ebs.tf del EP2
# ============================================================

# Obtener el rol LabRole provisto por AWS Academy
data "aws_iam_role" "labrole" {
  name = "LabRole"
}

# ------------------------------------------------------------
# EKS Cluster
# ------------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = data.aws_iam_role.labrole.arn

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public[*].id,
      aws_subnet.private[*].id
    )
    security_group_ids      = [aws_security_group.eks_sg.id]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = {
    Name = "${var.project_name}-eks-cluster"
  }
}

# ------------------------------------------------------------
# EKS Node Group (workers)
# ------------------------------------------------------------
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "workers"
  node_role_arn   = data.aws_iam_role.labrole.arn

  subnet_ids = aws_subnet.public[*].id

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  tags = {
    Name = "${var.project_name}-node-group"
  }
}
