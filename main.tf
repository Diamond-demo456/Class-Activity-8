data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "dev-terraform-key"
  public_key = file("~/.ssh/dev-terraform-key.pub")
}

resource "aws_security_group" "ec2_sg" {
  name        = "dev-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "multi_ec2" {
  count                  = 3
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_key.key_name
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "Dev-EC2-${count.index}"
  }
}

resource "aws_dynamodb_table" "students" {
  name         = "students_table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "student_id"
  range_key = "created_at"

  attribute {
    name = "student_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  tags = {
    Name = "StudentsTable"
  }
}

resource "aws_dynamodb_table_export" "export_students" {
  table_arn = aws_dynamodb_table.students.arn
  s3_bucket = "devops-s3-bucket-2026-03-30"

  export_format = "DYNAMODB_JSON"
}

