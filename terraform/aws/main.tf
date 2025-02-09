// Define your resources here


resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.123.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Development VPC"
  }
}


resource "aws_security_group" "default_sg" {
  name        = "default_sg"
  description = "default ssh and http access from home"
  vpc_id      = aws_vpc.dev_vpc.id

  tags = {
    Name = "default_sg"
  }

}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = var.my_public_subnet
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = var.my_public_subnet
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_5000_ipv4" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = var.my_public_subnet
  from_port         = 5000
  to_port           = 5000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
/*
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["ubuntu"] # Canonical
}
*/

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.123.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "Development IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    SessionManagerRunAs = "ubuntu"
  }
}

resource "aws_iam_role_policy" "AWSVSCodeRemoteConnect" {
    name = "AWSVSCodeRemoteConnect"
    role = aws_iam_role.ec2_role.id

    policy =jsonencode({
      "Version": "2012-10-17",
      "Statement": [ {
          "Effect": "Allow",
          "Action": [
              "ssmmessages:CreateControlChannel",
              "ssmmessages:CreateDataChannel",
              "ssmmessages:OpenControlChannel",
              "ssmmessages:OpenDataChannel",
              "ssm:DescribeAssociation",
              "ssm:ListAssociations",
              "ssm:UpdateInstanceInformation"
          ],
          "Resource": "*"
      }
      ]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "studentperf" {
  ami                     = var.ami_id #data.aws_ami.ubuntu.id 
  instance_type           = var.instance_type
  vpc_security_group_ids  = [aws_security_group.default_sg.id]
  subnet_id               = aws_subnet.my_subnet.id
  associate_public_ip_address = true
  iam_instance_profile    = aws_iam_instance_profile.ec2_instance_profile.name
  key_name                = var.keypair_name

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 20
    volume_type = "gp2"
  }
  user_data = <<-EOF
              #!/bin/bash
               echo "Running user data as ubuntu" 

              # Run a command as ubuntu
              sudo -u ubuntu bash -x << 'EOS'
                cd ~
                sudo apt-get update
                sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                sudo apt-get update
                sudo apt-get install -y docker-ce
                sudo usermod -aG docker ubuntu
                #install github runner agent
                # Create a folder
                mkdir actions-runner && cd actions-runner
                # Download the latest runner package
                curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz
                # Optional: Validate the hash
                echo "b13b784808359f31bc79b08a191f5f83757852957dd8fe3dbfcc38202ccf5768  actions-runner-linux-x64-2.322.0.tar.gz" | shasum -a 256 -c
                # Extract the installer
                tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz
                ./config.sh --url https://github.com/${var.github_owner}/${var.repository} --token ${var.github_runner_token}
                nohup ./run.sh > nohup.out 2>&1 &
              EOS
            EOF
  tags = {
    Name = "studentperf"
  }
}

resource "aws_ecr_repository" "dev_ecr_repo" {
  name = "dev-ecr-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "Dev ECR Repository"
  }
}

