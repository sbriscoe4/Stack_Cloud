variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}


variable "AWS_REGION" {
  default = "us-east-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}

variable "AMIS" {
  type = map(string)
  default = {
    #us-east-1 = "ami-13be557e"
    us-east-1 = "ami-08f3d892de259504d"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}

#variable "RDS_PASSWORD" {}

#variable "INSTANCE_USERNAME" {}

variable "DB_NAME" {}

variable "DB_USER" {}

variable "DB_PASSWORD" {}

#variable "DB_HOST" {}

variable "SUBNET_ID" {
    default = "subnet-10e47f4f"
}

variable "RDS_ENDPOINT" {}

variable "MOUNT_POINT"{
    default = "/var/www/html"
}