resource "aws_appautoscaling_target" "ecs_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.yourls_cluster.name}/${aws_ecs_service.yourls.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${aws_iam_role.ecs_autoscale_role.arn}"
  min_capacity       = 1
  max_capacity       = 2
}

resource "aws_appautoscaling_policy" "up" {
  name                    = "scale_up"
  service_namespace       = "ecs"
  resource_id             = "service/${aws_ecs_cluster.yourls_cluster.name}/${aws_ecs_service.yourls.name}"
  scalable_dimension      = "ecs:service:DesiredCount"


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.ecs_target"]
}

resource "aws_appautoscaling_policy" "down" {
  name                    = "scale_down"
  service_namespace       = "ecs"
  resource_id             = "service/${aws_ecs_cluster.yourls_cluster.name}/${aws_ecs_service.yourls.name}"
  scalable_dimension      = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.ecs_target"]
}

/* CloudWatch metrics */
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "yourls_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "75"

  dimensions {
    ClusterName = "${aws_ecs_cluster.yourls_cluster.name}"
    ServiceName = "${aws_ecs_service.yourls.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.up.arn}"]
  ok_actions    = ["${aws_appautoscaling_policy.down.arn}"]
}