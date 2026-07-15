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

  #############################################
  # COPY SCRIPTS
  #############################################

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/home/ubuntu"
  }

  #############################################
  # COPY SQL FILES
  #############################################

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

  #############################################
  # INITIALIZE DATABASE
  #############################################
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/bpay/scripts",
      "sudo mkdir -p /opt/bpay/sql",
      "sudo cp -r /home/ubuntu/scripts/* /opt/bpay/scripts/",
      "sudo cp /home/ubuntu/init-*.sql /opt/bpay/sql/",
      "sudo chmod +x /opt/bpay/scripts/*.sh",
      "ls -lrt /opt/bpay/scripts",
      "ls -lrt /opt/bpay/sql"
    ]
  }
} 