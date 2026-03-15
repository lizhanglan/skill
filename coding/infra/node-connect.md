---
title: OpenClaw节点连接与配对诊断
domain: coding/infra
keywords: [node-connect, 节点连接, 配对故障, QR码, 设置代码, Android, iOS, macOS, 伴侣应用, 本地Wi-Fi, VPS, tailnet, 网关绑定, 引导令牌, 未授权, 配对要求]
triggers: [QR码失败, 设置代码无效, 手动连接失败, 本地Wi-Fi正常但VPS失败, 节点未连接, 配对失败, 引导令牌无效, 引导令牌过期, gateway.bind, gateway.remote.url, Tailscale, plugins.entries.device-pair.config.publicUrl]
scope: 诊断Android、iOS和macOS伴侣应用的OpenClaw节点连接和配对故障
---

# OpenClaw节点连接与配对诊断

## 核心原则

1. **分层诊断** - 从最简单的问题开始检查，逐步深入复杂问题
2. **网络优先** - 大多数连接问题源于网络配置（防火墙、NAT、DNS）
3. **令牌安全** - 引导令牌有时间限制，过期需要重新生成
4. **配置验证** - 检查所有相关配置项，确保一致性和正确性
5. **日志分析** - 使用日志定位具体失败点和错误原因

## 规范细则

### 诊断工作流

**步骤 1：基础状态检查**
```bash
# 检查OpenClaw网关状态
openclaw gateway status

# 检查节点状态
openclaw nodes status

# 检查待处理配对请求
openclaw nodes pending

# 查看详细节点信息
openclaw nodes describe --node <node-id>
```

**步骤 2：网络连通性测试**
```bash
# 测试本地网络
ping -c 4 8.8.8.8
ping -c 4 google.com

# 测试网关可达性
openclaw gateway status --verbose

# 检查端口开放（网关默认端口）
nc -zv <gateway-host> <gateway-port>  # 通常 443 或 8443

# 检查Tailscale状态（如果使用）
tailscale status
tailscale ping <gateway-host>
```

**步骤 3：配置验证**
```bash
# 检查网关配置
openclaw config get --path gateway

# 检查设备配对插件配置
openclaw config get --path plugins.entries.device-pair

# 检查远程URL配置
openclaw config get --path gateway.remote.url
openclaw config get --path gateway.bind

# 导出完整配置审查
openclaw config get --full > /tmp/openclaw-config-$(date +%Y%m%d).yaml
```

**步骤 4：日志分析**
```bash
# 查看实时日志
openclaw logs --follow

# 查看特定时间段的日志
openclaw logs --since "10 minutes ago"

# 搜索配对相关日志
openclaw logs | grep -i "pair\|qr\|bootstrap\|token"

# 查看错误日志
openclaw logs | grep -i "error\|fail\|unauthorized\|invalid"
```

### 常见问题与解决方案

#### 问题 1：QR码/设置代码无效或过期

**症状**：
- 移动应用扫描QR码后显示"无效代码"
- 手动输入设置代码失败
- 错误消息提到"令牌过期"或"无效令牌"

**诊断**：
```bash
# 检查引导令牌状态
openclaw nodes pending

# 生成新的配对代码
openclaw nodes pairing --new

# 检查令牌过期时间（通常5-10分钟）
# 如果过期，需要重新生成
```

**解决方案**：
1. 生成新的配对代码：
   ```bash
   # 生成新的QR码和设置代码
   openclaw nodes pairing --new --format qr
   openclaw nodes pairing --new --format code
   ```

2. 在移动应用中使用新代码：
   - 确保在令牌有效期内（通常5分钟）使用
   - 确保网络连接正常
   - 如果使用QR码，确保清晰扫描

3. 延长令牌有效期（如果需要）：
   ```yaml
   # 在配置中调整
   plugins:
     entries:
       device-pair:
         config:
           bootstrapTokenTTL: "10m"  # 默认5分钟，延长到10分钟
   ```

#### 问题 2：本地Wi-Fi工作但VPS/tailnet失败

**症状**：
- 设备在本地网络中可以连接
- 通过VPS或Tailscale连接失败
- 错误消息提到"连接超时"或"无法到达主机"

**诊断**：
```bash
# 测试VPS可达性
ping -c 4 <vps-ip>
nc -zv <vps-ip> <port>

# 检查防火墙规则
sudo ufw status verbose
# 或
sudo firewall-cmd --list-all

# 检查网关绑定配置
openclaw config get --path gateway.bind
openclaw config get --path gateway.remote.url
```

**解决方案**：
1. 确保网关绑定到正确接口：
   ```yaml
   gateway:
     bind:
       # 绑定到所有接口（0.0.0.0）或特定IP
       address: "0.0.0.0"
       port: 8443
   ```

2. 配置正确的远程URL：
   ```yaml
   gateway:
     remote:
       # 使用VPS的公网IP或域名
       url: "https://your-vps-ip:8443"
       # 或使用Tailscale MagicDNS
       url: "https://your-hostname.tailscale.net:8443"
   ```

3. 配置防火墙允许流量：
   ```bash
   # 允许网关端口
   sudo ufw allow 8443/tcp
   # 或
   sudo firewall-cmd --permanent --add-port=8443/tcp
   sudo firewall-cmd --reload
   ```

#### 问题 3：错误提到"配对要求"、"未授权"、"引导令牌无效或过期"

**症状**：
- 错误消息："pairing required"（需要配对）
- 错误消息："unauthorized"（未授权）
- 错误消息："bootstrap token invalid or expired"（引导令牌无效或过期）

**诊断**：
```bash
# 检查配对插件是否启用
openclaw config get --path plugins.entries.device-pair.enabled

# 检查公共URL配置
openclaw config get --path plugins.entries.device-pair.config.publicUrl

# 查看详细的配对日志
openclaw logs | grep -A5 -B5 "pairing\|bootstrap\|unauthorized"
```

**解决方案**：
1. 确保配对插件已启用：
   ```yaml
   plugins:
     entries:
       device-pair:
         enabled: true
         config:
           # 公共URL必须与网关remote.url匹配
           publicUrl: "https://your-public-domain:8443"
   ```

2. 重新生成配对令牌：
   ```bash
   # 清除所有待处理配对
   openclaw nodes pending --clear
   
   # 生成新的配对代码
   openclaw nodes pairing --new
   ```

3. 检查时间同步：
   ```bash
   # 时间不同步会导致令牌验证失败
   date
   sudo timedatectl status
   
   # 同步时间（如果需要）
   sudo timedatectl set-ntp true
   ```

#### 问题 4：Android/iOS/macOS伴侣应用连接失败

**症状**：
- 移动应用显示"连接失败"
- 应用无法发现网关
- 特定平台的问题（仅Android或仅iOS失败）

**诊断**：
```bash
# 检查平台特定日志
openclaw logs | grep -i "android\|ios\|macos"

# 测试HTTPS证书（移动设备对证书要求严格）
openssl s_client -connect <gateway-host>:<gateway-port> -servername <gateway-host>

# 检查CORS头（如果使用WebSocket）
curl -I https://<gateway-host>:<gateway-port>
```

**解决方案**：
1. 确保使用有效的HTTPS证书：
   ```yaml
   gateway:
     tls:
       # 使用有效的证书（Let's Encrypt或商业证书）
       cert: "/path/to/fullchain.pem"
       key: "/path/to/privkey.pem"
       
       # 或使用自动证书（如Tailscale）
       auto: true
   ```

2. 配置正确的CORS头：
   ```yaml
   gateway:
     cors:
       origins:
         - "https://your-public-domain"
         - "capacitor://localhost"  # Capacitor应用（iOS/Android）
         - "http://localhost:*"     # 开发环境
   ```

3. 平台特定配置：
   - **Android**：确保应用有网络权限，不在电池优化列表中
   - **iOS**：确保有有效的ATS配置，使用有效的证书
   - **macOS**：检查防火墙和网络扩展设置

### 配置示例

**完整的网关和配对配置**：
```yaml
# ~/.openclaw/config.yaml
gateway:
  # 绑定配置
  bind:
    address: "0.0.0.0"  # 监听所有接口
    port: 8443
  
  # 远程访问URL（必须可从互联网访问）
  remote:
    url: "https://your-public-domain.com:8443"
  
  # TLS配置
  tls:
    # 选项1：自动证书（推荐用于Tailscale）
    auto: true
    
    # 选项2：手动证书
    # cert: "/etc/ssl/certs/your-cert.pem"
    # key: "/etc/ssl/private/your-key.pem"
  
  # CORS配置
  cors:
    origins:
      - "https://your-public-domain.com"
      - "capacitor://localhost"
      - "http://localhost:*"

# 插件配置
plugins:
  entries:
    device-pair:
      enabled: true
      config:
        # 必须与gateway.remote.url匹配
        publicUrl: "https://your-public-domain.com:8443"
        # 引导令牌有效期
        bootstrapTokenTTL: "5m"
        # 最大配对设备数
        maxPairedDevices: 10

# Tailscale集成（如果使用）
tailscale:
  enabled: true
  # Tailscale主机名（用于MagicDNS）
  hostname: "your-openclaw-gateway"
```

**防火墙配置示例**：
```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 8443/tcp comment "OpenClaw Gateway"
sudo ufw allow 41641/udp comment "Tailscale"
sudo ufw allow out 53 comment "DNS"
sudo ufw allow out 443 comment "HTTPS"
sudo ufw enable

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --permanent --add-port=41641/udp
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### 故障排除脚本

**创建诊断脚本**：
```bash
cat > ~/diagnose-node-connect.sh << 'EOF'
#!/bin/bash
# OpenClaw节点连接诊断脚本

echo "=== OpenClaw节点连接诊断 $(date) ==="
echo ""

# 1. 基础状态
echo "1. 基础状态检查:"
openclaw gateway status
echo ""

# 2. 节点状态
echo "2. 节点状态:"
openclaw nodes status
echo ""

# 3. 待处理配对
echo "3. 待处理配对请求:"
openclaw nodes pending
echo ""

# 4. 网络测试
echo "4. 网络连通性测试:"
ping -c 2 8.8.8.8 > /dev/null && echo "   ✅ 互联网连接正常" || echo "   ❌ 互联网连接失败"
ping -c 2 google.com > /dev/null && echo "   ✅ DNS解析正常" || echo "   ❌ DNS解析失败"

# 5. 配置检查
echo "5. 关键配置检查:"
openclaw config get --path gateway.remote.url
openclaw config get --path gateway.bind
openclaw config get --path plugins.entries.device-pair.config.publicUrl
echo ""

# 6. 日志检查（最近错误）
echo "6. 最近错误日志:"
openclaw logs --since "5 minutes ago" | grep -i "error\|fail\|warn" | tail -10
echo ""

echo "=== 诊断完成 ==="
echo "建议操作:"
echo "1. 如果配对令牌过期: openclaw nodes pairing --new"
echo "2. 如果配置不匹配: 检查 gateway.remote.url 和 device-pair.config.publicUrl"
echo "3. 如果网络问题: 检查防火墙和网络连接"
EOF

chmod +x ~/diagnose-node-connect.sh
```

**一键修复脚本**（谨慎使用）：
```bash
cat > ~/fix-node-connect.sh << 'EOF'
#!/bin/bash
# 一键修复常见节点连接问题

echo "开始修复节点连接问题..."

# 1. 生成新的配对令牌
echo "1. 生成新的配对令牌..."
openclaw nodes pairing --new --format both

# 2. 检查并修复配置一致性
echo "2. 检查配置一致性..."
GATEWAY_URL=$(openclaw config get --path gateway.remote.url --raw)
PUBLIC_URL=$(openclaw config get --path plugins.entries.device-pair.config.publicUrl --raw)

if [ "$GATEWAY_URL" != "$PUBLIC_URL" ]; then
    echo "   ⚠️  配置不匹配，正在修复..."
    openclaw config patch --json '{
        "plugins": {
            "entries": {
                "device-pair": {
                    "config": {
                        "publicUrl": "'"$GATEWAY_URL"'"
                    }
                }
            }
        }
    }'
    echo "   ✅ 已更新 publicUrl: $GATEWAY_URL"
else
    echo "   ✅ 配置一致"
fi

# 3. 重启网关服务
echo "3. 重启网关服务..."
openclaw gateway restart --delay-ms 2000

echo "修复完成！请使用新生成的配对代码连接设备。"
EOF

chmod +x ~/fix-node-connect.sh
```

## 反例（Anti-patterns）

**❌ 配置不一致**：
```yaml
# 错误：URL不匹配
gateway:
  remote:
    url: "https://example.com:8443"

plugins:
  entries:
    device-pair:
      config:
        publicUrl: "https://different-domain.com:8443"  # ❌ 不匹配
```

**❌ 使用HTTP而非HTTPS**：
```yaml
# 错误：移动设备要求HTTPS
gateway:
  remote:
    url: "http://example.com:8443"  # ❌ 应使用HTTPS
    
  tls:
    enabled: false  # ❌ 应启用TLS
```

**❌ 绑定到localhost**：
```yaml
# 错误：无法从外部访问
gateway:
  bind:
    address: "127.0.0.1"  # ❌ 只绑定到本地回环
    port: 8443
```

**❌ 防火墙阻止必要端口**：
```bash
# 错误：防火墙阻止网关端口
sudo ufw deny 8443  # ❌ 应允许
# 或未配置防火墙规则
```

**❌ 使用过期的配对令牌**：
```bash
# 错误：使用5分钟前生成的QR码
# 令牌已过期，需要重新生成
```

**❌ 忽略时间同步**：
```bash
# 错误：系统时间不同步
# 导致令牌验证失败，但错误信息不明显
```

## 适用场景

**适合使用此技能**：
- QR码/设置代码/手动连接失败
- 本地Wi-Fi工作但VPS/tailnet连接失败
- 错误提到"配对要求"、"未授权"、"引导令牌无效或过期"
- 错误提到gateway.bind、gateway.remote.url、Tailscale或plugins.entries.device-pair.config.publicUrl
- Android/iOS/macOS伴侣应用连接问题

**不适合使用此技能**：
- 应用功能问题（非连接相关）
- 性能问题（连接慢但能连接）
- 其他OpenClaw功能问题（非节点连接相关）
- 需要深度网络调试的复杂网络问题

## 快速参考

**常用命令**：
```bash
# 状态检查
openclaw gateway status
openclaw nodes status
openclaw nodes pending

# 生成配对代码
openclaw nodes pairing --new --format qr      # QR码
openclaw nodes pairing --new --format code    # 设置代码
openclaw nodes pairing --new --format both    # 两者

# 配置检查
openclaw config get --path gateway
openclaw config get --path plugins.entries.device-pair

# 日志查看
openclaw logs --since "5 minutes ago"
openclaw logs | grep -i "pair\|error"
```

**检查清单**：
- [ ] 网关服务正在运行
- [ ] 网关绑定到正确接口（0.0.0.0或公网IP）
- [ ] 远程URL可从互联网访问
- [ ] 防火墙允许网关端口（通常8443）
- [ ] TLS证书有效（如使用HTTPS）
- [ ] gateway.remote.url与device-pair.config.publicUrl一致
- [ ] 使用未过期的配对令牌（5分钟内）
- [ ] 系统时间同步
- [ ] 移动设备网络连接正常
