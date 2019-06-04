provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "local_file" "students" {
    filename = "${var.output_filename}"
}

resource "random_string" "password" {
  count             = "${var.instance_count}"
  length            = 12
  special           = true
  override_special  = "@"
}

resource "aws_instance" "aws_configure" {
  count           = "${var.instance_count}"
  ami             = "${var.ami}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"


  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "sudo service sshd restart",
      "sudo useradd student${count.index+1}",
      "sudo echo ${random_string.password.*.result[count.index]} | sudo passwd student${count.index+1} --stdin",
      "sudo yum -y update",
      "sudo yum install -y git",
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(join("", list(var.key_name, ".pem")))}"
    }
  }

  provisioner "local-exec" {
    command = "echo student${count.index+1}: ${random_string.password.*.result[count.index]} : ${self.public_ip} >> ${var.output_filename}"
  }

}
