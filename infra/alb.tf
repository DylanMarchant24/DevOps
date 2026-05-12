# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group: Frontend (8080)
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-tg-front"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

# Target Group: Backend Despachos (8081)
resource "aws_lb_target_group" "back_despachos" {
  name        = "${var.project_name}-tg-despachos"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/swagger-ui/index.html" # Ajustar si existe otro endpoint de health
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# Target Group: Backend Ventas (8082)
resource "aws_lb_target_group" "back_ventas" {
  name        = "${var.project_name}-tg-ventas"
  port        = 8082
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/swagger-ui/index.html" # Ajustar si existe otro endpoint de health
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# Listener principal del ALB (Puerto 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # Acción por defecto: Enviar al frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Regla de Listener: Enrutar /api/despachos al backend correspondiente
resource "aws_lb_listener_rule" "rule_despachos" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back_despachos.arn
  }

  condition {
    path_pattern {
      values = ["/api/despachos*"] # Ajustar ruta real del controlador
    }
  }
}

# Regla de Listener: Enrutar /api/ventas al backend correspondiente
resource "aws_lb_listener_rule" "rule_ventas" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back_ventas.arn
  }

  condition {
    path_pattern {
      values = ["/api/ventas*"] # Ajustar ruta real del controlador
    }
  }
}
