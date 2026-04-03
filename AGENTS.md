# AGENTS.md - Dota2 萌新班项目指南

## 项目概述

Dota2 萌新班数据平台 - 一个 Rails 8 应用，用于追踪和管理 Dota2 学员的对局数据、统计信息和班级管理。

**完整产品文档**: [docs/PRD/DESIGN.md](docs/PRD/DESIGN.md)

---

## 技术栈

| 组件 | 技术 |
|------|------|
| 后端 | Rails 8.1 + Ruby 3.4+ |
| 数据库 | SQLite3 |
| 缓存/队列 | Solid Cache / Solid Queue / Solid Cable |
| 前端 | Hotwire (Turbo + Stimulus) |
| CSS | Tailwind CSS 4 + DaisyUI 5.5+ |
| 认证 | Session-based (admin-only for login) |
| API | Stratz GraphQL API |

---

## 快速参考

### 模型关系
```
User (学员/教练/辅导员/管理员)
├── has_many :match_players
├── has_many :matches, through: :match_players
├── belongs_to :classroom (optional)
├── belongs_to :group (optional)
├── has_many :rank_snapshots
└── has_many :daily_stats

Match
├── has_many :match_players
├── has_many :users, through: :match_players
└── 字段: match_id, duration, game_mode, lobby_type, average_rank

MatchPlayer (关联表)
├── belongs_to :match
├── belongs_to :user
└── 字段: hero_id, kills, deaths, assists, won, award, lane_outcome

Classroom
├── has_many :groups
└── has_many :users

Group
├── belongs_to :classroom
└── has_many :users
```

### 核心服务
```ruby
# 数据同步
StratzApi.new.batch_sync_players(steam_ids, since_days: 14)
StratzApi.new.batch_player_profiles(steam_ids)

# 段位名称
Match#rank_name      # "中军 3星"
Match#game_mode_name # "全英雄选择（抢选）"
```

### 定时任务
```yaml
# config/recurring.yml
sync_morning: "0 4 * * *"      # 4am 同步
sync_evening: "0 16 * * *"     # 4pm 同步
calculate_morning: "0 5 * * *" # 5am 统计
weekly_leaderboards: "0 3 * * 1" # 周一 3am 排行榜
```

---

## DaisyUI 5 组件规范

### 布局基础

```erb
<!-- 页面容器 -->
<div class="container mx-auto p-4">

<!-- 卡片 -->
<div class="card bg-base-200">
  <div class="card-body">
    <h2 class="card-title">标题</h2>
    <!-- 内容 -->
  </div>
</div>
```

### 数据统计展示

```erb
<!-- 统计数字（大） -->
<div class="stats stats-vertical sm:stats-horizontal shadow w-full">
  <div class="stat">
    <div class="stat-title">标题</div>
    <div class="stat-value text-primary">123</div>
  </div>
</div>

<!-- 表格 -->
<div class="overflow-x-auto">
  <table class="table table-sm">
    <thead><tr><th>列</th></tr></thead>
    <tbody><tr class="hover"><td>数据</td></tr></tbody>
  </table>
</div>
```

### 按钮与链接

```erb
<!-- 主要操作 -->
<%= link_to "按钮", path, class: "btn btn-primary" %>

<!-- 次要操作 -->
<%= link_to "返回", path, class: "btn btn-ghost btn-sm" %>

<!-- 按钮组 -->
<div class="join">
  <%= link_to "选项1", path, class: "btn btn-sm join-item" %>
  <%= link_to "选项2", path, class: "btn btn-sm join-item" %>
</div>
```

### 标签与徽章

```erb
<span class="badge badge-primary">主要</span>
<span class="badge badge-success">成功</span>
<span class="badge badge-error">失败</span>
<span class="badge badge-warning">MVP</span>
<span class="badge badge-ghost">次要</span>
```

### 表单元素

```erb
<!-- 输入框 -->
<fieldset class="fieldset">
  <legend class="fieldset-legend">标签</legend>
  <input type="text" class="input input-bordered w-full" />
</fieldset>
```

### 常用颜色类

| 用途 | 类名 |
|------|------|
| 成功/胜利 | `text-success`, `badge-success`, `ring-success` |
| 失败 | `text-error`, `badge-error`, `ring-error` |
| 主要强调 | `text-primary`, `badge-primary`, `link-primary` |
| 次要强调 | `text-secondary`, `badge-secondary` |
| 弱化文字 | `opacity-50`, `opacity-70` |

### 响应式断点

- **默认**: 移动优先
- **sm**: 640px+
- **md**: 768px+
- **lg**: 1024px+
- **xl**: 1280px+

---

## 代码规范

### Rubocop
```bash
bundle exec rubocop -a    # 自动修复
```

### 测试
```bash
bin/rails test
```

### 文件修改检查清单

修改视图文件后，确认：

- [ ] 使用 DaisyUI 组件类（card、btn、badge、table 等）
- [ ] 移除自定义 CSS（如 bg-white、shadow、rounded-lg 等非 DaisyUI 类）
- [ ] 保持 dark 主题一致性（使用 bg-base-200、bg-base-100）
- [ ] 移动端可正常显示（使用响应式前缀 sm:、md:）
- [ ] 链接使用 `link link-primary` 类
- [ ] 按钮使用 `btn` 系列类

---

## 数据库 Schema 参考

```ruby
# 关键字段速查

User
- role: enum [:student, :coach, :assistant]
- is_admin: boolean
- dota2_player_id: string (Steam ID)
- current_rank / highest_rank: integer
- total_matches / total_wins: integer

Match
- match_id: bigint (Stratz ID)
- duration: integer (seconds)
- game_mode / lobby_type: integer
- average_rank: integer
- played_at: datetime
- raw_data: json

MatchPlayer
- player_slot: integer
- on_radiant: boolean
- won: boolean
- hero_id: integer
- kills / deaths / assists: integer
- award: enum [:NONE, :MVP, :TOP_CORE, :TOP_SUPPORT]
- lane_outcome: string
- party_size: integer
```

---

## 外部 API

### Stratz API
- Endpoint: https://api.stratz.com/graphql
- Batch Size: 50 players/request
- Rate Limit: 注意处理 429 错误

---

## 部署

使用 Kamal 2:
```bash
bin/kamal deploy
```

---

## 更多信息

- **详细设计**: [docs/PRD/DESIGN.md](docs/PRD/DESIGN.md)
- **组件参考**: [docs/ARCH/daisyui-components.md](docs/ARCH/daisyui-components.md)
