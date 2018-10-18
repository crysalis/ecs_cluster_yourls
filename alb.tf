resource "aws_alb" "yourls_lb" {
  name            = "yourls-lb"
  subnets         = ["${aws_subnet.public_subnet_1.id}","${aws_subnet.public_subnet_2.id}"]
  security_groups = ["${aws_security_group.yourls_lb_sg.id}"]

}

resource "aws_alb_listener" "yourls_listener" {
  load_balancer_arn = "${aws_alb.yourls_lb.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = ["aws_alb_target_group.yourls_tg"]

  default_action {
    target_group_arn = "${aws_alb_target_group.yourls_tg.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "yourls_tg" {
  name     = "yourls-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    path = "/admin/"
    port = 80
    interval = 30
    healthy_threshold = 3
    unhealthy_threshold = 3
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "yourls_lb_sg" {
  name        = "yourls-lb-sg"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
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



