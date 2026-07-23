resource "null_resource" "bootstrap" {

  depends_on = [
    aws_instance.bastion,
    local_file.init_databases,
    local_file.init_source,
    local_file.init_replicated,
    local_file.init_unified
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
  # COPY RENDERED SQL
  #############################################

  provisioner "file" {
    source      = "${path.root}/.terraform-rendered/ec2"
    destination = "/home/ubuntu"
  }

  #############################################
  # INITIALIZE DATABASE
  #############################################

  provisioner "remote-exec" {
    inline = [
      "set -euxo pipefail",

      "echo '===== HOME ====='",
      "pwd",

      "echo '===== /home/ubuntu ====='",
      "ls -al /home/ubuntu",

      "echo '===== /home/ubuntu/scripts ====='",
      "ls -al /home/ubuntu/scripts",

      "echo '===== /home/ubuntu/ec2 ====='",
      "ls -al /home/ubuntu/ec2",

      "sudo mkdir -p /opt/bpay/scripts",
      "sudo mkdir -p /opt/bpay/sql",

      "sudo cp -rv /home/ubuntu/scripts/* /opt/bpay/scripts/",
      "sudo cp -rv /home/ubuntu/ec2/* /opt/bpay/sql/",

      "echo '===== /opt/bpay/sql ====='",
      "ls -al /opt/bpay/sql",

      "echo '===== init-db ====='",
      "bash -x /opt/bpay/scripts/init-db.sh",

      "echo '===== verify-db ====='",
      "bash -x /opt/bpay/scripts/verify-db.sh"
    ]
  }



}