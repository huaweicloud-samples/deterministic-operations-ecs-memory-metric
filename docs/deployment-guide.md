# 部署指导书

> 本指导书描述如何使用 Terraform 在本云平台上一键创建本实践所需的资源。所有命令均在本仓库根目录下执行，进入部署目录统一使用相对路径 `cd infra`。

## 一、前置条件

| 项 | 要求 | 说明 |
|---|---|---|
| 账号 | 已开通本云平台账号并完成实名认证 | 个人 / 企业账号均可 |
| 权限 | 账号具备创建私有网络、弹性云服务器、弹性公网 IP 的权限 | 建议授予项目级管理员或等效权限 |
| 区域 | `cn-north-4`（推荐） | 可与 `agent_install_region` 保持一致 |
| Terraform | `>= 1.5.0` | IaC 部署工具 |
| Provider | `huaweicloud ~> 1.70` | 本云平台 Terraform Provider |
| 凭据 | 已创建访问密钥，运行时经环境变量提供 | 请勿写入仓库文件 |

凭据提供方式：

```bash
export HW_ACCESS_KEY="<AK>"
export HW_SECRET_KEY="<SK>"
```

## 二、部署步骤

```bash
# 1. 进入部署目录（相对路径）
cd infra

# 2. 初始化
terraform init

# 3. 预演资源变更
terraform plan

# 4. 执行部署
terraform apply -auto-approve
```

预期输出（节选）：

- `terraform init`：`Terraform has been successfully initialized!`
- `terraform plan`：`Plan: 7 to add, 0 to change, 0 to destroy.`
- `terraform apply`：`Apply complete! Resources: 7 added, 0 changed, 0 destroyed.`

部署完成后查看关键输出：

```bash
terraform output
```

重点记录 `ecs_public_ip`（弹性公网 IP，SSH 入站地址）与 `ecs_id`。

## 三、部署后验证

本实践验证目标：操作系统级内存指标已由云监控（Cloud Eye）代理采集并上报，可在云监控控制台查看内存使用率曲线。

### 步骤 1：登录弹性云服务器

```bash
ssh root@<ecs_public_ip>
```

### 步骤 2：确认内存采集代理已运行

```bash
systemctl status telescope
free -m
```

预期：`telescope` 服务处于 `active (running)`；`free -m` 输出系统内存总量与已用内存。

### 步骤 3：制造内存负载，观察指标变化

```bash
stress --vm 1 --vm-bytes 640M --timeout 300s
```

保持该负载，登录云监控控制台，进入对应弹性云服务器的「操作系统监控」页，查看内存使用率曲线，应可见使用率明显抬升。

### 步骤 4：控制台核对

在云监控控制台的「操作系统监控」中确认存在「内存使用率」指标，且数据时间戳为近期（说明代理上报链路正常）。

> 请按上述步骤自行验证，确认内存指标可正常采集与查看后，方可视为交付完成。

## 四、清理资源

```bash
# 进入部署目录
cd infra

# 一键释放所有资源
terraform destroy -auto-approve
```

预期输出：`Destroy complete! Resources: 7 destroyed.`

> 避免资源残留：`terraform destroy` 仅释放由本仓库状态追踪的资源；若曾在控制台手动创建额外资源，请手动释放。

## 五、注意事项

- **代理安装区域**：`agent_install_region` 需与代理安装包所在 OBS 区域一致，默认 `cn-north-4`。若部署到其他区域，请同步修改该变量以及 `region`。
- **登录方式**：默认提供口令登录，建议生产环境改用 SSH 密钥对（填写 `ssh_public_key`）。
- **安全组入站**：`admin_cidr` 默认放开到 `0.0.0.0/0`，调试期可临时放开，交付前请收紧到运维者实际 IP。
- **弹性公网 IP 出方向**：弹性云服务器通过绑定的弹性公网 IP 直接出公网，用于拉取代理安装包与软件源；如要求统一出网，可在部署后追加 NAT 网关与 SNAT。
