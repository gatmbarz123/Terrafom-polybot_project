resource "aws_lb" "alb-new" {
  name               = "alb-telegram"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = "alb.polybot.logs"
  }

  

  tags = {
    Environment = "polybot-project"
  }

}

resource "aws_lb_target_group" "alb-tg" {
  name     = "tg-alb-telegram"
  port     = 8443
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "alb-tg-attachment" {
  for_each         = { for idx, instance in var.instance_id : idx => instance }
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = each.value
  port             = 8443
}


resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb-new.arn
  port              = "8443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg_new"   
  description = "Allow SSH and 8443 traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.hosted_zone_id.zone_id 
  name    = var.record_name
  type    = "A"
  
  alias {
    name                   = aws_lb.alb-new.dns_name
    zone_id                = aws_lb.alb-new.zone_id
    evaluate_target_health = true
  }

}