output "alb_url" {
  value       = aws_route53_record.alb.name
  description = "The URL for the ALB"
}
