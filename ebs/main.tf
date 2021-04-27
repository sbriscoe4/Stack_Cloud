#cloud-boothook
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


#create EBS Volume 
resource "aws_ebs_volume" "stackvol1" {
    availability_zone = "us-east-1a"
    size              = 40

    tags = {
        Name = "stack_vol-tf"
    }
}

resource "aws_ebs_volume" "stackvol2" {
    availability_zone = "us-east-1a"
    size              = 40

    tags = {
        Name = "stack_vol-tf"
    }
}

resource "aws_ebs_volume" "stackvol3" {
    availability_zone = "us-east-1a"
    size              = 40

    tags = {
        Name = "stack_vol-tf"
    }
}

resource "aws_ebs_volume" "stackvol4" {
    availability_zone = "us-east-1a"
    size              = 40

    tags = {
        Name = "stack_vol-tf"
    }
}

#create ec2 
resource "aws_instance" "web" {
    ami           = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    #iam_instance_profile = aws_iam_instance_profile.s3_profile.name
    key_name = "MyEC2KeyPair"
    security_groups = [aws_security_group.stack_sg.name]
    #subnet_id = "subnet-10e47f4f"
    availability_zone = "us-east-1a"
    tags = {
        Name = "ebs_inst-tf"
    }
    user_data = file("EBS.sh") 
} 

#attach EBS Volume 
resource "aws_volume_attachment" "vol1_attach" {
    device_name = "/dev/sdb"
    volume_id = "${aws_ebs_volume.stackvol1.id}"
    instance_id = "${aws_instance.web.id}"
    force_detach = true
}

resource "aws_volume_attachment" "vol2_attach" {
    device_name = "/dev/sdc"
    volume_id = "${aws_ebs_volume.stackvol2.id}"
    instance_id = "${aws_instance.web.id}"
    force_detach = true
}

resource "aws_volume_attachment" "vol3_attach" {
    device_name = "/dev/sdd"
    volume_id = "${aws_ebs_volume.stackvol3.id}"
    instance_id = "${aws_instance.web.id}"
    force_detach = true
}

resource "aws_volume_attachment" "vol4_attach" {
    device_name = "/dev/sde"
    volume_id = "${aws_ebs_volume.stackvol4.id}"
    instance_id = "${aws_instance.web.id}"
    force_detach = true
}