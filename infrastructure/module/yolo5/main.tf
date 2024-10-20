resource "aws_security_group" "yolo5_sg" {
  name        = "yolo5_sg_new"   
  description = "Allow SSH and 8443 traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
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
resource "aws_placement_group" "placement_group" {
  name     = "pg-yolo5"
  strategy = "spread"
}

resource "aws_autoscaling_group" "as-yolo5" {
  name                      = "as-yolo5"
  max_size                  = 3
  min_size                  = 1
  force_delete              = true
  placement_group           = aws_placement_group.placement_group.id
  vpc_zone_identifier       = var.subnet_id

   launch_template {
    id      = aws_launch_template.lt-as-yolo5.id
    version = "$Latest"
  }

}

resource "aws_launch_template" "lt-as-yolo5" {
  name_prefix   = "lt-as-yolo5"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_pairs
  
  iam_instance_profile {
    name = aws_iam_instance_profile.profile-yolo5.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.yolo5_sg.id] 
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "yolo5"  
    }
  }
}

#-----------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high_alarm"
  alarm_description   = "Alarm when CPU exceeds 50%"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 50
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as-yolo5.name
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale_out_policy"
  scaling_adjustment      = 1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.as-yolo5.name
}

#-------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low_alarm"
  alarm_description   = "Alarm when CPU is below 30%"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 30
  comparison_operator = "LessThanThreshold"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as-yolo5.name
  }
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale_in_policy"
  scaling_adjustment      = -1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.as-yolo5.name
}


#-------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "attach_policy_with_yolo5" {
  role       = aws_iam_role.yolo5_role.name
  policy_arn = aws_iam_policy.yolo5_policy.arn
}


resource "aws_iam_role" "yolo5_role" {
  name = "yolo5_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"  
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}


resource "aws_iam_policy" "yolo5_policy" {
  name = "yolo5_policy"

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1729157299571",
      "Action": "dynamodb:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt1729157323179",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt1729157336699",
      "Action": "sqs:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
})
}

resource "aws_iam_instance_profile" "profile-yolo5" {
  name = "profile-yolo5"
  role = aws_iam_role.yolo5_role.name
}

#------------------------------------------------------------------------

