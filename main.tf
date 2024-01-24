provider "aws"{
	region = "ap-south-1"
	access_key = "AKIAUSPNL3ESI6ZUC3LF"
	secret_key = "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"
}

resource "aws_vpc" "DevVPC"{
	
	cidr_block = "10.10.0.0/16"
	instance_tenancy = "default"

	tags = {

		Name = "DevVPC"	
	}

}

resource "aws_security_group" "sg1" {
  name        = "basic-security-group"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id = "${aws_vpc.DevVPC.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_subnet" "sub1"{

	vpc_id = "${aws_vpc.DevVPC.id}"
	cidr_block = "10.10.0.0/28"
	availability_zone = "ap-south-1a"

	tags = {

		Name = "sub1"
	}

}

resource "aws_subnet" "sub2"{

        vpc_id = "${aws_vpc.DevVPC.id}"
        cidr_block = "10.10.1.0/28"
	availability_zone = "ap-south-1a"

        tags = { 

                Name = "sub2"
        }

}

resource "aws_internet_gateway" "ig"{

	vpc_id = "${aws_vpc.DevVPC.id}"
	
	tags = {

		Name = "internetgateway"
	}

}

resource "aws_route_table" "rt1"{

	vpc_id = "${aws_vpc.DevVPC.id}"
		
	route {	

		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.ig.id}"	
	}

}

resource "aws_route_table_association" "a1"{

	subnet_id = "${aws_subnet.sub1.id}"
	route_table_id = "${aws_route_table.rt1.id}"
	
}

resource "aws_route_table_association" "a2"{

        subnet_id = "${aws_subnet.sub2.id}"
        route_table_id = "${aws_route_table.rt1.id}"

}




resource "aws_instance" "ec2-1"{

	ami = "ami-0c84181f02b974bc3"
	instance_type = "t2.micro"
	associate_public_ip_address = true
	subnet_id = "${aws_subnet.sub1.id}"
	availability_zone = "ap-south-1a"
	vpc_security_group_ids = [aws_security_group.sg1.id]
	key_name = "linux"
	
	tags = {

		Name = "ec2-1"
		env = "prod"
	}
}
	
resource "aws_instance" "ec2-2"{

        ami = "ami-0c84181f02b974bc3"
        instance_type = "t2.micro"
        associate_public_ip_address = true
        subnet_id = "${aws_subnet.sub2.id}"
	availability_zone = "ap-south-1a"
        vpc_security_group_ids = [aws_security_group.sg1.id]
        key_name = "linux"

        tags = {

                Name = "ec2-2"
                env = "dev"
        }

}
