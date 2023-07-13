resource "aws_vpc" "testitouille-VPC" {
        cidr_block = "10.0.0.0/24"
        tags = {
                Name = "testitouille-VPC"
        }
}
resource "aws_subnet" "testitouille-SUBNET1" {
        vpc_id = "${aws_vpc.testitouille-VPC.id}"
        cidr_block = "10.0.0.0/24"
        tags = {
                Name = "testitouille-SUBNET1"
        }
}
resource "aws_internet_gateway" "testitouille-IGW" {
}
resource "aws_internet_gateway_attachment" "testitouille-IGW-ATTACHMENT" {
        vpc_id = "${aws_vpc.testitouille-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.testitouille-IGW.id}"
}
resource "aws_route" "testitouille-ROUTE-DEFAULT" {
        route_table_id = "${aws_vpc.testitouille-VPC.main_route_table_id}"
        destination_cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.testitouille-IGW.id}"
        depends_on = [
                aws_internet_gateway_attachment.testitouille-IGW-ATTACHMENT
        ]
}
resource "aws_security_group" "testitouille-SG" {
        name = "testitouille-SG"
        description = "testitouille-SG"
        vpc_id = "${aws_vpc.testitouille-VPC.id}"
        ingress {
                description = "testitouille-SG-ALLOW-WEB"
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
                ipv6_cidr_blocks = []
        }
        ingress {
                description = "testitouille-SG-ALLOW-SSH"
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
                Name = "testitouille-SG"
        }
}
resource "aws_instance" "testitouille-INSTANCE" {
        ami = "ami-0f61de2873e29e866"
        subnet_id = "${aws_subnet.testitouille-SUBNET1.id}"
        instance_type = "t2.micro"
        associate_public_ip_address = true
        key_name = "ERODRIGUEZ-KEYSSH"
        security_groups = ["${aws_security_group.testitouille-SG.id}"]
        tags = {
                Name = "testitouille-INSTANCE"
        }
        user_data = "${file("web.sh")}"
        provisioner "local-exec" {
                command = "echo ${self.public_ip} > public_ip"
        }
}
