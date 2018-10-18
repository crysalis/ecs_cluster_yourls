
resource "aws_ecs_cluster" "yourls_cluster" {
  name = "ecs-cluster"
}  

data "template_file" "yourls_task" {
  template = "${file("${path.module}/yourls_task.json")}"

  vars {
    image       = "repo/yourls:${var.yourls_version}" 
    db_hostname	= "${aws_db_instance.db.address}"
    db_user			= "${var.db_user}"
    db_password = "${var.db_pwd}"
    db_name 		= "${var.db_name}"
    domain 			= "${var.domain}"
    logs        = "${aws_cloudwatch_log_group.yourls.name}"
    yourls_user = "${var.yourls_user}"
    yourls_pass = "${var.yourls_pass}"
  }
}

resource "aws_ecs_task_definition" "yourls" {
  family                   = "yourls"
  container_definitions    = "${data.template_file.yourls_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}


resource "aws_cloudwatch_log_group" "yourls" {
  name = "yourls"
}


resource "aws_security_group" "ecs_service_sg" {
  vpc_id      = "${aws_vpc.default.id}"
  name        = "ecs-service-sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_ecs_service" "yourls" {
  name            = "yourls"
  task_definition = "${aws_ecs_task_definition.yourls.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.yourls_cluster.id}"
  # depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]

  network_configuration {
    security_groups = [ "${aws_security_group.ecs_service_sg.id}"]
    subnets         = ["${aws_subnet.private_subnet_1.id}","${aws_subnet.private_subnet_2.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.yourls_tg.arn}"
    container_name   = "yourls"
    container_port   = "80"
  }
  health_check_grace_period_seconds = "120"
  depends_on = ["aws_alb_target_group.yourls_tg", "aws_ecs_task_definition.yourls"]
}

