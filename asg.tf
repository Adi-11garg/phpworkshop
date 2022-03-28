# aws_autoscaling_group.as_group:
resource "aws_autoscaling_group" "as_group" {
    desired_capacity          = 2
    health_check_grace_period = 60
    default_cooldown        = 60
    health_check_type         = "EC2"
    max_size                  = 5
    min_size                  = 2
    name                      = "project"
    target_group_arns         = [
        aws_lb_target_group.alb_target_group.arn,
    ]
    vpc_zone_identifier       = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]


    launch_template {
        id      = aws_launch_template.launch_template.id
        version = aws_launch_template.launch_template.latest_version
    }

    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 50
        }
        triggers = ["launch_template"]
  }
  termination_policies      = ["Default"]

}

# aws_launch_template.launch_template:
resource "aws_launch_template" "launch_template" {
    default_version         = 1
    image_id                = "ami-011a9944eb4abcf55"  
    # image_id                = "ami-0b6d5b94fb02d2192"
    instance_type           = "t2.micro"
    name_prefix   = "project"

    vpc_security_group_ids  = [
        aws_security_group.asg_sg.id,
    ]

    tag_specifications {
        resource_type = "instance"

        tags = {
            Name = "project-instance"
        }
  }

}

# aws_autoscaling_policy.bat:
resource "aws_autoscaling_policy" "bat" {
    autoscaling_group_name    = aws_autoscaling_group.as_group.name
    name                      = "project-scaling-policy"
    policy_type               = "PredictiveScaling"
    
    predictive_scaling_configuration {
        max_capacity_breach_behavior = "HonorMaxCapacity"
        mode                         = "ForecastOnly"
        scheduling_buffer_time       = "60"

        metric_specification {
            target_value = 10

            predefined_metric_pair_specification {
                predefined_metric_type = "ALBRequestCount"
                resource_label         = "app/projec/b231937526760058/targetgroup/project/a7bbb7d2573ed04f"
            }
        }
    }
}