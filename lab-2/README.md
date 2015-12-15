# Lab 2 - Terraform

In this lab you'll be using Terraform to bring up a web server cluster on EC2.

A quick note about how this lab is set up. We've split the process of creating the infrastructure into stages. For each stage there is a directory with it's Terraform configuration for creating the infrastructure in that stage. So the configuration is built up step-by-step by adding (and in some cases modifying) configuration with each stage. You could `diff` the `main.tf` files between stages to check what changed.

## Relevant Documentation

[AWS: What is Amazon VPC?](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Introduction.html)
[AWS: Elastic Load Balancing](https://aws.amazon.com/elasticloadbalancing/)
[Terraform: Commands (CLI)](https://www.terraform.io/docs/commands/index.html)
[Terraform: AWS Provider](https://www.terraform.io/docs/providers/aws/index.html)
[Terraform: DNSimple Provider](https://www.terraform.io/docs/providers/dnsimple/index.html)

## Terraform variables

Edit the lab-2/variables.tf file and update the default values for `aws_key_name` and `project_name`. You'll find instructions in the file. And run the `copy-variables-file.sh` script. You now should have the same `variables.tf` file in each subdirectory of `lab-2`.

    ~/aws-automation/lab-2# bash copy-variables-file.sh

## Create the VPC

TODO Security Group

Let's start by creating the VPC and it's associated resources as defined in `01-vpc/aws.tf`. The same file will be repeating for all subsequent steps (02-single-instance/aws.tf has exactly the same contents etc.). That is the VPC configuration will remain unchanged throughout the rest of the lab.

First run `plan` to get a sense of what Terraform will do.

    ~/aws-automation/lab-2# terraform plan 01-vpc/
    [...]
    Plan: 6 to add, 0 to change, 0 to destroy.

Okay, now let's build the first stage of the infrastructure.

    ~/aws-automation/lab-2# terraform apply 01-vpc/
    [...]
    Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Running `plan` again after the `apply` operation has completed should be interesting. Terraform should indicate that infrastructure as defined in `01-vpc/` is actually running on AWS--no changes necessary.

    ~/aws-automation/lab-2# terraform plan 01-vpc/
    [...]
    No changes. Infrastructure is up-to-date. This means that Terraform
    could not detect any differences between your configuration and
    the real physical resources that exist. As a result, Terraform
    doesn't need to do anything.

    terraform plan 02-single-instance/
    Plan: 1 to add, 0 to change, 0 to destroy.

You might want to check out the [VPC Console]( https://eu-central-1.console.aws.amazon.com/vpc/home#vpcs:) to get a better sense of infrastructure build in this step. Use the project name you set in `variables.tf` to find your VPC.

## Create a single EC2 instance

In this step you'll be creating a single EC2 instance. Take a look at the 02-single-instance/main.tf file and run terraform.

    ~/aws-automation/lab-2# terraform apply 02-single-instance/
    [...]
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

## Provision the EC2 instance

Take a look at 03-provision-instance/main.tf and compare it to the configuration in the previous step. The instance now has provisioner stanzas for installing a web server.

Running `apply` with the updated configuration might be a little bit surprising at first since terraform reports that no changes are needed.

    ~/aws-automation/lab-2# terraform apply 03-provision-instance/
    [...]
    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

This actually makes sense if you consider that provisioning is something that happens when EC2 instances boot. In this situation Terraform has already created the instance and is unable to know which provisioners have been executed. So the solution here is to destroy and re-create the instance for provisioning to happen. Terraform provides the `taint` command for exactly this purpose. This can be used to signal Terraform that a resource needs to be recreated.

    ~/aws-automation/lab-2# terraform taint aws_instance.lab-2-web

And run `apply` again. This time you should see the `lab-2-web` instance being destroyed and re-created.

    ~/aws-automation/lab-2# terraform apply 03-provision-instance/
    [...]
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    [...]
    Outputs:

      address = ec2-52-59-253-91.eu-central-1.compute.amazonaws.com

Open the address in the browser. You should see the default Apache page.

## Create a load balancer

Again, take a look at the changes in `04-load-balancer/main.tf`. The number of `lab-2-web` instances has been increased to 3. Plus the provisioning code has been updated slightly. And a load balancer resource has been added.

Okay, lets see what Terraform would do if we go forward with this config.

    ~/aws-automation/lab-2# terraform plan 04-load-balancer/
    Plan: 3 to add, 0 to change, 0 to destroy.

And before we run `apply` we have to taint the instance carried over from the previous step to re-run provisioning.

    ~/aws-automation/lab-2# terraform taint aws_instance.lab-2-web.0
    ~/aws-automation/lab-2# terraform apply 04-load-balancer/

Output should now also include the ELB address. Wait for instances to boot and provisioning code to finish it's work. It also takes a bit for instances to be added to the LB. Open the address in your browser and hit refresh like crazy. You should see the LB rotating your requests to different instances.

And you might want to use the [Load Balancers page on the EC2 Console](https://eu-central-1.console.aws.amazon.com/ec2/#LoadBalancers:) to check the ELB you just created.

## Create DNS records

TODO

## Destroy the provisioned infrastructure

Finally clean up and kill all resources you have created. Terraform makes this really easy:

    ~/aws-automation/lab-2# terraform destroy
