provider "aws" {
  region = var.aws_region
}

resource "aws_subnet" "subnet" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = var.jenkins_subnet_cidr
  availability_zone = var.jenkins_availability_zone

  tags = {
    Name = "${var.project_name}-subnet"
  }
}
