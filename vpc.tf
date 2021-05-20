#This will create 1 vpc with 8 subnets (2 priv. + 6 pub.), 1 internet gateway, 2 route tables, 1 nat gateway
# vpc

resource "aws_vpc" "clixxvpc" {
    cidr_block       = var.vpc_cidr1
    instance_tenancy = "default"
    enable_dns_support = true 

    tags = {
    Name = "vpctf"
    }
}

# pub. sub for bastion sever
resource "aws_subnet" "bastionsub" {
    vpc_id            = aws_vpc.clixxvpc.id
    cidr_block        = "10.0.0.0/24"
    availability_zone = var.AZ1
    
    tags = {
    Name = "bastionsub"
    }
}

# pub. sub 
resource "aws_subnet" "pubsub" {
    vpc_id            = aws_vpc.clixxvpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = var.AZ2
    
    tags = {
    Name = "pubsub"
    }
}


# priv. subnet for app server with 256 hosts
resource "aws_subnet" "appsub1" {
    cidr_block        = "10.0.2.0/24" 
    vpc_id            = aws_vpc.clixxvpc.id
    availability_zone = var.AZ1
    
    tags = {
    Name = "appsub1"
    }
}

# priv. subnet for app server with 450 hosts
resource "aws_subnet" "appsub2" {
    cidr_block        = "10.0.3.0/25"
    vpc_id            = aws_vpc.clixxvpc.id
    availability_zone = var.AZ2
    
    tags = {
    Name = "appsub2"
    }
}

# priv. subnet for RDS with 680 hosts
resource "aws_subnet" "rdssub1" {
    cidr_block        = "10.0.4.0/26"
    vpc_id            = aws_vpc.clixxvpc.id
    availability_zone = var.AZ1
    
    tags = {
    Name = "rdssub1"
    }
}

# priv. subnet for RDS with 680 hosts
resource "aws_subnet" "rdssub2" {
    cidr_block        = "10.0.5.0/26"
    vpc_id            = aws_vpc.clixxvpc.id
    availability_zone = var.AZ2
    
    tags = {
    Name = "rdssub2"
    }
}

# priv. subnet for Oracle with 254 hosts
resource "aws_subnet" "orasub1" {
    cidr_block        = "10.0.6.0/24"
    vpc_id            = aws_vpc.clixxvpc.id
    availability_zone = var.AZ1
    
    tags = {
    Name = "orasub1"
    }
}

# priv. subnet for Oracle with 254 hosts
resource "aws_subnet" "orasub2" {
    cidr_block        = "10.0.7.0/24" 
    vpc_id            = aws_vpc.clixxvpc.id
    availability_zone = var.AZ2
    
    tags = {
    Name = "orasub2"
    }
}

# bastion sec group
resource "aws_security_group" "publicsg"{
    name        = "publicsg_tf"
    description = "public securtiy group"
    vpc_id      = aws_vpc.clixxvpc.id
    revoke_rules_on_delete = "true"

    ingress{
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    
    
    ingress{
        description = "MYSQL/Aurora"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress{
        description="NFS"
        from_port   = 2049
        to_port     = 2049
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress{
        description = "Custom TCP"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress{
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "publicsg_tf"
    }
}

# app sg allow bastion sg
resource "aws_security_group" "appsg_tf"{
    name        = "appsg_tf"
    description = "appsg allow publicsg"
    vpc_id      = aws_vpc.clixxvpc.id
    revoke_rules_on_delete = "true"

    ingress{
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.publicsg.id]
    }

    ingress{
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        security_groups = [aws_security_group.publicsg.id] 
    }

    ingress{
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.publicsg.id]
    }    
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "appsg_tf"
    }
}

# rds sg allow app sg
resource "aws_security_group" "rdssg_tf"{
    name        = "rdssg_tf"
    description = "rdssg allow appsg"
    vpc_id      = aws_vpc.clixxvpc.id
    revoke_rules_on_delete = "true"

    ingress{
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.appsg_tf.id]
    }    
    
    ingress{
        description = "MYSQL/Aurora"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        security_groups = [aws_security_group.appsg_tf.id]
    } 

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "rdssg_tf"
    }
}

# oracle sg allow bastion sg
resource "aws_security_group" "orasg_allow_publicsg"{
    name        = "orasg_allow_publicsg"
    description = "orasg allow publicsg"
    vpc_id      = aws_vpc.clixxvpc.id
    revoke_rules_on_delete = "true"

    ingress{
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.publicsg.id]
    }    
    
    ingress{
        description = "Oracle-RDS"
        from_port   = 1521
        to_port     = 1521
        protocol    = "tcp"
        security_groups = [aws_security_group.publicsg.id]
    } 

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "orasg_allow_publicssg"
    }
}

# create internet gateway for the public subnet
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.clixxvpc.id
}

# create custom route table and add internet gateway
resource "aws_route_table" "custome_route_table" {
    vpc_id = aws_vpc.clixxvpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
    }

    tags = {
    Name = "custome_route_tabletf"
    }
}

# associatec custome rout table with pub subnets
resource "aws_route_table_association" "attach_pub" {
    for_each = {
        sub1 = aws_subnet.bastionsub.id
        sub2 = aws_subnet.pubsub.id
    }
    route_table_id = aws_route_table.custome_route_table.id
    subnet_id      = each.value
}

# create elastic ip
resource "aws_eip" "eip" {
    vpc = true
}

# create nat gateway for communication with the private subnet
resource "aws_nat_gateway" "natgateway" {
    allocation_id = aws_eip.eip.id
    subnet_id     = aws_subnet.pubsub.id
    depends_on = [aws_internet_gateway.ig]
}

# create Main route table and add nat gateway 
resource "aws_route_table" "main_route_table" {
    vpc_id = aws_vpc.clixxvpc.id

    route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway.id
    }

    tags = {
    Name = "main_route_tabletf"
    }
}

# associate nat (main rout table) to priv app subnet
resource "aws_route_table_association" "attach_priv" {
    for_each = {
        sub1 = aws_subnet.appsub1.id
        sub2 = aws_subnet.appsub2.id
        sub3 = aws_subnet.rdssub1.id
        sub4 = aws_subnet.rdssub2.id
        sub5 = aws_subnet.orasub1.id
        sub6 = aws_subnet.orasub2.id
    }
    route_table_id = aws_route_table.main_route_table.id
    subnet_id      = each.value
}

# create load balancer
resource "aws_alb" "clixxalb" {
    name               = "clixxvpcalbtf"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.publicsg.id]
    subnets            = [aws_subnet.bastionsub.id, aws_subnet.pubsub.id]

    enable_deletion_protection = false

    tags = {
        Environment = "alb_tf"
    }
}

# create target group
resource "aws_lb_target_group" "clixxtg" {
    name     = "clixxvpc-alb-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.clixxvpc.id

    health_check {
        path = "/index.php"
    }
}

# create listener
resource "aws_lb_listener" "clixxlistener" {
    load_balancer_arn = aws_alb.clixxalb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clixxtg.arn
    }
}

# restore snapshot - create db from snapshot
resource "aws_db_instance" "clixxdbinsttf" {
    identifier               = "clixxdbrestoretf"
    instance_class           = "db.t2.micro"
    db_subnet_group_name     = aws_db_subnet_group.rdssubnetgroup.id
    username                 = local.db_creds.username
    password                 = local.db_creds.password
    snapshot_identifier      = "clixxdbsnap"
    vpc_security_group_ids   = [aws_security_group.rdssg_tf.id]
    skip_final_snapshot      = true
    availability_zone        = var.AZ1
}

data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
  secret_id = "creds"
}
locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

# rds subnet group - allows db to reside in 2 AZs
resource "aws_db_subnet_group" "rdssubnetgroup" {
    name       = "clixxrdssubnetgroup"
    subnet_ids = [aws_subnet.rdssub1.id, aws_subnet.rdssub2.id]

    tags = {
    Name = "rds subnet group"
    }
} 

# create bastion ec2 
resource "aws_instance" "bastion" {
    ami             = "ami-0742b4e673072066f"
    instance_type   = "t2.micro"
    #iam_instance_profile = aws_iam_instance_profile.s3_profile.name
    key_name = "MyEC2KeyPair"
    vpc_security_group_ids = [aws_security_group.publicsg.id]
    availability_zone = var.AZ1
    subnet_id = aws_subnet.bastionsub.id
    associate_public_ip_address = true
    tags = {
        Name = "bastionEC2tf"
    }
}

# configure launch configuration for app server asg
resource "aws_launch_configuration" "clixxvpc_launch" {
    name   = "clixxvpc_launchtf" 
    image_id      = var.AMIS["us-east-1"]
    instance_type = "t2.micro"
    #iam_instance_profile = aws_iam_instance_profile.s3_profile.name
    #tls_private_key = "MyEC2KeyPair_Priv"
    key_name = "MyEC2KeyPair"
    security_groups = [aws_security_group.appsg_tf.id]

    user_data = templatefile("bootstrap2.sh", {
        REGION       = var.AWS_REGION,
        DB_NAME      = var.DB_NAME,
        DB_USER      = var.DB_USER,
        DB_PASSWORD  = var.DB_PASSWORD,
        RDS_ENDPOINT = aws_db_instance.clixxdbinsttf.address,
        MOUNT_POINT  = var.MOUNT_POINT
        LB_DNS       = aws_alb.clixxalb.dns_name 
    })

    depends_on = [aws_db_instance.clixxdbinsttf] 

    #lifecycle {
    #create_before_destroy = true
    #}
} 

## autoscaling group
resource "aws_autoscaling_group" "clixxvpc_asg" {
    name                 = "clixxvpc_asg"
    launch_configuration = aws_launch_configuration.clixxvpc_launch.name
    min_size             = 1
    max_size             = 2
    desired_capacity     = 1
    vpc_zone_identifier  = [aws_subnet.appsub1.id, aws_subnet.appsub2.id]
    health_check_grace_period = 300 
    target_group_arns = [aws_lb_target_group.clixxtg.arn]
    force_delete      = true 
}

output "instance_public_ip" {
    value = aws_instance.bastion.public_ip
}

# attach load balancer to asg
resource "aws_autoscaling_attachment" "attachclixx" {
    autoscaling_group_name = aws_autoscaling_group.clixxvpc_asg.id
    alb_target_group_arn   = aws_lb_target_group.clixxtg.arn
}

# s3 backend configuration for remote state
terraform {
    backend "s3"{
        bucket  = "stackbuckstate-shavon1"
        key     = "terraform.tfstate"
        region  = "us-east-1"
        dynamodb_table = "statelock-tf"
    }
}

