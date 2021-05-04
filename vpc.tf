#This will create 1 vpc with 8 subnets (2 priv. + 6 pub.), 1 internet gateway, 2 route tables, 1 nat gateway
#vpc
resource "aws_vpc" "vpc_tf" {
    cidr_block       = var.vpc_cidr_block
    instance_tenancy = "default"

    tags = {
    Name = vpc_tf
    }
}
/*
#subnets
resource "aws_subnet" "public_subnet_1" {
    vpc_id     = aws_vpc.terraform_vpc.id
    cidr_block = var.public_subnet_cidr_block_1
    availability_zone = var.public_subnet_1_az

    tags = {
    Name = var.public_subnet_name_1
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id     = aws_vpc.terraform_vpc.id
    cidr_block = var.public_subnet_cidr_block_2
    availability_zone = var.public_subnet_2_az

    tags = {
    Name = var.public_subnet_name_2
    }
}

resource "aws_subnet" "private_subnet_1" {
    cidr_block        = var.private_subnet_cidr_block_1
    vpc_id            = aws_vpc.terraform_vpc.id
    availability_zone = var.private_subnet_1_az

    tags = {
    Name = var.tagkey_name_private_subnet_1
    }
}

#attach internet gateway to vpc
#internet gateway for the public subnet
resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.terraform_vpc.id
}

#create rout table - two (main and one with ig) (one interent accessible and one is not) 
#create route table to subnet associations
resource "aws_route_table" "public_subnet_1_to_internet" {
    vpc_id = aws_vpc.terraform_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
    }

    tags = {
    Name = var.public_route_table_1
    }
}

resource "aws_route_table_association" "internet_for_public_subnet_1" {
    route_table_id = aws_route_table.public_subnet_1_to_internet.id
    subnet_id      = aws_subnet.public_subnet_1.id
}

#nat gateway for communication with the private subnet
resource "aws_nat_gateway" "natgateway_1" {
    count         = "1"
    allocation_id = aws_eip.eip_1[count.index].id
    subnet_id     = aws_subnet.public_subnet_1.id
}

#nat gateway route table and associations
resource "aws_route_table" "natgateway_route_table_1" {
    count  = "1"
    vpc_id = aws_vpc.terraform_vpc.id

    route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1[count.index].id
    }

    tags = {
    Name = var.tagkey_name_natgateway_route_table_1
    }
}

resource "aws_route_table_association" "private_subnet_1_to_natgateway" {
    count          = "1"
    route_table_id = aws_route_table.natgateway_route_table_1[count.index].id
    subnet_id      = aws_subnet.private_subnet_1.id
}

#load balancer - not required
resource "aws_alb" "alb" {
    name               = var.alb_name
    internal           = var.alb_internal
    load_balancer_type = var.load_balancer_type
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

    enable_deletion_protection = var.enable_deletion_protection

    tags = {
    Environment = var.alb_tagname
    }
}
*/