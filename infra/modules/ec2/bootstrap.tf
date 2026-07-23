resource "null_resource" "bootstrap" {

  depends_on = [
    aws_instance.bastion
  ]

  triggers = {
    bastion_id = aws_instance.bastion.id
  }

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
    source      = "${path.module}/rendered"
    destination = "/home/ubuntu"
  }

  #############################################
  # INITIALIZE DATABASE
  #############################################
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/bpay/scripts",
      "sudo mkdir -p /opt/bpay/sql",

      "sudo cp -r /home/ubuntu/scripts/* /opt/bpay/scripts/",
      "sudo cp -r /home/ubuntu/rendered/* /opt/bpay/sql/",

      "sudo chmod +x /opt/bpay/scripts/*.sh",

      "ls -lrt /opt/bpay/scripts",
      "ls -lrt /opt/bpay/sql",

      "bash /opt/bpay/scripts/init-db.sh",
      "bash /opt/bpay/scripts/verify-db.sh"
    ]
  }
}