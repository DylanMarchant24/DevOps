# ============================================================
# APPLICATION LOAD BALANCER
# EP3: target_type cambia a "ip" para trabajar con pods EKS
# ============================================================

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

# Target Group: Frontend
# target_type = "ip" es requerido para EKS (los pods tienen IPs propias)
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-tg-front"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  tags = {
    Name = "${var.project_name}-tg-frontend"
  }
}

# Listener HTTP (puerto 80) → reenvía al frontend
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}
