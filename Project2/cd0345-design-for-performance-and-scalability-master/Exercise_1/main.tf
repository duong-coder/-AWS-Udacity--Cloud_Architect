# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  access_key = "AKIASVBKBFY2W3AQJRX4"
  secret_key = "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"
  region = "us-east-1"
}


# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "Udacity-T2" {
  count = "4"
  ami = "ami-06eecef118bbf9259"
  instance_type = "t2.micro"
  subnet_id = "subnet-0973f8a81750f56b4"
  tags = {
    "Name" = "Udacity T2"
  }
}


# TODO: provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "Udacity-M4" {
  count = "2"
  ami = "ami-06eecef118bbf9259"
  instance_type = "m4.large"
  subnet_id = "subnet-0973f8a81750f56b4"
  tags = {
    "Name" = "Udacity M4"
  }
}

## terraform destroy -target aws_instance.Udacity-M4