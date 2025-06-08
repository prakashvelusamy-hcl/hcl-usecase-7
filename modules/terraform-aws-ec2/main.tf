# data "aws_security_group" "sg" {
#   filter {
#     name   = "vpc-id"
#     values = [aws_vpc.main.id]
#   }
#   filter {
#     name   = "group-name"
#     values = ["default"]
#   }
# }
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-http-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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


resource "aws_instance" "public_instances" {
  count                       = var.public_instance
  ami                         = "ami-0e35ddab05955cf57"
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_ids[count.index]
  associate_public_ip_address = true
  #   security_groups = [data.aws_security_group.sg.id]
  security_groups = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Hostname: $(hostname)</h1>" > /var/www/html/index.html
              systemctl reload nginx
              EOF

  tags = {
    Name = "Public-Instance-${count.index}"
  }
}






