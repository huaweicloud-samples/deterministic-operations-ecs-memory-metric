#!/bin/bash
# ============================================================================
# 弹性云服务器首次启动脚本（user-data）
# 作用：安装云监控（Cloud Eye）代理，采集操作系统级内存指标并上报；
#       同时安装内存压测工具，用于演示内存指标随负载变化。
# 本脚本为华为云实践内容，仅使用本平台服务术语。
# ============================================================================
set -e
export DEBIAN_FRONTEND=noninteractive

AGENT_REGION=${agent_region}

# 基础工具与内存压测工具（用于演示内存指标变化）
apt-get update -y
apt-get install -y wget curl stress

# 安装云监控（Cloud Eye）代理：采集操作系统级内存等指标并上报
WORK_DIR=/tmp/telescope_agent
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
wget -q "https://obs.$AGENT_REGION.myhuaweicloud.com/agent/telescope_linux_amd64.tar.gz" -O telescope.tar.gz
tar -xzf telescope.tar.gz
cd telescope_linux_amd64
chmod +x install.sh
./install.sh

# 确保代理运行（安装脚本通常已启动，这里补一道保险）
systemctl enable telescope 2>/dev/null || true
systemctl start telescope 2>/dev/null || true

# 等待代理完成首次采集与上报
sleep 60
echo "Cloud Eye agent installed and started; memory metric will appear under 云监控 - 操作系统监控."
