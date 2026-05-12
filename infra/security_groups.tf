# Security Group para el ALB (Público)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Permitir trafico web entrante al ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP desde Internet"
    from_port   = 80
    to_port     = 80
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

# Security Group para la instancia EC2 (Privado)
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Permitir trafico desde el ALB hacia los contenedores"
  vpc_id      = aws_vpc.main.id

  # Frontend
  ingress {
    description     = "Frontend desde ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Backend Despachos
  ingress {
    description     = "Backend Despachos desde ALB"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Backend Ventas
  ingress {
    description     = "Backend Ventas desde ALB"
    from_port       = 8082
    to_port         = 8082
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# Security Group para MySQL (Interno)
# Nota: Como MySQL corre en la misma EC2 en Docker, el tráfico es interno (localhost/bridge). 
# Sin embargo, se adjunta por buena práctica de separación o en caso de futura migración a RDS.
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Permitir trafico a MySQL solo desde la EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL desde EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}
