# Repositorio ECR: Backend Despachos
resource "aws_ecr_repository" "back_despachos" {
  name                 = "ecr-back-despachos"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr-despachos"
  }
}

# Repositorio ECR: Backend Ventas
resource "aws_ecr_repository" "back_ventas" {
  name                 = "ecr-back-ventas"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr-ventas"
  }
}

# Repositorio ECR: Frontend
resource "aws_ecr_repository" "front_despacho" {
  name                 = "ecr-front-despacho"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr-frontend"
  }
}
