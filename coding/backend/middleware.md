---
title: 后端中间件设计规范
domain: coding/backend
keywords: [中间件, middleware, 认证, JWT, API Key, 限流, rate limit, 输入验证, XSS, SQL注入, CORS, CSRF, GZip, 缓存, ETag, Metrics, 链路追踪, 多租户, Feature Flag, FastAPI, ASGI, 滑动窗口]
triggers: [设计中间件, 写认证逻辑, 实现限流, 输入验证, 防止API滥用, 保护接口安全, 写ASGI中间件, 跨域问题, 响应压缩, 接口监控, 多租户隔离, 灰度发布]
scope: 基于 FastAPI/ASGI 的后端服务中间件设计与选型
---

# 后端中间件设计规范

## AI 工作流程

在创建任何中间件代码之前，必须先执行以下步骤：

1. 分析项目上下文（技术栈、业务类型、已有中间件）
2. 根据分析结果，列出推荐使用的中间件清单，并说明每个的理由
3. 询问用户确认：哪些需要、哪些不需要、是否有遗漏
4. 用户确认后，再开始实现

推荐清单的格式：

```
根据你的项目（[项目类型]），我推荐以下中间件：

✅ 必要
- [中间件名]：[一句话说明为什么这个项目需要它]

⚠️ 可选
- [中间件名]：[适用条件]

❌ 不推荐
- [中间件名]：[为什么这个项目用不上]

请确认哪些需要实现，或补充我遗漏的需求。
```

## 核心原则

1. 中间件只做横切关注点，不写业务逻辑 —— 认证、限流、验证是中间件，订单处理不是
2. 执行顺序决定安全性 —— 安全层 → 请求处理层 → 认证层 → 限流层，顺序不可颠倒
3. 失败策略必须明确 —— 认证失败 401，限流失败 429，验证失败 400，不能混用
4. Fail-open 只用于基础设施故障 —— Redis 挂了可以放行限流，认证服务挂了不能放行认证
5. 每个中间件必须有豁免路径机制 —— `/health`、`/docs` 等端点不应被拦截

## 规范细则

### 中间件分层顺序（从外到内）

```
请求进入
  ↓ 1. 安全层        CORS、Security Headers、CSRF、XSS Protection
  ↓ 2. 请求处理层    Request ID、请求日志、输入验证、Body 大小限制
  ↓ 3. 认证授权层    JWT、API Key、权限检查
  ↓ 4. 限流层        滑动窗口限流、并发限制
  ↓ 5. 缓存层        响应缓存、ETag、Cache-Control
  ↓ 6. 监控可观测层  Metrics、链路追踪、性能监控、错误追踪
  ↓ 7. 压缩优化层    GZip、Brotli
  ↓ 8. 业务逻辑层    多租户隔离、Feature Flag、国际化
  ↓ 路由处理
```

FastAPI 的 `add_middleware` 是后注册先执行，注册顺序与上面相反：

```python
app.add_middleware(TenantMiddleware)         # 最后执行（最内层）
app.add_middleware(GZipMiddleware)
app.add_middleware(MetricsMiddleware)
app.add_middleware(ResponseCacheMiddleware)
app.add_middleware(RateLimitMiddleware)
app.add_middleware(AuthMiddleware)
app.add_middleware(RequestIDMiddleware)
app.add_middleware(SecurityHeadersMiddleware) # 最先执行（最外层）
```

### 完整中间件目录

#### 第 1 层：安全层

| 中间件 | 作用 | 适用场景 |
|--------|------|---------|
| CORS | 跨域资源共享控制 | 前后端分离项目必选 |
| Security Headers | 添加 CSP、HSTS、X-Frame-Options 等安全响应头 | 所有 Web 服务 |
| CSRF Protection | 防止跨站请求伪造，cookie + header 双重验证 | 有浏览器表单提交的服务 |
| XSS Protection | 响应内容过滤，防止反射型 XSS | 返回 HTML 内容的服务 |

#### 第 2 层：请求处理层

| 中间件 | 作用 | 适用场景 |
|--------|------|---------|
| Request ID | 为每个请求生成唯一 ID，写入响应头，用于日志关联 | 所有服务必选 |
| Request Logging | 记录请求方法、路径、耗时、状态码 | 所有服务必选 |
| Input Validation | SQL 注入、XSS、路径遍历防护 | 所有接受用户输入的服务 |
| Body Size Limit | 限制请求体大小，防止内存溢出攻击 | 所有服务必选，上传服务需调大阈值 |

#### 第 3 层：认证授权层

| 中间件 | 作用 | 适用场景 |
|--------|------|---------|
| JWT Auth | Bearer Token 验证，解析用户信息到 `request.state` | 有用户体系的服务 |
| API Key | Header 或 Query 参数传递 API Key | 对外开放的 API 服务 |
| Permission | 基于角色/权限的访问控制（RBAC） | 有多角色权限区分的服务 |

#### 第 4 层：限流层

| 中间件 | 作用 | 适用场景 |
|--------|------|---------|
| Rate Limit | 滑动窗口限流，按用户类型分级 | 所有对外服务必选 |
| Concurrent Limit | 限制同一客户端的并发请求数 | 有耗时操作的服务（爬虫、文件处理） |

#### 第 5 层：缓存层

| 中间件 | 作用 | 适用场景 |
|--------|------|---------|
| Response Cache | 缓存 GET 响应，减少重复计算 | 读多写少的查询接口 |
| ETag | 基于内容哈希的条件请求，节省带宽 | 静态资源或低频变更的数据接口 |
| Cache Control | 统一设置响应的缓存策略头 | 需要精细控制客户端缓存的服务 |

#### 第 6 层：监控可观测层

| 中间件 | 作用 | 适用场景 |
|--------|------|---------|
| Metrics | 收集请求数、延迟、错误率，暴露 `/metrics` 端点 | 生产环境必选 |
| Tracing | 分布式链路追踪，注入 trace_id | 微服务架构必选 |
| Performance Monitor | 记录慢请求，超阈值告警 | 有性能 SLA 要求的服务 |
| Error Tracking | 捕获未处理异常，上报到 Sentry 等平台 | 生产环境必选 |

#### 第 7 层：压缩优化层

| 中间件 | 作用 | 适用场景 |
|--------|------|---------|
| GZip | 压缩响应体，减少传输体积 | 响应体较大的 API（列表、报表） |
| Brotli | 比 GZip 压缩率更高，现代浏览器支持 | 面向浏览器的服务，GZip 的替代选项 |

#### 第 8 层：业务逻辑层

| 中间件 | 作用 | 适用场景 |
|--------|------|---------|
| Tenant Isolation | 多租户数据隔离，从 token 解析租户 ID | SaaS 多租户平台 |
| Feature Flag | 按用户/租户/比例开关功能 | 需要灰度发布的服务 |
| A/B Testing | 流量分组，支持实验对比 | 有产品实验需求的服务 |
| Localization | 根据 `Accept-Language` 切换语言 | 多语言服务 |

### 认证中间件

- 使用 `HTTPBearer` + JWT，token 放 `Authorization: Bearer <token>` header
- 提供两个版本：强制认证 `get_current_user` 和可选认证 `get_current_user_optional`
- token 验证失败统一返回 401，响应必须包含 `WWW-Authenticate: Bearer` header
- 认证事件（成功/失败）必须记录结构化日志，失败事件同时写入持久化错误日志
- 不在中间件层做权限判断，权限判断在路由层用 `Depends` 实现

### 限流中间件

- 使用滑动窗口算法，基于 Redis 实现
- 按用户类型分级限流：

| 用户类型 | 每分钟 | 每小时 | 每天 |
|---------|--------|--------|------|
| 匿名    | 30     | 500    | 5000 |
| 认证用户 | 60    | 2000   | 20000 |
| 管理员  | 120    | 5000   | 50000 |

- 客户端标识优先级：已认证用户 ID > API Key > 客户端 IP
- IP 获取需处理反向代理：优先读 `X-Forwarded-For` 的第一个值
- Redis 不可用时 Fail-open（放行请求），但必须记录告警日志
- 限流响应必须包含 headers：`Retry-After`、`X-RateLimit-Limit`、`X-RateLimit-Remaining`、`X-RateLimit-Reset`

### 输入验证中间件

- Query 参数：检查 SQL 注入模式、XSS 模式（`<script`、`javascript:`）
- Path 参数：禁止 `..`、`/`、`\`（路径遍历防护）
- Body 验证交给 Pydantic model，中间件不重复处理
- 验证失败返回 400，响应体统一格式：

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": "具体原因"
  }
}
```

### 豁免路径

所有中间件必须支持豁免路径配置，默认豁免：

```python
EXEMPT_PATHS = ["/health", "/metrics", "/docs", "/redoc", "/openapi.json"]
```

## 反例（Anti-patterns）

**❌ 在中间件里写业务逻辑**
```python
# 错误：中间件不应该查数据库做业务判断
async def __call__(self, scope, receive, send):
    user = await db.query(User).filter(...).first()
    if user.subscription_expired:
        return 403
```

**❌ 认证和限流顺序颠倒**
```python
# 错误：限流在认证之前，无法按用户分级限流
app.add_middleware(AuthMiddleware)       # 后执行
app.add_middleware(RateLimitMiddleware)  # 先执行 ← 此时拿不到用户信息，只能按 IP 限流
```

**❌ 基础设施故障时不 Fail-open**
```python
# 错误：Redis 故障导致所有请求失败
except Exception as e:
    raise HTTPException(500, "Rate limit service unavailable")

# 正确：Fail-open + 告警
except Exception as e:
    logger.error("rate_limit_check_failed", error=str(e))
    return True, None  # 放行
```

**❌ 限流响应不带 Retry-After**
```python
# 错误：客户端不知道何时重试
return JSONResponse(status_code=429, content={"error": "Too many requests"})

# 正确
return JSONResponse(
    status_code=429,
    content={"error": {"code": "RATE_LIMIT_EXCEEDED", "retry_after": retry_after}},
    headers={"Retry-After": str(retry_after), "X-RateLimit-Remaining": "0"}
)
```

**❌ 认证失败暴露过多信息**
```python
# 错误：暴露内部细节给攻击者
raise HTTPException(401, detail=f"User {username} not found in database")

# 正确：统一模糊化
raise HTTPException(401, detail="无效或过期的认证令牌")
```

## 适用场景

**适合（匹配度 85%+）**
- 内部管理后台、运营系统
- 数据采集 / 爬虫平台
- 简单 SaaS API 服务
- 移动应用后端

**不适合（需要额外设计）**
- 实时通信（WebSocket）—— 需要专门的连接管理中间件
- IoT 平台 —— 需要 MQTT/CoAP 协议支持
- 金融交易系统 —— 需要审计日志、分布式事务中间件
