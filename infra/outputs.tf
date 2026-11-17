output "ecs_public_ip" {
  description = "弹性云服务器绑定的弹性公网 IP（SSH 入站地址）。"
  value       = huaweicloud_vpc_eip.ecs.address
}

output "ecs_id" {
  description = "弹性云服务器 ID。"
  value       = huaweicloud_compute_instance.server.id
}

output "ecs_private_ip" {
  description = "弹性云服务器私有 IP。"
  value       = huaweicloud_compute_instance.server.network[0].fixed_ip_v4
}

output "region" {
  description = "部署区域。"
  value       = var.region
}
