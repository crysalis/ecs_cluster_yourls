resource "aws_db_instance" "db" {
  depends_on              = ["aws_security_group.mysql"]
  identifier              = "db"
  allocated_storage       = "20"
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.6.40"
  instance_class          = "db.t2.micro"
  name                    = "${var.db_name}"
  username                = "${var.db_user}"
  password                = "${var.db_pwd}"
  vpc_security_group_ids  = ["${aws_security_group.mysql.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.mysql.id}"
  availability_zone       = "us-east-1a"
  backup_retention_period = "7"

  tags {
    Name = "yourls-db"
  }
}

resource "aws_db_subnet_group" "mysql" {
  name        = "yourls db subnet group"
  subnet_ids  = ["${aws_subnet.private_subnet_1.id}","${aws_subnet.private_subnet_2.id}"]
}

resource "aws_security_group" "mysql" {
  vpc_id      = "${aws_vpc.default.id}"
  name        = "sg_for_mysql"


  ingress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
      security_groups = ["${aws_security_group.ecs_service_sg.id}"]
  }

  egress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
      security_groups = ["${aws_security_group.ecs_service_sg.id}"]
  }
}

resource "aws_security_group" "mysq_sg" {
  name = "mysql-sg"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
      security_groups = ["${aws_security_group.mysql.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}