resource "aws_key_pair" "bastion" {

  key_name = "bpay-etl-bastion-key"

  public_key = file(pathexpand("~/.ssh/bpay-etl.pub"))

}