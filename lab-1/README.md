# Lab 1 - Packer

This lab is all about [Packer](https://www.packer.io/). Have fun!

## Relevant Documentation

- [Amazon Machine Images (AMI)](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
- [Packer Amazon EBS Builder](https://www.packer.io/docs/builders/amazon-ebs.html)
- [Packer Shell Provisioner](https://www.packer.io/docs/provisioners/shell.html)
- [Packer Chef Solo Provisioner](https://www.packer.io/docs/provisioners/chef-solo.html)
- [Packer Command-Line: Build](https://www.packer.io/docs/command-line/build.html)

## EBS Builder Example

In the first example we take a look at how the `amazon-ebs` builder works. You'll find all the relevant files in [lab-1/ebs-builder/](https://github.com/b4nk/aws-automation/tree/master/lab-1/ebs-builder). Provisioning part is kept deliberately simple and consists only of two shell scripts. You can find those in the [lab-1/ebs-builder/scripts](https://github.com/b4nk/aws-automation/tree/master/lab-1/ebs-builder/scripts) folder.

    ~/aws-automation# cd lab-1/

Take a look at the builders part of the template.

    ~/aws-automation/lab-1# cat ebs-builder/template.json | jq '.builders[0]'

Here we have chosen to use the latest Ubuntu Trusty AMI as the source for our build.

    ~/aws-automation/lab-1# source_ami=$(jq -r '.builders[0].source_ami' < ebs-builder/template.json)
    ~/aws-automation/lab-1# aws ec2 describe-images --image-ids $source_ami

It's usually also a good idea to run `validate` on the template before you start a build.

    ~/aws-automation/lab-1# packer validate
    ~/aws-automation/lab-1# packer validate -syntax-only ebs-builder/template.json
    ~/aws-automation/lab-1# packer validate ebs-builder/template.json

Now start the build. Packer is going to launch an EC2 instance from the source AMI, provision the instance, and finally create a new AMI from a snapshot. This is going to take a while.

    ~/aws-automation/lab-1# packer build ebs-builder/template.json
    [...]
    ==> Builds finished. The artifacts of successful builds are:
    --> amazon-ebs: AMIs were created:

    eu-central-1: ami-abcd1234

You should now be able to check your new AMI on EC2. You might also want to look up your AMI on the [EC2 Console]( https://eu-central-1.console.aws.amazon.com/ec2/#images).

    ~/aws-automation/lab-1# aws ec2 describe-images --image-ids ami-abcd1234

Use the provided helper script to launch an EC2 instance using the new image. Pass your EC2 key pair name and the id of your freshly minted AMI as the arguments. The script will output the hostname of your EC2 instance.

    ~/aws-automation/lab-1# cd ..

    ~/aws-automation# bash tools/run-ec2-instance.sh -k jane.doe -i ami-abcd1234

SSH into your instance and check the results. Now you have an AMI with `cowsay` baked in--yay! Note that it might take a while for the instance to boot.

    $ ssh -i ssh-keys/ec2-key.pem ubuntu@ec2-54-93-53-242.eu-central-1.compute.amazonaws.com
    ubuntu@ip-172-31-28-58:~$ cowsay building AMIs is nice!
    ubuntu@ip-172-31-28-58:~$ exit

Finally destroy the instance. You'll find the instance id in the output of the launch helper script.

    ~/aws-automation# aws ec2 terminate-instances --instance-ids i-abcd1234

## Chef-Solo Provisioner Example

In this example we're going to build a simple web server AMI using the `chef-solo` provisioner. Builder configuration in the template is more or less the same as in the previous example except we're using template variables instead of hardcoding values directly in builder configuration. You'll find all the relevant files in [lab-1/chef-solo-provisioner/](https://github.com/b4nk/aws-automation/tree/master/lab-1/chef-solo-provisioner)

Start by editing the template and finishing the provisioners part. You need to create configuration for a `chef-solo` provisioner from scratch. The provisioner is supposed to install nginx using the [nginx cookbook](https://supermarket.chef.io/cookbooks/nginx). You'll find this cookbook and all it's dependencies in the [lab-1/chef-solo-provisioner/cookbooks](https://github.com/b4nk/aws-automation/tree/master/lab-1/chef-solo-provisioner/cookbooks). Take a look at the
[Chef Solo provisioner](https://www.packer.io/docs/provisioners/chef-solo.html) docs.

Option         | Value
---------------|---------------------------------
cookbook_paths | chef-solo-provisioner/cookbooks
run_list       | recipe[nginx]

Edit the Packer template and run `validate` until things check out with the `chef-solo` provisioner.

    ~/aws-automation/lab-1# packer validate chef-solo-provisioner/template.json

Start the build and make sure that the provisioning part of the process works without any problems.

    ~/aws-automation/lab-1# packer build chef-solo-provisioner/template.json

And if this completes start an instance.

    ~/aws-automation# bash tools/run-ec2-instance.sh -k jane.doe -i ami-abcd1234

Wait for the instance to boot. If everything worked as it was supposed to then you should be able to open you instances public DNS address in your browser.

Finally destroy the instance.

    ~/aws-automation# aws ec2 terminate-instances --instance-ids i-abcd1234

# Extra: Building a Vagrant Box with Packer

TODO
