data "template_file" "prometheus_config" {
  template = file("${path.module}/prometheus.yml")

  vars = {
    targets = join(",", [for ip in var.instance_ips : "'${ip}:5000'"])
  }
}

data "template_file" "docker-compose" {
  template = file("${path.module}/docker-compose.yml")

}

data "template_file" "daemon" {
  template = file("${path.module}/daemon.json")

}

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical owner ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}