terraform {
  required_version = ">= 1.5"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.70"
    }
  }

  # 状态文件建议落地到 OBS 桶（生产环境改为 OBS 桶后端，endpoint 指向 OBS）。
  backend "local" {}
}

# 凭据（AK/SK）由部署方在运行时通过环境变量提供（HW_ACCESS_KEY / HW_SECRET_KEY），此处不填写具体值。
provider "huaweicloud" {
  region = var.region
}
