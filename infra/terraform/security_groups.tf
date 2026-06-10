# ============================================================
# SECURITY GROUPS
# EP3: Se eliminan los SG de EC2 frontend/backend
#      Se agrega el SG del cluster EKS
# ============================================================

# Security Group del ALB (tráfico público HTTP)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Permitir trafico HTTP/HTTPS entrante al ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP desde Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS desde Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Security Group del clúster EKS
# Permite tráfico entre nodos y desde el ALB
resource "aws_security_group" "eks_sg" {
  name        = "${var.project_name}-eks-sg"
  description = "SG para nodos EKS y comunicacion interna del cluster"
  vpc_id      = aws_vpc.main.id

  # Tráfico entre nodos del clúster (necesario para K8s)
  ingress {
    description = "Comunicacion interna entre nodos"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Tráfico desde el ALB hacia los pods (puertos altos de NodePort)
  ingress {
    description     = "Trafico desde ALB a NodePort"
    from_port       = 30000
    to_port         = 32767
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Puerto 443 para kubectl (API server de EKS)
  ingress {
    description = "HTTPS hacia API server EKS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-sg"
  }
}
