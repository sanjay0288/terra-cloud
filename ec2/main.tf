#security group
resource "aws_security_group" "webserver232_access" {
        name = "webserver232_access"
        description = "allow ssh and http"

        ingress {
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = 90
                to_port = 90
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }


}

resource "aws_instance" "ourfirst" {
  ami           = "ami-03bb6d83c60fc5f7c"
  availability_zone = "ap-south-1a"
  instance_type = "t2.medium"
  security_groups = ["${aws_security_group.webserver232_access.name}"]
  key_name = "key2"
  user_data = filebase64("install_httpd.sh")
  tags = {
    Name  = "ec2-test12"
    Location = "Mumbai"
  }

}
