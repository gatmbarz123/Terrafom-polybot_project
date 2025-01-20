resource "aws_instance" "prometheus" {
    ami           = data.aws_ami.ubuntu_ami.id 
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.prometheus_sg.id]
    key_name  =   var.key_pairs
    subnet_id = var.subnet_id[0]
    
    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key
    host        = self.public_ip
    }

    provisioner "remote-exec" {
      inline = [

        "sudo apt update -y",
        "sudo apt install -y docker.io",
        "sudo apt install -y docker-compose",
        "sudo systemctl start docker",
        "sudo systemctl enable docker",

        "sudo mkdir -p /etc/prometheus",
        "sudo mkdir -p /var/lib/prometheus",

        "sudo bash -c 'cat > /etc/prometheus/prometheus.yml <<EOL\n${data.template_file.prometheus_config.rendered}\nEOL'",
        "sudo bash -c 'cat > /etc/docker/daemon.json <<EOL\n${data.template_file.daemon.rendered}\nEOL'",
        "sudo bash -c 'cat > /docker-compose.yml <<EOL\n${data.template_file.docker-compose.rendered}\nEOL'",

        "sudo systemctl restart docker",
        "sudo docker-compose up -d"
      ]
    }

    tags = {
      Name = "prometheus-server"
    }
  
}

resource "aws_security_group" "prometheus_sg" {  
    name        = "prometheus_sg"   
    description = "Allow SSH and 9090/3000 traffic"
    vpc_id      = var.vpc_id

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 3000    
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    from_port   = 9323
    to_port     = 9323
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

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