---
title: 天气查询与预报
domain: coding/tools
keywords: [weather, 天气, 天气预报, 温度, 湿度, 降水, 风速, wttr.in, Open-Meteo, 天气API, 实时天气, 天气预警]
triggers: [天气查询, 天气预报, 温度, 湿度, 风速, 降水概率, 实时天气, 天气状况, 气象数据, 天气预警]
scope: 通过wttr.in或Open-Meteo获取当前天气和天气预报，无需API密钥
---

# 天气查询与预报

## 核心原则

1. **简单易用** - 使用无需API密钥的服务（wttr.in、Open-Meteo）
2. **多格式支持** - 支持文本、JSON、HTML等多种输出格式
3. **全球覆盖** - 支持全球各地天气查询
4. **实时数据** - 提供当前天气和短期预报
5. **轻量级** - 最小依赖，快速响应

## 规范细则

### 基础操作

#### 使用wttr.in（推荐）
**基本查询**：
```bash
# 查询当前位置天气
curl wttr.in

# 查询指定城市
curl wttr.in/Beijing
curl wttr.in/上海
curl wttr.in/"New York"

# 使用城市代码（避免歧义）
curl wttr.in/~Beijing
curl wttr.in/北京市
```

**输出格式控制**：
```bash
# 简洁输出（一行）
curl wttr.in/Beijing?format=3

# 简洁输出带名称
curl wttr.in/Beijing?format=4

# 只显示当前天气
curl wttr.in/Beijing?0

# 显示今天和明天
curl wttr.in/Beijing?1

# 显示三天预报
curl wttr.in/Beijing?2
```

**语言和单位**：
```bash
# 中文输出
curl zh.wttr.in/Beijing

# 英文输出
curl en.wttr.in/Beijing

# 公制单位（默认）
curl wttr.in/Beijing?m

# 英制单位
curl wttr.in/Beijing?u

# 同时指定
curl zh.wttr.in/Beijing?m
```

#### 使用Open-Meteo
**基本查询**：
```bash
# 通过curl查询
curl "https://api.open-meteo.com/v1/forecast?latitude=39.9042&longitude=116.4074&current_weather=true"

# 北京天气（JSON格式）
curl "https://api.open-meteo.com/v1/forecast?latitude=39.9042&longitude=116.4074&current_weather=true&timezone=Asia/Shanghai"
```

**参数说明**：
- `latitude`、`longitude`：经纬度（必需）
- `current_weather`：是否获取当前天气
- `timezone`：时区
- `hourly`、`daily`：小时/天预报参数
- `temperature_unit`：温度单位（celsius或fahrenheit）
- `windspeed_unit`：风速单位（kmh、ms、mph、kn）
- `precipitation_unit`：降水单位（mm、inch）

### 高级查询

#### 获取详细预报
```bash
# wttr.in详细预报
curl wttr.in/Beijing?FQ

# 或使用v2格式
curl v2.wttr.in/Beijing

# JSON格式（便于程序处理）
curl wttr.in/Beijing?format=j1
```

#### 多日预报
```bash
# 3天预报
curl wttr.in/Beijing?3

# 7天预报（可能需要v2）
curl v2.wttr.in/Beijing?7

# 指定日期
curl wttr.in/Beijing@2025-03-20
```

#### 特定天气要素
```bash
# 只显示温度
curl wttr.in/Beijing?format="%l:+%c+%t\n"

# 温度+天气状况
curl wttr.in/Beijing?format="%l:+%c+%t,+%w\n"

# 详细格式
curl wttr.in/Beijing?format="%l:\n%c+%t\n🌡️+%h\n💨+%w\n🌧️+%p\n"
```

**格式代码**：
- `%l`：位置
- `%c`：天气状况图标
- `%t`：温度
- `%w`：风速
- `%h`：湿度
- `%p`：降水概率
- `%P`：降水量
- `%C`：天气状况文字
- `%u`：紫外线指数

#### 批量查询
```bash
# 多个城市
for city in Beijing Shanghai Guangzhou Shenzhen; do
    echo "=== $city ==="
    curl -s "wttr.in/$city?format=3"
    echo
done

# 从文件读取城市列表
while IFS= read -r city; do
    weather=$(curl -s "wttr.in/$city?format=3")
    echo "$city: $weather"
done < cities.txt
```

### 实用脚本

#### 天气通知脚本
```bash
#!/bin/bash
# 每日天气通知

CITY="${1:-Beijing}"
NOTIFICATION_TITLE="今日天气"
SAVE_DIR="$HOME/.weather"
LOG_FILE="$SAVE_DIR/weather.log"

mkdir -p "$SAVE_DIR"

# 获取天气信息
WEATHER_JSON=$(curl -s "wttr.in/$CITY?format=j1")
CURRENT_CONDITION=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0]')

# 提取数据
TEMP=$(echo "$CURRENT_CONDITION" | jq -r '.temp_C')
FEELS_LIKE=$(echo "$CURRENT_CONDITION" | jq -r '.FeelsLikeC')
HUMIDITY=$(echo "$CURRENT_CONDITION" | jq -r '.humidity')
WIND_SPEED=$(echo "$CURRENT_CONDITION" | jq -r '.windspeedKmph')
WEATHER_DESC=$(echo "$CURRENT_CONDITION" | jq -r '.weatherDesc[0].value')
PRECIPITATION=$(echo "$CURRENT_CONDITION" | jq -r '.precipMM')

# 构建消息
MESSAGE="🌤️ $CITY 天气
温度: ${TEMP}°C (体感 ${FEELS_LIKE}°C)
天气: ${WEATHER_DESC}
湿度: ${HUMIDITY}%
风速: ${WIND_SPEED} km/h
降水: ${PRECIPITATION} mm"

# 输出到日志
echo "$(date): $MESSAGE" >> "$LOG_FILE"

# 发送通知（根据平台）
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    osascript -e "display notification \"$MESSAGE\" with title \"$NOTIFICATION_TITLE\""
elif command -v notify-send &> /dev/null; then
    # Linux (notify-send)
    notify-send "$NOTIFICATION_TITLE" "$MESSAGE"
elif command -v termux-notification &> /dev/null; then
    # Termux (Android)
    termux-notification -t "$NOTIFICATION_TITLE" -c "$MESSAGE"
fi

echo "$MESSAGE"
```

#### 旅行天气检查
```bash
#!/bin/bash
# 旅行目的地天气检查

DESTINATIONS=(
    "Beijing"
    "Shanghai"
    "Tokyo"
    "London"
    "New York"
)

echo "=== 旅行目的地天气检查 ==="
echo "检查时间: $(date)"
echo ""

for city in "${DESTINATIONS[@]}"; do
    echo "📍 $city"
    
    # 获取当前天气
    CURRENT=$(curl -s "wttr.in/$city?format=3")
    echo "当前: $CURRENT"
    
    # 获取3天预报
    FORECAST=$(curl -s "wttr.in/$city?format=\"%l:+%c+%t,+%w\"&2" | head -3)
    echo "预报:"
    echo "$FORECAST"
    
    echo ""
done

# 建议
echo "=== 旅行建议 ==="
echo "1. 查看目的地天气预报，准备合适衣物"
echo "2. 注意降水概率，准备雨具"
echo "3. 关注温度变化，注意防暑/保暖"
echo "4. 大风天气注意安全"
```

#### 天气数据记录
```bash
#!/bin/bash
# 天气数据记录器

CITY="Beijing"
DATA_DIR="$HOME/weather-data"
CSV_FILE="$DATA_DIR/weather_$(date +%Y%m).csv"

mkdir -p "$DATA_DIR"

# 如果CSV文件不存在，创建表头
if [[ ! -f "$CSV_FILE" ]]; then
    echo "timestamp,city,temperature_c,feels_like_c,humidity,wind_speed_kmh,weather_desc,precipitation_mm" > "$CSV_FILE"
fi

# 获取天气数据
WEATHER_JSON=$(curl -s "wttr.in/$CITY?format=j1")
CURRENT_CONDITION=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0]')

# 提取数据
TIMESTAMP=$(date -Iseconds)
TEMP=$(echo "$CURRENT_CONDITION" | jq -r '.temp_C')
FEELS_LIKE=$(echo "$CURRENT_CONDITION" | jq -r '.FeelsLikeC')
HUMIDITY=$(echo "$CURRENT_CONDITION" | jq -r '.humidity')
WIND_SPEED=$(echo "$CURRENT_CONDITION" | jq -r '.windspeedKmph')
WEATHER_DESC=$(echo "$CURRENT_CONDITION" | jq -r '.weatherDesc[0].value' | tr ',' ';')
PRECIPITATION=$(echo "$CURRENT_CONDITION" | jq -r '.precipMM')

# 写入CSV
echo "$TIMESTAMP,$CITY,$TEMP,$FEELS_LIKE,$HUMIDITY,$WIND_SPEED,$WEATHER_DESC,$PRECIPITATION" >> "$CSV_FILE"

echo "天气数据已记录: $TIMESTAMP"
echo "温度: ${TEMP}°C, 湿度: ${HUMIDITY}%, 天气: ${WEATHER_DESC}"

# 可选：每天只记录一次（通过cron）
# 添加到cron: 0 9 * * * /path/to/weather-logger.sh
```

### 集成到OpenClaw

#### 天气查询命令
```bash
# 在OpenClaw中查询天气
exec command:"curl -s 'wttr.in/Beijing?format=3'"

# 或使用更友好的格式
exec command:"echo '北京天气:'; curl -s 'wttr.in/Beijing?format=\"%c+%t,+%w,+%h\"'"
```

#### 天气提醒cron作业
```bash
# 创建天气提醒cron作业
openclaw cron add --json '{
  "name": "morning-weather",
  "schedule": {
    "kind": "cron",
    "expr": "0 8 * * *",
    "tz": "Asia/Shanghai"
  },
  "payload": {
    "kind": "agentTurn",
    "message": "查询北京天气并生成简洁的早晨天气提醒，包含温度、天气状况和今日建议。使用wttr.in API，输出格式简洁明了。"
  },
  "sessionTarget": "isolated",
  "delivery": {
    "mode": "announce",
    "channel": "webchat"
  }
}'
```

#### 天气技能集成
```bash
# 创建天气查询技能使用示例
cat > weather-query.sh << 'EOF'
#!/bin/bash
# OpenClaw天气查询助手

CITY="${1:-Beijing}"
FORMAT="${2:-human}"  # human, json, simple

case $FORMAT in
    human)
        curl -s "zh.wttr.in/$CITY?1"
        ;;
    json)
        curl -s "wttr.in/$CITY?format=j1"
        ;;
    simple)
        curl -s "wttr.in/$CITY?format=3"
        ;;
    *)
        echo "未知格式: $FORMAT"
        echo "可用格式: human, json, simple"
        ;;
esac
EOF

chmod +x weather-query.sh
```

## 反例（Anti-patterns）

**❌ 不处理网络错误**：
```bash
# 错误：直接使用curl不检查网络
weather=$(curl wttr.in/Beijing)
echo "$weather"
# 如果网络失败，$weather为空或包含错误
# 正确：检查curl退出状态
if weather=$(curl -s -f wttr.in/Beijing); then
    echo "$weather"
else
    echo "无法获取天气信息"
fi
```

**❌ 不验证城市名称**：
```bash
# 错误：使用未经验证的用户输入
city="$USER_INPUT"
curl "wttr.in/$city"
# 如果$city包含特殊字符或空格，可能失败
# 正确：验证和清理输入
city=$(echo "$USER_INPUT" | tr -d '[:space:]' | sed 's/[^a-zA-Z0-9-]//g')
if [[ -n "$city" ]]; then
    curl "wttr.in/$city"
fi
```

**❌ 忽略API限制**：
```bash
# 错误：频繁请求不缓存
while true; do
    curl wttr.in/Beijing
    sleep 1  # 过于频繁
done
# 可能被限速或屏蔽
# 正确：合理间隔和缓存
last_update=0
update_interval=300  # 5分钟

while true; do
    current_time=$(date +%s)
    if (( current_time - last_update >= update_interval )); then
        weather=$(curl -s wttr.in/Beijing)
        last_update=$current_time
    fi
    # 使用缓存的$weather
    sleep 60
done
```

**❌ 不处理特殊字符**：
```bash
# 错误：城市名包含空格不处理
city="New York"
curl "wttr.in/$city"  # 错误：wttr.in/New York
# 正确：处理空格
city="New York"
encoded_city=$(echo "$city" | sed 's/ /+/g')
curl "wttr.in/$encoded_city"
# 或使用引号
curl "wttr.in/New%20York"
```

**❌ 不检查服务可用性**：
```bash
# 错误：假设服务总是可用
weather_data=$(curl -s wttr.in/Beijing)
# 如果wttr.in宕机，获取失败
# 正确：检查服务状态或提供备选
if ! curl -s -I https://wttr.in > /dev/null 2>&1; then
    echo "天气服务暂时不可用"
    # 可以尝试备选服务
    # curl api.open-meteo.com/...
else
    weather_data=$(curl -s wttr.in/Beijing)
fi
```

**❌ 不处理时区差异**：
```bash
# 错误：忽略查询地点的时区
curl wttr.in/London
# 显示的是伦敦当地时间，可能与用户所在时区不同
# 正确：考虑时区或明确说明
echo "伦敦当地时间:"
curl wttr.in/London
# 或使用时区参数（如果API支持）
```

## 适用场景

**适合使用此技能**：
- 查询当前天气状况
- 获取短期天气预报（1-3天）
- 旅行前的天气检查
- 日常天气提醒和通知
- 天气数据记录和分析
- 集成到其他应用中的天气功能
- 教学或演示中的天气API使用

**不适合使用此技能**：
- 长期天气预报（超过7天）
- 专业气象分析（需要专业气象数据）
- 历史天气数据查询（需要历史数据库）
- 精确的天气预警（需要官方预警系统）
- 气象科学研究（需要原始气象数据）
- 商业天气服务（需要商业API许可）

## 最佳实践

### 输入处理
1. **城市验证**：验证城市名称有效性
2. **编码处理**：正确处理特殊字符和空格
3. **默认值**：提供合理的默认城市
4. **错误提示**：友好的城市未找到提示

### 输出处理
1. **格式选择**：根据用途选择合适的输出格式
2. **本地化**：考虑用户的语言和单位偏好
3. **简洁性**：非必要信息不显示
4. **可读性**：人类可读的格式化输出

### 性能优化
1. **缓存策略**：合理缓存天气数据
2. **请求频率**：避免过于频繁的请求
3. **超时设置**：设置合理的请求超时
4. **并行处理**：批量查询时考虑并行

### 错误处理
1. **网络检查**：检查网络连接和服务可用性
2. **备用服务**：考虑备用天气服务
3. **优雅降级**：服务不可用时提供基本功能
4. **用户反馈**：清晰的错误信息提示

## 常见用例

### 用例1：命令行天气工具
```bash
#!/bin/bash
# 命令行天气工具

VERSION="1.0.0"
DEFAULT_CITY="Beijing"

show_help() {
    cat << EOF
天气查询工具 v$VERSION

用法: $0 [选项] [城市]

选项:
  -c, --city CITY     指定城市（默认: $DEFAULT_CITY）
  -f, --format FORMAT 输出格式（simple, detailed, json）
  -d, --days DAYS     预报天数（1-3）
  -l, --lang LANG     语言（zh, en