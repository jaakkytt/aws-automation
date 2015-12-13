# AWS Infrastructure Automation Hands-on

TODO index labs

## Getting Started

Lab setup is identical to the one we used for *AWS Bootcamp*. We only assume that you have Docker installed on your laptop. Windows and OS X users refer to [AWS Bootcamp materials](https://github.com/b4nk/aws-bootcamp) if you need a refresher on Docker Machine.

### 1. Download your AWS access key

Sign in to your AWS account and head over to the [IAM console](https://console.aws.amazon.com/iam/home#users). Should you need it, you'll find the sign-in link in the email with your AWS user account details.

Once you're on the *Users* page find your AWS account from the list. Open the *Security Credentials* tab and click *Create Access Key*. Finally choose *Download Credentials*. You'll find your *Access Key ID* and *Secret Access Key* in the downloaded `credentials.csv` file.

### 2. Clone the [b4nk/aws-automation](https://github.com/b4nk/aws-automation.git) repo

    $ git clone https://github.com/b4nk/aws-automation.git /path/to/repo/clone

If you're on Windows, you might want to [download the ZIP archive]( https://github.com/b4nk/aws-automation/archive/master.zip) instead. This is to avoid problems with Git converting line endings.

### 3. Run the Docker container

Pull the latest image.

    $ docker pull taavitani/aws-automation:latest

And run the container mounting your repo clone using the `-v` option.

    $ docker run -it -v /path/to/repo/clone:/root/aws-automation taavitani/aws-automation

If you're on Windows.

    PS > .\docker.exe pull taavitani/aws-automation:latest
    PS > .\docker.exe run -it -v /c/path/to/repo/clone:/root/aws-automation taavitani/aws-automation

If the repo clone was successfully mounted you should see the contents in the container.

    ~/aws-automation# ls

### 4. Configure AWS credentials and region

Run the AWS `config` command. You'll need your *AWS Access Key ID* and *AWS Secret Access Key* from the `credentials.csv` file you downloaded earlier. Also set the default region to `eu-central-1`.

    ~/aws-automation# aws configure

Finally, check that your AWS access is actually working. You should see a JSON response with your account details.

    ~/aws-automation# aws iam get-user

### 5. Create your EC2 key pair (SSH key)

Run the provided helper script to create your EC2 key pair.

    ~/aws-automation# bash tools/create-ec2-key-pair.sh

This writes the private key to `~/aws-automation/ssh-keys/ec2-key.pem`. So it's accessible from the host in the `/path/to/repo/clone/ssh-keys` folder. If you're using PuTTY then you might want to run PuTTYgen to convert this to .ppk.
