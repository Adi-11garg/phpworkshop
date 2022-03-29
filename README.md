We would have to create a 3 tier php application infrastructure on aws with the help of terraform using jenkins pipeline.

**Features of architecture**
- Highly available (available in both AZs)
- Highly scalable (Java applications should scale on cpu)
- Highly Secure 
- zero downtime deployment


**In this architecture I used the following tools:-**
1.IAAC-Terraform
2.CICD-Jenkins
3.AWS


The approach which i used to make application is mention below. There are few artefacts         
1.Arch diagram
2.Terraform code
3.Push it on Github
4.CICD Jenkins pipeline
5.Custom ami for nginx with wordpress

**Strategy to write terraform code-**
1.Provider
2.VPC
3.Subnet-AZ
4.Internet Gateway(iwg)
5.Nat-Gateway(NAT)
6.Public Route Table
7.Private Route Table
8.Security Group (public,private)
9.EC2 launch in public subnet
10.Rds
11.Application load balancer 
12.Autoscaling


**Terraform high availability infrstructure on AWS**

This repository contains terraform configuration file to launch high availability infrastructure on AWS. In this repository I try to show the syntax of terraform resources which i used- 

# AWS Provider
provider "aws" {
  region = "us-east-1"
}



# Vpc
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  availability_zone = "eu-west-3a"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

# IWG
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "example" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.example.id
}

# Public route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route = []

  tags = {
    Name = "example"
  }
}

# Private route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.example.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "example"
  }
}
# Security Group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
# alb
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true
# alb target group
resource "aws_lb_target_group" "front_end" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# alb listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "443"
  protocol          = "HTTPS"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}
# asg

resource "aws_launch_template" "example" {
  name_prefix   = "example"
  image_id      = data.aws_ami.example.id
  instance_type = "c5.large"
}

resource "aws_autoscaling_group" "example" {
  capacity_rebalance  = true
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.example1.id, aws_subnet.example2.id]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.example.id
      }

      override {
        instance_type     = "c4.large"
        weighted_capacity = "3"
      }

      override {
        instance_type     = "c3.large"
        weighted_capacity = "2"
      }
    }
  }
}

# Requirements

   1.AWS account
   2.EC2 instance with Terraform and Jenkins configured
   3.An AMI configured with Nginx, wordpress.
   4.IAM service role attach with EC2 instance running Jenkins
   
        

# Setup
# AMI Setup

    
    Launch EC2 instance with Amazon Ubuntu AMI
    Install Nginx, PHP and required packages
    Configure Nginx to run WordPress application
    Create Amazon AMI from it in the region you want to use it

# How to configure wordpress with nginx �:
1.To install the nginx package, use the default package manager as follows:/
2.Confirm that the Nginx service is up and enabled on boot using the following systemctl commands./
3.Open a web browser and use the following address to navigate. (http://YOUR_SERVER_IP)/
4.Installing Mysql Database on Ubuntu 20.04/
5.Confirm that the Mysql database service is running and is enabled to automatically start when your system is restarted./
6.You need to enable some basic security measures for the Mysql database installation, by running the mysql_secure_installation script which ships with the Mysql package./
7.To access the Mysql shell, run the mysql command with the -u option with sudo./
8.Installing PHP in Ubuntu 20.04/
9.After finding the extension, you can install it. For example, I am installing PHP modules for Redis in-memory cache and Zip compression tool./
10.After installing PHP extension, you need to restart nginx to apply recent changes./
11.Next, test if Nginxis working in conjunction with PHP. Create an info.php page under the web document root /var/www/html/ directory as shown./
12.Copy and paste the following code in the file, then save the file and exit it. 
     <?php
        phpinfo();
     ?>
13.open a web browser and navigate using the following address.

      http://YOUR_SERVER_IP/info.php

14.Installing PhpMyAdmin in Ubuntu 20.04/
15.To configure a database for PhpMyAdmin with the dbconfig-common package, select yes in the next prompt./
16.Next, create a password for PhpMyAdmin to register with the Mysql database server./
17.In a browser go to http://SERVER_IP/phpmyadmin, replacing SERVER_IP with the server’s actual IP address./
18.After installing lemp you can download the latest version of wordpress./
19.Once the download is complete, extract the archived file using the tar command as shown./
20.Next, move the extracted WordPress directory into your document root i.e. /var/www/html/ and under your website as shown (replace mysite.com with your website’s name or domain name). The following command will create a mysite.com directory and move WordPress files under it./
21.Now set appropriate permissions on the website (/var/www/html/mysite.com) directory. It should be owned by the Nginx user and group called www-data./
22.Creating a WordPress Database for Website./
23.Creating Nginx VirtualHost for WordPress Website/
24.Completing the WordPress Installation via Web Interface./


# Jenkins Instance Setup

    Launch EC2 instance with your choice of AMI
    Install latest version of Java
    Install and Configure Jenkins
    Install and configure Terraform
    Give appropiate permission to jenkins user
    Create aws role and attach with ami to access aws services

# Paste that custom ami id in terraform instances and then push the code on Git by following commands:
1.git init//
2.git add .//
3.git commit -m "msg"//
4.git status//
5.git remote add origin <repo link>//
6.git remote -v//
7.git push -u origin <branch name>  //
  
# GitHub Setup

    Clone the repository
    Set webhook to trigger Jenkins job
    Put the terraform configuration file and Jenkins file into repository

# Jenkins job setup

    Install required Jenkins plugins
    Create pipeline job
    Add GitHub repository url as SCM
    Set GitHub Poll SCM
    Push your changes or run the job the provision the infrastructure

After making pipeline build the code and jenkins will make the infrasturcture on aws and with the help of load balancer dns we can see our desirable output on browser.

