resource "aws_instance" "lab-2-web" {
  count = 3
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  subnet_id = "${aws_subnet.lab-2.id}"
  vpc_security_group_ids = ["${aws_security_group.lab-2.id}"]
  tags { Name = "lab-2-${var.project_name}-web-${count.index}" }

  connection {
    user     = "ubuntu"
    key_file = "${var.aws_key_path}"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install apache2",
      "echo \"<h1>${self.public_dns}</h1>\" | sudo tee /var/www/html/index.html",
      "echo \"<h2>${self.public_ip}</h2>\"  | sudo tee -a /var/www/html/index.html",
    ]
  }
}

resource "aws_elb" "lab-2-web" {
  name = "lab-2-${var.project_name}-web"
  subnets = ["${aws_subnet.lab-2.id}"]
  security_groups = ["${aws_security_group.lab-2.id}"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  instances = ["${aws_instance.lab-2-web.*.id}"]
  tags { Name = "lab-2-${var.project_name}-web" }
}

output "elb-address" { value = "${aws_elb.lab-2-web.dns_name}" }
output "instance-ips" { value = "${join(", ", aws_instance.lab-2-web.*.public_ip)}"}

provider "dnsimple" {
  email = "${var.dnsimple_email}"
  token = "${var.dnsimple_token}"
}

resource "dnsimple_record" "lab-2-web" {
  domain = "b4nk.systems"
  name   = "${var.subdomain}"
  value  = "${aws_elb.lab-2-web.dns_name}"
  type   = "CNAME"
  ttl    = 30
}

output "load balancer DNS record:" { value = "${dnsimple_record.lab-2-web.hostname}" }

