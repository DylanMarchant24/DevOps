# Volumen EBS (GP3, 8GB) para persistencia de la Base de Datos
resource "aws_ebs_volume" "db_data" {
  # El volumen debe crearse en la misma Availability Zone que la instancia EC2
  availability_zone = aws_instance.app_server.availability_zone
  size              = 8
  type              = "gp3"

  tags = {
    Name = "${var.project_name}-db-volume"
  }
}

# Acoplamiento del Volumen EBS a la Instancia EC2
resource "aws_volume_attachment" "db_data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.db_data.id
  instance_id = aws_instance.app_server.id

  # Forzar el detachment si la EC2 se destruye, para no dejar el volumen en estado "in-use" colgante
  force_detach = true
}
