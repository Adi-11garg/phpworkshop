resource "aws_db_subnet_group" "db_subnet" {
name = "db-subnet-group"
subnet_ids = ["${aws_subnet.private_subnet1.id}", "${aws_subnet.private_subnet2.id}"]
}


# aws_db_instance.db:
resource "aws_db_instance" "db" {
    availability_zone                     = "ap-south-1a"
    db_subnet_group_name                  = aws_db_subnet_group.db_subnet.name
    engine                                = "mysql"
    engine_version                        = "8.0.27"
    identifier                            = "drupal-db"
    instance_class                        = "db.t2.micro"
    port                                  = 3306
    publicly_accessible                   = false
    username                              = "drupal"
    password                              = "drupaldb"
    db_name                               = "drupal"
    allocated_storage                     = 20
    vpc_security_group_ids                = [
        aws_security_group.db_sg.id,
    ]

}
