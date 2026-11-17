# 网络：VPC / 公有子网 / 安全组 / 弹性公网 IP
# 说明：弹性云服务器通过绑定的弹性公网 IP 直接出入公网（入站 SSH / 出站拉取代理安装包），
# 无需额外的 NAT 网关；如需对子网统一出网，可在部署后按需追加 NAT + SNAT。

resource "huaweicloud_vpc" "main" {
  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "public" {
  name       = "${var.project_name}-subnet"
  vpc_id     = huaweicloud_vpc.main.id
  cidr       = "10.0.0.0/24"
  gateway_ip = "10.0.0.1"
}

resource "huaweicloud_networking_secgroup" "ecs" {
  name = "${var.project_name}-sg-ecs"
}

resource "huaweicloud_networking_secgroup_rule" "ssh_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = "22"
  remote_ip_prefix  = var.admin_cidr
  security_group_id = huaweicloud_networking_secgroup.ecs.id
}

resource "huaweicloud_networking_secgroup_rule" "egress_all" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "0"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.ecs.id
}

resource "huaweicloud_vpc_eip" "ecs" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.project_name}-ecs-bw"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
}
