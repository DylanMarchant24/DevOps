# IAM Role para que la EC2 pueda autenticarse y descargar imágenes desde ECR
resource "aws_iam_role" "ec2_ecr_role" {
  name = "${var.project_name}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Adjuntar política gestionada por AWS para acceso read-only a ECR
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Instance Profile para asignar a la EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# Obtener la AMI más reciente de Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Instancia EC2 (t2.micro) en Subred Privada
resource "aws_instance" "app_server" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.private[0].id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Adjuntar Security Groups (ec2_sg para apps, db_sg para la DB local si queremos abstraer sus reglas)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id, aws_security_group.db_sg.id]

  # User Data Script para preparar Docker y el disco EBS
  user_data = <<-EOF
    #!/bin/bash
    # 1. Actualizar sistema e instalar Docker
    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker
    
    # 2. Instalar Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Añadir usuario ec2-user al grupo docker
    usermod -aG docker ec2-user
    
    # 3. Preparar el disco EBS para la persistencia de MySQL
    # En instancias t2.micro (basadas en Xen), /dev/sdf se mapea como /dev/xvdf
    DEVICE="/dev/xvdf"
    MOUNT_POINT="/data/mysql"
    
    # Esperar unos segundos a que el volumen se adjunte completamente
    sleep 20
    
    # Verificar si el disco ya tiene un sistema de archivos
    FS_TYPE=$(blkid -s TYPE -o value $DEVICE)
    if [ -z "$FS_TYPE" ]; then
      echo "Formateando disco nuevo $DEVICE con ext4..."
      mkfs -t ext4 $DEVICE
    else
      echo "El disco $DEVICE ya tiene formato $FS_TYPE. Omitiendo formateo."
    fi
    
    # Crear punto de montaje y montar
    mkdir -p $MOUNT_POINT
    mount $DEVICE $MOUNT_POINT
    
    # Asegurar montaje persistente tras reinicios del SO en fstab
    echo "$DEVICE $MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab
    
    # Asegurar permisos para el usuario del contenedor MySQL (típicamente UID/GID 999 en imágenes oficiales)
    chown -R 999:999 $MOUNT_POINT
    chmod -R 700 $MOUNT_POINT
  EOF

  tags = {
    Name = "${var.project_name}-app-server"
  }
}

# Adjuntar la instancia EC2 a los Target Groups del ALB
resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.app_server.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "back_despachos" {
  target_group_arn = aws_lb_target_group.back_despachos.arn
  target_id        = aws_instance.app_server.id
  port             = 8081
}

resource "aws_lb_target_group_attachment" "back_ventas" {
  target_group_arn = aws_lb_target_group.back_ventas.arn
  target_id        = aws_instance.app_server.id
  port             = 8082
}
