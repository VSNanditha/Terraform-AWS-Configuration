provider "aws" {}

resource "local_file" "students" {
    filename = "students.txt"
}

resource "random_string" "password" {
  length            = 12
  special           = true
  override_special  = "@"
  count             = 2

}

resource "aws_instance" "aws_configure" {
  count           = 2
  ami             = "ami-0756fbca465a59a30"
  instance_type   = "t2.micro"
  key_name        = "MyAWSKey2"
  vpc_security_group_ids = [
    "sg-037d55c15f0d46c39"
  ]

  # provisioner "file" {
  #   source      = "script.sh"
  #   destination = "/tmp/"
  # }

  provisioner "remote-exec" {
    inline = [
      "echo ${random_string.password.*.result[count.index]}",
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
      private_key = "${file("MyAWSKey2.pem")}"
    }
  }

  provisioner "local-exec" {
    command = "echo student${count.index+1}: ${random_string.password.*.result[count.index]} : ${self.public_ip} >> students.txt"
  }

}
