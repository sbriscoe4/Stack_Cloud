
#create bucket
#versioning
#server access logging 
#store objects on bucket
#configure S3 for static website & reference policy file
#redirect request to another host
#event notifications to SNS (simple notification service) topic
#object level logging

#create log bucket
resource "aws_s3_bucket" "log_bucket" {
    bucket = "logbuckettf-shavon"
    acl    = "log-delivery-write"
    force_destroy = true
}

#create bucket
resource "aws_s3_bucket" "buck1" {
    bucket = "stackbucktf-shavon"
    acl    = "public-read"
    #enable force destroy to delete
    force_destroy = true

    #set allocation tags
    tags = {
    Name        = "Stack CSA"
    Environment = "Dev"
    }

    #versioning
    versioning {
        enabled = true
    }

    #server logging
    logging {
        target_bucket =  aws_s3_bucket.log_bucket.id 
        target_prefix = "log/"
    }   
}

#store objects on bucket
resource "aws_s3_bucket_object" "obj1" { 
    bucket = "stackbucktf-shavon"
    key    = "test_move.txt"
    acl    = "public-read"
    source = "C:/apps/terraform/tf/STACK_S3-TF/src/main/tf/test_move.txt"

    depends_on = [
    aws_s3_bucket.web_bucket-shavon,
    ]
}

#configure S3 for static website
resource "aws_s3_bucket" "web_bucket-shavon" {
    bucket = "websitetf-shavon"
    acl    = "public-read"
    policy = file("policy.json")
    force_destroy = true
    
    website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
    [{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
    }]
    EOF

    #redirect_all_requests_to = "www.google.com"
    }
}

#store objects on bucket
resource "aws_s3_bucket_object" "logo" { 
    bucket = "websitetf-shavon"
    key    = "logo.png"
    acl    = "public-read"
    source = "C:/apps/terraform/tf/STACK_S3-TF/src/main/tf/STACK_IT_LOGO.png"

    depends_on = [
    aws_s3_bucket.web_bucket-shavon,
    ]
}

resource "aws_s3_bucket_object" "index" { 
    bucket = "websitetf-shavon"
    key    = "index.html"
    acl    = "public-read"
    source = "C:/apps/terraform/tf/STACK_S3-TF/src/main/tf/index.html"

    depends_on = [
    aws_s3_bucket.web_bucket-shavon,
    ]
}

resource "aws_s3_bucket_object" "error" { 
    bucket = "websitetf-shavon"
    key    = "error.html"
    acl    = "public-read"
    source = "C:/apps/terraform/tf/STACK_S3-TF/src/main/tf/error.html"

    depends_on = [
    aws_s3_bucket.web_bucket-shavon,
    ]
}

#redirect request to another host
resource "aws_s3_bucket" "redirect_bucket" {
    bucket = "google-shavon"
    acl    = "public-read"
    force_destroy = true

    website {
        redirect_all_requests_to = "www.google.com"
    }

    tags = {
    Name        = "Stack CSA"
    Environment = "Dev"
    }
}

#event notifications to SNS (simple notification service) topic
resource "aws_sns_topic" "topic" {
    name = "s3-event-notification-topic"

    policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:s3-event-notification-topic",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"arn:aws:s3:::snsbucktf-shavon"}
        }
    }]
}
POLICY
}

resource "aws_s3_bucket" "sns_bucket" {
    bucket = "snsbucktf-shavon"
    force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = "snsbucktf-shavon" #aws_s3_bucket.bucket.id

    topic {
    topic_arn     = "arn:aws:sns:us-east-1:127910218168:s3-event-notification-topic"
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"
    }

    depends_on = [
    aws_s3_bucket.sns_bucket,
    ]
}

#lock an s3 object
resource "aws_s3_bucket" "lock_bucket" {
    bucket = "objlockbucket-shavon"
    acl    = "public-read"
    force_destroy = true

    object_lock_configuration {
    object_lock_enabled = "Enabled"
    } 

    tags = {
    Name = "Stack CSA"
    Environment = "Dev"
    }
}

resource "aws_s3_bucket_object" "obj2" {
    bucket = aws_s3_bucket.lock_bucket.id
    key    = "test_move.txt"
    acl    = "public-read"
    source = "test_move.txt"
    etag = filemd5("test_move.txt")

    object_lock_legal_hold_status = "ON"
    object_lock_mode = "GOVERNANCE"
    object_lock_retain_until_date = "2021-12-31T07:20:50.52Z"
    
    force_destroy = true
}

/*
#object logging with cloudtrail
#create objectlog bucket
resource "aws_s3_bucket" "obj_log_bucket" {
    bucket = "objlogbuckettf-shavon"
    acl    = "log-delivery-write"
    force_destroy = true
}

data "aws_s3_bucket" "objlogbuck-shavon" {
    bucket = "objlogbuck-shavon"
    force_destroy = true
    policy = <<POLICY {
        "Version": "2012-10-17"
        "Statement": [
            {
                "Sid": "AWSCloudTrailAclCheck",
                "Effect": "Allow",
                "Principal": {
                    "Service": "cloudtrail.amazonaws.com"
                },
                "Action": "s3:GetBucketAcl",
                "Resource":  "arn:aws:s3:::objlogbuck-shavon/*"

            }
        ]
    }
    POLICY
}

resource "aws_cloudtrail" "cloudtrail-shavon" {
    name = "objtrail-shavon"
    s3_bucket_name = "stackbucktf-shavon"
    is_multi_region_trail = true

    event_selector {
        read_write_type           = "All"
        include_management_events = true

        data_resource {
        type = "AWS::S3::Object"

        # Make sure to append a trailing '/' to your ARN if you want
        # to monitor all objects in a bucket.
        values = ["${data.aws_s3_bucket.important-bucket.arn}/"]
        }
    }

    depends_on = [
    aws_s3_bucket.sns_bucket,
    ]
}

*/