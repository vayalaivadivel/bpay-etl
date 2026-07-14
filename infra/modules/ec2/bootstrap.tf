resource "terraform_data" "bootstrap" {

  depends_on = [
    aws_instance.bastion
  ]

  triggers_replace = [
    aws_instance.bastion.id
  ]

  connection {
    type        = "ssh"
    host        = aws_instance.bastion.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {

    source = "${path.module}/scripts"

    destination = "/home/ubuntu"

  }

  provisioner "remote-exec" {

    inline = [

      "chmod +x /home/ubuntu/scripts/*.sh",

      "echo '===== SCRIPTS ====='",

      "ls -lrt /home/ubuntu/scripts",

      "echo '===== SQL ====='",

      "ls -lrt /home/ubuntu/sql"

    ]

  }

}