variable "region" {
  description = "华为云区域。"
  type        = string
  default     = "cn-north-4"
}

variable "project_name" {
  description = "资源命名前缀（建议全局唯一，避免与其他任务资源混淆）。"
  type        = string
  default     = "ecs-memory-metric"
}

variable "admin_cidr" {
  description = "运维管理来源 CIDR（SSH 入站）。调试期建议锁到运维者 IP，交付前收紧。"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_cidr" {
  description = "VPC 网段。"
  type        = string
  default     = "10.0.0.0/16"
}

# 计算规格显式声明，便于部署前评估资源用量（不依赖动态查询结果）。
variable "ecs_flavor" {
  description = "弹性云服务器规格（通用计算型 s6）。"
  type        = string
  default     = "s6.large.2"
}

variable "admin_password" {
  description = "弹性云服务器登录口令，生产环境建议改用密钥对。"
  type        = string
  sensitive   = true
  default     = "ChangeMe_2026!Mem"
}

variable "ssh_public_key" {
  description = "SSH 公钥（留空则仅使用口令登录）。建议优先使用密钥对。"
  type        = string
  default     = ""
}

variable "image_name" {
  description = "公共镜像名称（按区域确认真实可用镜像）。"
  type        = string
  default     = "Ubuntu 22.04 server 64bit"
}

variable "agent_install_region" {
  description = "云监控代理安装包所在 OBS 区域（通常与 region 一致）。"
  type        = string
  default     = "cn-north-4"
}
