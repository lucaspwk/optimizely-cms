resource "aws_db_instance" "sql_server_instance" {
  identifier              = "sql-server-instance"
  engine                  = "sqlserver-se"
  engine_version          = "15.00.4073.23.v1"
  instance_class          = "db.m5.large"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = random_string.rds_master_username.result
  password                = random_password.rds_master_password.result
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids  = [aws_security_group.default.id]
  skip_final_snapshot     = true
  license_model           = "license-included"


  tags = {
    Name = "sql-server-instance"
  }
}

resource "aws_security_group" "default" {
  name        = "rds-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow traffic to RDS"

  ingress {
    from_port   = 1433
    to_port     = 1433
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

# Create the DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "random_string" "rds_master_username" {
  length  = 8
  upper   = true
  lower   = true
  numeric = false
  special = false
}

resource "random_password" "rds_master_password" {
  length           = 16
  special          = true
  min_special      = 4
  override_special = "_#"
  keepers = {
    pass_version = 1
  }
}