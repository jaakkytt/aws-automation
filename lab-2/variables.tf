// EDIT! The name of your EC2 key pair.
variable "aws_key_name" {
  default = "edit.this"
}

// No need to change if you used the provided key pair helper script.
variable "aws_key_path" {
  default = "/root/aws-automation/ssh-keys/ec2-key.pem"
}

// EDIT! A unique name for your project. For example firstname-lastname.
variable "project_name" {
  default = "edit-this-as-well"
}

// The default region for AWS.
variable "aws_region" {
  default = "eu-central-1"
}

// Ubuntu Trusty AMIs
variable "aws_amis" {
  default = {
    eu-central-1    = "ami-02392b6e"
    eu-west-1       = "ami-6514ce16"
  }
}
