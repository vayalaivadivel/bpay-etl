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

      "echo '===== HOME UBUNTU ====='",
      "ls -al /home/ubuntu",

      "echo '===== EC2 DIRECTORY ====='",
      "ls -al /home/ubuntu/ec2 || true",

      "echo '===== SCRIPTS ====='",
      "ls -al /home/ubuntu/scripts",

      "sudo mkdir -p /opt/bpay/scripts",
      "sudo mkdir -p /opt/bpay/sql",

      "sudo cp -r /home/ubuntu/scripts/* /opt/bpay/scripts/",
      "sudo cp -r /home/ubuntu/ec2/* /opt/bpay/sql/",

      "echo '===== OPT SQL ====='",
      "ls -al /opt/bpay/sql",

      "echo '===== RUN INIT ====='",
      "bash -x /opt/bpay/scripts/init-db.sh",

      "echo '===== VERIFY ====='",
      "bash -x /opt/bpay/scripts/verify-db.sh"
    ]
  }
}