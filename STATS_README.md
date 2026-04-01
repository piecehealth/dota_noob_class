# Dota 2 学员对局统计系统

## 系统概述

本系统通过 Stratz GraphQL API 自动抓取学员的 Dota 2 对局数据和段位信息，生成每日统计报表和排行榜。

## 功能特性

### 1. 数据抓取
- 每天两次自动抓取（上午8点、晚上8点）
- 支持手动触发同步
- 使用 Stratz API (GraphQL)

### 2. 段位追踪
- 自动记录学员当前段位和历史最高段位
- 段位快照功能，追踪段位变化趋势
- 段位分布统计

### 3. 每日统计
- 每人每日对局数、胜负、KDA
- 班级/小组统计汇总
- 段位变化追踪

### 4. 排行榜
- 每日活跃玩家排行
- 胜率排行
- KDA 排行
- 段位提升明星学员

## 配置

### 环境变量

```bash
# 在 .env 或环境变量中设置
STRATZ_API_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 定时任务

```yaml
# config/recurring.yml
production:
  sync_matches_morning:
    class: BatchSyncAllPlayersJob
    schedule: at 8am every day
    
  sync_matches_evening:
    class: BatchSyncAllPlayersJob
    schedule: at 8pm every day
    
  calculate_daily_stats:
    class: CalculateDailyStatsJob
    schedule: at 1am every day
```

## 使用说明

### 手动同步

```bash
# 同步所有学员
rails "dota:stats:sync_all"

# 同步特定学员
USER_ID=123 rails "dota:stats:sync_user"

# 计算某日统计
DATE=2024-03-31 rails "dota:stats:calculate_daily"

# 查看排行榜
DATE=2024-03-31 rails "dota:stats:top_performers"

# 查看明星学员
DAYS=7 rails "dota:stats:stars"
```

### Web 界面

访问 `/stats` 查看统计概览，包括：
- 每日统计
- 排行榜
- 明星学员
- 段位分布
- 周报
- 班级/小组统计
- 玩家对比

## 数据模型

### User
- `current_rank`: 当前段位
- `highest_rank`: 历史最高段位
- `total_matches`: 总对局数
- `total_wins`: 总胜场
- `rank_updated_at`: 段位更新时间

### RankSnapshot
- 记录每次段位抓取的快照
- 用于计算段位提升

### DailyStat
- 每人每日的统计汇总
- 包括：对局数、胜负、KDA、段位变化

## API 限制

- Stratz API 有请求频率限制
- 批量同步时加入了 0.1s 延迟
- 如遇限流，任务会自动重试

## 故障排除

### API 返回错误
- 检查 STRATZ_API_TOKEN 是否有效
- 查看日志确认 User-Agent 设置正确

### 数据未更新
- 确认学员已设置 dota2_player_id
- 检查定时任务是否正常运行
- 手动运行同步任务测试

## 技术栈

- Rails 8.1
- Solid Queue (后台任务)
- SQLite3 (数据库)
- Stratz GraphQL API
