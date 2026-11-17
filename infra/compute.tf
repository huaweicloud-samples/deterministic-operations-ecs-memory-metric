# 计算：弹性云服务器运行云监控（Cloud Eye）代理，采集操作系统级内存指标
data "huaweicloud_availability_zones" "this" {}

data "huaweicloud_images_image" "base" {
  name        = var.image_name
  most_recent = true
}

# SSH 密钥对（可选）
resource "huaweicloud_compute_keypair" "this" {
  count      = var.ssh_public_key != "" ? 1 : 0
  name       = "${var.project_name}-key"
  public_key = var.ssh_public_key
}

resource "huaweicloud_compute_instance" "server" {
  name               = "${var.project_name}-server"
  flavor_name        = var.ecs_flavor
  image_id           = data.huaweicloud_images_image.base.id
  security_group_ids = [huaweicloud_networking_secgroup.ecs.id]
  availability_zone  = data.huaweicloud_availability_zones.this.names[0]
  admin_pass         = var.admin_password
  eip_id             = huaweicloud_vpc_eip.ecs.id
  key_pair           = try(huaweicloud_compute_keypair.this[0].name, null)

  system_disk_type = "SSD"
  system_disk_size = 40

  network {
    uuid = huaweicloud_vpc_subnet.public.id
  }

  user_data = templatefile("${path.module}/../src/user-data.tpl", {
    agent_region = var.agent_install_region
  })

  # user_data / admin_pass 为运行期或部署期变更项，交由实例生命周期管理
  lifecycle {
    ignore_changes = [user_data, admin_pass]
  }
}
