resource "aws_instance" "polybot" {
  count = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.polybot_sg.id]
  key_name  =   var.key_pairs
  subnet_id = var.subnet_id[count.index % length(var.subnet_id)]
  iam_instance_profile = aws_iam_instance_profile.profile-polybot.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y ansible
              EOF


  tags = {
    Name = "polybot-${count.index}"
  }
  
}

resource "aws_security_group" "polybot_sg" {
  name        = "polybot_sg_new"   
  description = "Allow SSH and 8443 traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
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

#---------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "attach_policy_with_polybot" {
  role       = aws_iam_role.polybot_role.name
  policy_arn = aws_iam_policy.polybot_policy.arn
}


resource "aws_iam_role" "polybot_role" {
  name = "polybot_role"

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


resource "aws_iam_policy" "polybot_policy" {
  name = "polybot_policy"

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
    },
    {
      "Sid": "Stmt1729157459746",
      "Action": "secretsmanager:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
})
}

resource "aws_iam_instance_profile" "profile-polybot" {
  name = "profile-polybot"
  role = aws_iam_role.polybot_role.name
}
