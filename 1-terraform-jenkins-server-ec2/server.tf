# # Fetch the latest Amazon Linux Image (AMI) owned by AWS
# data "aws_ami" "latest-amazon-linux-image" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# # Get current public IP
# data "http" "myip" {
#   url = "http://ipv4.icanhazip.com"
# }

# # Define the Jenkins server
# resource "aws_instance" "jenkins-server" {
#   # Specify the AMI id defined above
#   ami                         = data.aws_ami.latest-amazon-linux-image.id
#   instance_type               = var.instance_type
#   key_name                    = "jenkins-server"
#   subnet_id                   = aws_subnet.jenkins-subnet-1.id
#   vpc_security_group_ids      = [aws_default_security_group.jenkins-sg.id]
#   availability_zone           = var.avail_zone
#   associate_public_ip_address = true
#   # Specify a script to be executed when the instance is launched
#   user_data                   = file("jenkins-script.sh")
#   tags = {
#     Name = "${var.env_prefix}-server"
#   }
# }
