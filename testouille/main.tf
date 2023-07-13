terraform {
        required_providers {
                aws = {
                        source  = "hashicorp/aws"
                }
        }
}
provider "aws" {
        region = "eu-west-3"
}
resource "aws_vpc" "testouille-VPC" {
        cidr_block = "10.0.0.0/24"
        tags = {
                Name = "testouille-VPC"
        }
}
resource "aws_subnet" "testouille-SUBNET1" {
        vpc_id = "${aws_vpc.testouille-VPC.id}"
        cidr_block = "10.0.0.0/24"
        tags = {
                Name = "testouille-SUBNET1"
        }
}
resource "aws_internet_gateway" "testouille-IGW" {
}
resource "aws_internet_gateway_attachment" "testouille-IGW-ATTACHMENT" {
        vpc_id = "${aws_vpc.testouille-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.testouille-IGW.id}"
}
resource "aws_route" "testouille-ROUTE-DEFAULT" {
        route_table_id = "${aws_vpc.testouille-VPC.main_route_table_id}"
        destination_cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.testouille-IGW.id}"
        depends_on = [
                aws_internet_gateway_attachment.testouille-IGW-ATTACHMENT
        ]
}
resource "aws_security_group" "testouille-SG" {
        name = "testouille-SG"
        description = "testouille-SG"
        vpc_id = "${aws_vpc.testouille-VPC.id}"
        ingress {
                description = "testouille-SG-ALLOW-WEB"
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
                ipv6_cidr_blocks = []
        }
        ingress {
                description = "testouille-SG-ALLOW-SSH"
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
                ipv6_cidr_blocks = []
        }
        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
                ipv6_cidr_blocks = []
        }
        tags = {
                Name = "testouille-SG"
        }
}
resource "aws_instance" "testouille-INSTANCE" {
        ami = "ami-0f61de2873e29e866"
        subnet_id = "${aws_subnet.testouille-SUBNET1.id}"
        instance_type = "t2.micro"
        associate_public_ip_address = true
        key_name = "ERODRIGUEZ-KEYSSH"
        security_groups = ["${aws_security_group.testouille-SG.id}"]
        tags = {
                Name = "testouille-INSTANCE"
        }
        user_data = "${file("web.sh")}"
        provisioner "local-exec" {
                command = "echo ${self.public_ip} > public_ip"
        }
}
