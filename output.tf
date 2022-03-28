output "alb_url" {
  value = aws_lb.elb_app.dns_name
}

output "database_url" {
  value = aws_db_instance.db.endpoint
}