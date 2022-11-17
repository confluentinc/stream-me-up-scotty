terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
    region = "us-east-2"
}
resource "aws_default_vpc" "default_vpc" {
    tags = {
        name = "Default VPC"
    }
}
resource "aws_security_group" "postgres_sg" {
    name = "postgres_security_group_${split("-", uuid())[0]}"
    description = "Security Group for Postgres EC2 instance. Used in Confluent Cloud Realtime Datawarehouse Ingestion workshop."
    vpc_id = aws_default_vpc.default_vpc.id
    egress {
        description = "Allow all outbound."
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "Postgres"
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "Postgres"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    tags = {
        Name = "rt-dwh-postgres-sg"
        created_by = "terraform"
    }
}

data "template_cloudinit_config" "pg_bootstrap_customers" {
    base64_encode = true
    part {
        content_type = "text/x-shellscript"
        content = "${file("../scripts/pg_customers_bootstrap.sh")}"
    }
}
resource "aws_instance" "postgres_customers" {
    ami = "ami-0c7478fd229861c57"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.postgres_sg.name]
    user_data = "${data.template_cloudinit_config.pg_bootstrap_customers.rendered}"
    tags = {
        Name = "rt-dwh-postgres-customers-instance"
        created_by = "terraform"
    }
}
resource "aws_eip" "postgres_customers_ip" {
    vpc = true
    instance = aws_instance.postgres_customers.id
    tags = {
        Name = "rt-dwh-postgres-customers-eip"
        created_by = "terraform"
    }
}
output "postgres_instance_customers_public_endpoint" {
    value = aws_eip.postgres_customers_ip.public_ip
}
data "template_cloudinit_config" "pg_bootstrap_products" {
    base64_encode = true
    part {
        content_type = "text/x-shellscript"
        content = "${file("../scripts/pg_products_bootstrap.sh")}"
    }
}
resource "aws_instance" "postgres_products" {
    ami = "ami-0c7478fd229861c57"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.postgres_sg.name]
    user_data = "${data.template_cloudinit_config.pg_bootstrap_products.rendered}"
    tags = {
        Name = "rt-dwh-postgres-products-instance"
        created_by = "terraform"
    }
}
resource "aws_eip" "postgres_products_ip" {
    vpc = true
    instance = aws_instance.postgres_products.id
    tags = {
        Name = "rt-dwh-postgres-products-eip"
        created_by = "terraform"
    }
}
output "postgres_instance_products_public_endpoint" {
    value = aws_eip.postgres_products_ip.public_ip
}