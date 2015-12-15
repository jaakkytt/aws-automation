resource "aws_instance" "lab-2-web" {
  count = 1
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  subnet_id = "${aws_subnet.lab-2.id}"
  vpc_security_group_ids = ["${aws_security_group.lab-2.id}"]
  tags { Name = "lab-2-${var.project_name}-web-${count.index}" }
}
