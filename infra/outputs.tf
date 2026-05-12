output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS del Application Load Balancer"
  value       = aws_lb.main.dns_name
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

output "ec2_private_ip" {
  description = "IP Privada de la instancia EC2"
  value       = aws_instance.app_server.private_ip
}
