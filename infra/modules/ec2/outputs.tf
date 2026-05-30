output "public_ip" {
  value = aws_instance.bastion.public_ip
}

output "public_dns" {
  value = aws_instance.bastion.public_dns
}

output "instance_id" {
  value = aws_instance.bastion.id
}
output "security_group_id" {

  value = aws_security_group.bastion_sg.id
}