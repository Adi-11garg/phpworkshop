# aws_vpc.main:
resource "aws_vpc" "main" {
    cidr_block                       = "10.0.0.0/16"
    enable_dns_hostnames             = true
    enable_dns_support               = true
    tags                             = {
        "Name" = "project-vpc"
    }
}

# aws_subnet.private_subnet:
resource "aws_subnet" "private_subnet1" {
    availability_zone                              = "ap-south-1a"
    cidr_block                                     = "10.0.120.0/24"
    # map_public_ip_on_launch                        = true
    tags                                           = {
        "Name" = "project-subnet-private1"
    }
    vpc_id                                         = aws_vpc.main.id

}

# aws_subnet.private_subnet:
resource "aws_subnet" "private_subnet2" {
    availability_zone                              = "ap-south-1b"
    cidr_block                                     = "10.0.14.0/24"
    # map_public_ip_on_launch                        = true
    tags                                           = {
        "Name" = "project-subnet-private2"
    }
    vpc_id                                         = aws_vpc.main.id

}

# aws_subnet.public_subnet1:
resource "aws_subnet" "public_subnet1" {
    availability_zone                              = "ap-south-1b"
    cidr_block                                     = "10.0.128.0/24"
    # map_public_ip_on_launch                        = true
    tags                                           = {
        "Name" = "project-subnet-public2"
    }
    vpc_id                                         = aws_vpc.main.id

}

# aws_subnet.public_subnet2:
resource "aws_subnet" "public_subnet2" {
    availability_zone                              = "ap-south-1a"
    cidr_block                                     = "10.0.0.0/24"
    # map_public_ip_on_launch                        = true
    vpc_id                                         = aws_vpc.main.id 

}

# aws_nat_gateway.nat_gw:
resource "aws_nat_gateway" "nat_gw1" {
    connectivity_type = "private"
    subnet_id            = aws_subnet.private_subnet1.id 
    tags                 = {
        "Name" = "project-nat"
    }
}

# aws_nat_gateway.nat_gw:
resource "aws_nat_gateway" "nat_gw2" {
    connectivity_type = "private"
    subnet_id            = aws_subnet.private_subnet2.id 
    tags                 = {
        "Name" = "project-nat"
    }
}

# aws_internet_gateway.gw:
resource "aws_internet_gateway" "gw" {
    tags     = {
        "Name" = "project-igw"
    }
    vpc_id   = aws_vpc.main.id
}

# aws_route_table.public_rt:
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    tags             = {
        "Name" = "project-rtb-public1"
    }
}

# aws_route_table_association.assoc1:
resource "aws_route_table_association" "assoc1" {
    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.public_rt.id
}

# aws_route_table_association.assoc2:
resource "aws_route_table_association" "assoc2" {
    subnet_id = aws_subnet.public_subnet2.id
    route_table_id = aws_route_table.public_rt.id
}

# aws_route_table.public_rt:
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw1.id
    }
    tags             = {
        "Name" = "project-rtb-private1"
    }
}

# aws_route_table.public_rt:
resource "aws_route_table" "private_rt2" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw2.id
    }
    tags             = {
        "Name" = "project-rtb-private2"
    }
}

# aws_route_table_association.assoc3:
resource "aws_route_table_association" "assoc3" {
    subnet_id = aws_subnet.private_subnet1.id 
    route_table_id = aws_route_table.private_rt.id
}

# aws_route_table_association.assoc3:
resource "aws_route_table_association" "assoc4" {
    subnet_id = aws_subnet.private_subnet2.id 
    route_table_id = aws_route_table.private_rt.id
}