# aws_lb.elb_app:
resource "aws_lb" "elb_app" {
    internal                   = false
    load_balancer_type         = "application"
    name                       = "projec"
    security_groups            = [
        aws_security_group.asg_sg.id,
    ]
    subnets                    = [
        aws_subnet.public_subnet1.id,
        aws_subnet.public_subnet2.id,
    ]
    
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.elb_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# aws_lb_target_group.alb_target_group:
resource "aws_lb_target_group" "alb_target_group" {
    name                          = "project"
    port                          = 80
    protocol                      = "HTTP"
    target_type                   = "instance"
    vpc_id                        = aws_vpc.main.id

    health_check {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "80"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 5
    }

}


