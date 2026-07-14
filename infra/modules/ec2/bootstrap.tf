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
    source      = "${path.module}/init-databases.sql.tpl"
    destination = "/home/ubuntu/init-databases.sql"
    }

    provisioner "file" {
    source      = "${path.module}/init-source.sql.tpl"
    destination = "/home/ubuntu/init-source.sql"
    }

    provisioner "file" {
    source      = "${path.module}/init-replicated.sql.tpl"
    destination = "/home/ubuntu/init-replicated.sql"
    }

    provisioner "file" {
    source      = "${path.module}/init-unified.sql.tpl"
    destination = "/home/ubuntu/init-unified.sql"
    }
  provisioner "remote-exec" {

    inline = [

      "chmod +x /home/ubuntu/scripts/*.sh",

      "echo '===== SCRIPTS ====='",

      "ls -lrt /home/ubuntu/scripts",

      "echo '===== SQL ====='",

      "ls -lrt /home/ubuntu/*.sql"

    ]

  }

}