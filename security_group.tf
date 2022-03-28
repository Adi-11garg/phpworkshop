resource "aws_security_group" "asg_sg" {
  name        = "asg_sg"
  vpc_id = aws_vpc.main.id

  ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  ingress  {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

# aws_security_group.db_sg:
resource "aws_security_group" "db_sg" {
    egress {
            cidr_blocks      = [
                "10.0.0.0/16"
            ]
            from_port        = 0
            protocol         = "-1"
            to_port          = 0
        }
    ingress {
            cidr_blocks      = [
                "0.0.0.0/0"
            ]
            from_port        = 3306
            protocol         = "tcp"
            to_port          = 3306
        }
    name        = "wordpress-sg"
    vpc_id      = aws_vpc.main.id

}
