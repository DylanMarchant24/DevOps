# ============================================================
# OUTPUTS
# EP3: Se reemplazan outputs de EC2 por outputs de EKS
# ============================================================

output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS del Application Load Balancer (URL pública del Frontend)"
  value       = aws_lb.main.dns_name
}

output "eks_cluster_name" {
  description = "Nombre del clúster EKS"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint del API server del clúster EKS"
  value       = aws_eks_cluster.main.endpoint
}

output "ecr_back_despachos_url" {
  description = "URI del repositorio ECR para Back Despachos"
  value       = aws_ecr_repository.back_despachos.repository_url
}

output "ecr_back_ventas_url" {
  description = "URI del repositorio ECR para Back Ventas"
  value       = aws_ecr_repository.back_ventas.repository_url
}

output "ecr_front_despacho_url" {
  description = "URI del repositorio ECR para Frontend"
  value       = aws_ecr_repository.front_despacho.repository_url
}
