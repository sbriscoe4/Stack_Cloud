#create security group
resource "aws_security_group" "stack_sg"{
    name="stack_sec_group"
    description="stack sec group"
    vpc_id="vpc-8a258ef7"

    ingress{
        description="HTTP"
        from_port=80
        to_port=80
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }

    ingress{
        description="SSH"
        from_port=22
        to_port=22
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }    
    
    ingress{
        description="MYSQL/Aurora"
        from_port=3306
        to_port=3306
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    } 

    ingress{
        description="NFS"
        from_port=2049
        to_port=2049
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    } 

    ingress{
        description="Custom TCP"
        from_port=8080
        to_port=8080
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    } 

    ingress{
        description="HTTPS"
        from_port=443
        to_port=443
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    } 

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

    tags={
        Name="stack_sec_group-tf"
    }
}

#create s3 policy
resource "aws_iam_policy" "policy" {
    name        = "s3_policy"
    description = "s3 admin access policy"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "s3:*",
        "Effect": "Allow",
        "Resource": "*" 
        }
    ]
}
    EOF
} 

#create role 
resource "aws_iam_role" "s3_role" {
    name = "s3-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
            "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
    EOF 
}

#attach s3 policy to role
resource "aws_iam_policy_attachment" "s3_attach" {
    name       = "s3-attachment"
    policy_arn = aws_iam_policy.policy.arn
    roles       =  [aws_iam_role.s3_role.name]
} 

# create ec2 instance profile with s3 role
resource "aws_iam_instance_profile" "s3_profile" {
    name = "s3_profile"
    role = aws_iam_role.s3_role.name
}

#create efs
resource "aws_efs_file_system" "efs" {
    creation_token = "stack_efs"
    encrypted = true
    throughput_mode = "bursting"
    tags = {
        Name = "wp_efs-tf"
    }
}

#creating Mount target of EFS
resource "aws_efs_mount_target" "mount" {
    depends_on = [aws_efs_file_system.efs]
    file_system_id = aws_efs_file_system.efs.id
    subnet_id      = "subnet-10e47f4f" #aws_instance.web.subnet_id
    security_groups = [aws_security_group.stack_sg.id]
}

#creating Mount Point for EFS
resource "null_resource" "configure_nfs" {
    depends_on = [aws_efs_mount_target.mount]
    connection {
        type     = "ssh"
        user     = "ec2-user"
        private_key = tls_private_key.my_key.private_key_pem
        host     = aws_instance.web.public_ip
    }

}

#create ec2 
resource "aws_instance" "web" {
    ami           = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.s3_profile.name
    key_name = "MyEC2KeyPair"
    security_groups = [aws_security_group.stack_sg.name]
    tags = {
        Name = "wp_inst-tf"
    }
        
    #user_data = file("${path.module}/bootstrap.sh") 
    user_data = templatefile("clixxapp/bootstrap.sh", {
        efs_id       = aws_efs_file_system.efs.id,
        REGION       = var.AWS_REGION,
        DB_NAME      = var.DB_NAME,
        DB_USER      = var.DB_USER,
        DB_PASSWORD  = var.DB_PASSWORD,
        RDS_ENDPOINT = var.RDS_ENDPOINT,
        MOUNT_POINT  = var.MOUNT_POINT
    })
} 

#s3 backend configuration for remote state
terraform {
    backend "s3"{
        bucket= "stackbuckstate-shavon"
        key= "terraform.tfstate"
        region= "us-east-1"
        dynamodb_table= "statelock-tf"
    }
}

/*
## launch configureation
resource "aws_launch_configuration" "wp_launch" {
    name   = "wp_launch" 
    image_id      = var.AMIS["us-east-1"]
    instance_type = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.s3_profile.name
    key_name = "MyEC2KeyPair"
    security_groups = [aws_security_group.stack_sg.name]
    user_data = templatefile("WordPressEFS2.sh", {
        efs_id       = aws_efs_file_system.efs.id,
        REGION       = var.AWS_REGION,
        DB_NAME      = var.DB_NAME,
        DB_USER      = var.DB_USER,
        DB_PASSWORD  = var.DB_PASSWORD,
        RDS_ENDPOINT = var.RDS_ENDPOINT,
        MOUNT_POINT  = "/var/www/html"
    })
} 

## autoscaling group
resource "aws_autoscaling_group" "wp_asg" {
    name                 = "wp_asg"
    launch_configuration = aws_launch_configuration.wp_launch.name
    min_size             = 1
    max_size             = 2
    desired_capacity     = 1
    vpc_zone_identifier  = ["subnet-10e47f4f"]
}
*/

#autoscaling policy




