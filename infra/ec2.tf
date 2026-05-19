# Obtener la AMI más reciente de Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ----------------------------------------------------
# Instancia EC2 FRONTEND (Subred Pública)
# ----------------------------------------------------
resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  iam_instance_profile        = "LabInstanceProfile"
  key_name                    = "vockey"

  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    usermod -aG docker ec2-user
  EOF

  tags = {
    Name = "${var.project_name}-frontend"
  }
}

# ----------------------------------------------------
# Instancia EC2 BACKEND (Subred Privada)
# ----------------------------------------------------
resource "aws_instance" "backend" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.private[0].id
  iam_instance_profile = "LabInstanceProfile"
  key_name             = "vockey"

  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    usermod -aG docker ec2-user
    
    # Preparar el disco EBS para MySQL
    DEVICE="/dev/xvdf"
    MOUNT_POINT="/data/mysql"
    sleep 20
    FS_TYPE=$(blkid -s TYPE -o value $DEVICE)
    if [ -z "$FS_TYPE" ]; then
      mkfs -t ext4 $DEVICE
    fi
    mkdir -p $MOUNT_POINT
    mount $DEVICE $MOUNT_POINT
    echo "$DEVICE $MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab
    chown -R 999:999 $MOUNT_POINT
    chmod -R 700 $MOUNT_POINT
  EOF

  tags = {
    Name = "${var.project_name}-backend"
  }
}

# ----------------------------------------------------
# Attachments al Load Balancer
# ----------------------------------------------------
# El ALB recibe el tráfico HTTP y lo manda al Frontend
resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend.id
  port             = 8080
}

# Nota: El Frontend se comunicará directamente con los backends (o a través del ALB interno, 
# pero como la pauta exige comunicación Frontend->Backend restringida, usamos IPs internas).
# Si el ALB actual es PÚBLICO, NO podemos adjuntar los Backends a él si queremos que la rúbrica 
# se cumpla ("solo el frontend es accesible desde internet").
# Los Target Groups de back_ventas y back_despachos quedan huérfanos o podemos borrarlos de alb.tf.
