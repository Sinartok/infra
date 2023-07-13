resource "aws_vpc" "test-VPC" {
        cidr_block = "10.0.0.0/24"
        tags = {
                Name = "test-VPC"
        }
}
resource "aws_subnet" "test-SUBNET1" {
        vpc_id = "${aws_vpc.test-VPC.id}"
        cidr_block = "10.0.0.0/24"
        tags = {
                Name = "test-SUBNET1"
        }
}
resource "aws_internet_gateway" "test-IGW" {
}
resource "aws_internet_gateway_attachment" "test-IGW-ATTACHMENT" {
        vpc_id = "${aws_vpc.test-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.test-IGW.id}"
}
resource "aws_route" "test-ROUTE-DEFAULT" {
        route_table_id = "${aws_vpc.test-VPC.main_route_table_id}"
        destination_cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.test-IGW.id}"
        depends_on = [
                aws_internet_gateway_attachment.test-IGW-ATTACHMENT
        ]
}
resource "aws_security_group" "test-SG" {
        name = "test-SG"
        description = "test-SG"
        vpc_id = "${aws_vpc.test-VPC.id}"
        ingress {
                description = "test-SG-ALLOW-WEB"
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
                ipv6_cidr_blocks = []
        }
        ingress {
                description = "test-SG-ALLOW-SSH"
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
                Name = "test-SG"
        }
}
resource "aws_instance" "test-INSTANCE" {
        ami = "ami-0f61de2873e29e866"
        subnet_id = "${aws_subnet.test-SUBNET1.id}"
        instance_type = "t2.micro"
        associate_public_ip_address = true
        key_name = "ERODRIGUEZ-KEYSSH"
        security_groups = ["${aws_security_group.test-SG.id}"]
        tags = {
                Name = "test-INSTANCE"
        }
        user_data = "${file("web.sh")}"
        provisioner "local-exec" {
                command = "echo ${self.public_ip} > public_ip"
        }
}
