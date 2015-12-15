resource "aws_instance" "lab-2-web" {
  count = 1
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
    ]
  }
}

output "address" { value = "${aws_instance.lab-2-web.public_dns}" }
