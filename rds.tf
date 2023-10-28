provider "aws" {
  region = "ap-south-1" # Replace with your desired AWS region
}
data "aws_vpc" "va2pt-product-vpc" {
  id = "vpc-0a849686c452c8b00" # Replace with your existing VPC ID
}

resource "aws_security_group" "va2pt" {
  name_prefix = "va2pt"
  description = "Allow incoming PostgreSQL traffic"
  vpc_id      = data.aws_vpc.va2pt-product-vpc.id
}

resource "aws_db_subnet_group" "va2pt" {
  name        = "va2pt-subnet-group"
  description = "Example DB subnet group"
  subnet_ids  = ["subnet-0c923bd4e13b47c26","subnet-012fdf08e2a421d47",]
}
resource "aws_db_instance" "va2pt_kodem_test" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.t3.large"
  identifier           = "va2pt-kodem"
  db_name              = "kodem"
  username             = "va2pt"
  password             = "va2ptdatabase"
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  publicly_accessible  = false
  multi_az             = false
  vpc_security_group_ids = [aws_security_group.va2pt.id]
  db_subnet_group_name  = aws_db_subnet_group.va2pt.name
}





resource "aws_security_group_rule" "ingress" {
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["10.0.1.0/24"] # Adjust the CIDR block as needed
  security_group_id = aws_security_group.va2pt.id
}


output "rds_endpoint" {
  value = aws_db_instance.va2pt_kodem_test.endpoint
}
