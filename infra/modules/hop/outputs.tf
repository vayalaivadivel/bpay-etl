output "alb_dns" {
  value = aws_lb.hop.dns_name
}
output "ecs_cluster_id" {

  value = aws_ecs_cluster.hop.id
}

output "ecs_cluster_name" {

  value = aws_ecs_cluster.hop.name
}

output "alb_listener_arn" {
  value = aws_lb_listener.hop.arn
}

output "alb_sg_id" {

  value = aws_security_group.hop_alb.id
}