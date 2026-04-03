# DOTA2 萌新班管理系统 - 产品设计与功能规格

## 项目概述

本系统是为 B 站 UP 主[就是 Ray](https://space.bilibili.com/3219088) 组织的 DOTA2 萌新班提供的辅助系统。

萌新班计划招募 1000 名学员、200 名教练、辅导员若干。所有成员分成 20 个班，每班 5 个组。最小单位为组：每组 10 名学员 + 2 名教练。

---

## 技术架构

### 核心技术栈

| 组件 | 技术 |
|------|------|
| 后端 | Rails 8.1 + Ruby 3.4+ |
| 数据库 | SQLite3 |
| 缓存/队列 | Solid Cache / Solid Queue / Solid Cable |
| 前端 | Hotwire (Turbo + Stimulus) |
| CSS | Tailwind CSS 4 + DaisyUI 5.5+ |
| 认证 | Session-based |
| API | Stratz GraphQL API |

### 项目结构

```
app/
├── controllers/
│   ├── application_controller.rb    # 基础认证逻辑
│   ├── sessions_controller.rb       # 登录/登出
│   ├── matches_controller.rb        # 对局列表/详情
│   ├── stats_controller.rb          # 统计数据
│   ├── users_controller.rb          # 玩家详情
│   ├── leaderboards_controller.rb   # 排行榜
│   ├── classrooms_controller.rb     # 班级管理
│   └── pages_controller.rb          # 首页
├── models/
│   ├── user.rb                      # 用户模型（学员/教练/辅导员/管理员）
│   ├── match.rb                     # 对局基础信息
│   ├── match_player.rb              # 对局玩家数据（关联表）
│   ├── classroom.rb                 # 班级
│   ├── group.rb                     # 小组
│   ├── hero.rb                      # 英雄数据
│   ├── daily_stat.rb                # 每日统计
│   ├── weekly_leaderboard.rb        # 周排行榜
│   └── rank_snapshot.rb             # 段位快照
├── services/
│   └── stratz_api.rb                # Stratz API 客户端
├── jobs/
│   ├── batch_sync_all_players_job.rb    # 批量同步玩家数据
│   ├── calculate_daily_stats_job.rb     # 计算每日统计
│   └── calculate_weekly_leaderboards_job.rb # 计算周排行榜
└── views/                           # DaisyUI 5 组件视图
```

---

## 核心功能模块

### 1. 用户系统

#### 角色类型
- **学员 (student)**: 基础用户，绑定 Steam ID，有 Dota2 对战数据
- **教练 (coach)**: 可查看本组学员数据，辅助管理
- **辅导员 (assistant)**: 班级级管理角色
- **管理员 (admin)**: 系统管理，后台访问权限

#### 用户字段
- `display_name`: 显示名称
- `username`: 登录用户名
- `dota2_player_id`: Steam ID，用于同步数据
- `current_rank` / `highest_rank`: 当前/最高段位
- `total_matches` / `total_wins`: 总场次/胜场
- `classroom_id` / `group_id`: 所属班级/小组

---

### 2. 对局数据同步

#### 数据来源
- Stratz GraphQL API (https://api.stratz.com/graphql)
- 自动同步：每天 4am / 4pm（Solid Queue 定时任务）
- 批量处理：每批 50 个玩家

#### 同步内容
- 对局基础信息：ID、时长、模式、段位、胜负
- 玩家数据：英雄、击杀/死亡/助攻、位置、线路结果、奖项 (MVP/最佳核心/最佳辅助)
- 玩家档案：总场次、胜场、当前段位

#### API 方法
```ruby
StratzApi#batch_sync_players       # 批量同步比赛数据
StratzApi#batch_player_profiles    # 批量获取玩家档案
```

---

### 3. 对局展示

#### 对局列表页 (`/matches`)
- 表格展示所有学员对局
- 筛选：按班级、小组过滤
- 信息：对局 ID、时间、模式、玩家、英雄、KDA、结果
- 分页：Kaminari 分页

#### 个人对局页 (`/matches/mine`, `/users/:id/matches`)
- 显示单个用户的对局历史
- 表格与主列表一致
- 权限：学员只能看自己的，教练/管理员可看任何人的

#### 对局详情页 (`/matches/:id`)
- 天辉/夜魇队伍展示
- 玩家信息：游戏内名称 + 系统用户名
- 班级/小组徽章
- 英雄、KDA、位置、线路结果、奖项

---

### 4. 数据统计

#### 每日统计 (`/stats/daily`)
- 班级/小组维度的每日汇总
- 对局数、胜率、平均 KDA、平均 IMP
- 过去 30 天趋势图

#### 排行榜 (`/leaderboards`)
每周自动计算的排名（6 个维度）：
1. **对局数最多** - 活跃玩家
2. **KDA 最高** - 综合表现
3. **MVP 最多** - 最佳表现
4. **段位提升最多** - 进步最快
5. **胜场最多** - 胜利贡献
6. **IMP 最高** - 影响力

支持查看历史周排行榜。

#### 班级统计 (`/classrooms/mine`)
- 教练视角：查看本班各组学员
- 展示最近 10 场对局的英雄头像墙
- 胜负用绿/红边框区分

---

### 5. 段位系统

#### 段位映射
| Rank 范围 | 段位名 |
|-----------|--------|
| 0-9 | 先锋 1-5 星 |
| 10-19 | 卫士 1-5 星 |
| 20-29 | 中军 1-5 星 |
| 30-39 | 统帅 1-5 星 |
| 40-49 | 传奇 1-5 星 |
| 50-59 | 万古流芳 1-5 星 |
| 60-69 | 超凡入圣 1-5 星 |
| 70+ | 冠绝一世 |

#### 段位快照
- 每次同步时记录段位变化
- 用于计算"段位提升"排行榜

---

### 6. 游戏模式映射

| ID | 模式名 |
|----|--------|
| 0 | 未知 |
| 1 | 全英雄选择 |
| 22 | 全英雄选择（抢选）|
| 23 | 加速模式 |

---

### 7. 自动化任务（Solid Queue）

#### 定时任务配置 (`config/recurring.yml`)
```yaml
# 每天 4am / 4pm 同步数据
sync_morning: "0 4 * * * Asia/Shanghai"
sync_evening: "0 16 * * * Asia/Shanghai"

# 每天 5am / 5pm 计算统计
calculate_morning: "0 5 * * * Asia/Shanghai"
calculate_evening: "0 17 * * * Asia/Shanghai"

# 每周一 3am 计算排行榜
weekly_leaderboards: "0 3 * * 1 Asia/Shanghai"
```

---

## 关键业务逻辑

### 数据同步流程
1. **BatchSyncAllPlayersJob** 获取所有活跃学员的 Steam ID
2. **StratzApi#batch_sync_players** 分批查询（50/批）
3. 创建/更新 Match 和 MatchPlayer 记录
4. **StratzApi#batch_player_profiles** 更新用户段位信息
5. **CalculateDailyStatsJob** 计算每日统计
6. **RankSnapshot.capture_for_user** 记录段位快照

### 权限检查
```ruby
# 认证
before_action :require_authentication

# 仅管理员
before_action :require_admin!

# 仅教练/管理员
current_user.coach? || current_user.admin?

# 只能看自己的（学员）
current_user == @user || current_user.coach? || current_user.admin?
```

---

## UI/UX 设计规范

### 主题
- 默认深色主题 (`data-theme="dark"`)
- DaisyUI 5 组件系统

### 常用组件模式

#### 页面布局
```erb
<div class="container mx-auto p-4">
  <h1 class="text-2xl font-bold mb-4">标题</h1>
  
  <div class="card bg-base-200">
    <div class="card-body">
      <!-- 内容 -->
    </div>
  </div>
</div>
```

#### 数据表格
```erb
<div class="overflow-x-auto">
  <table class="table">
    <thead>
      <tr>
        <th>列名</th>
      </tr>
    </thead>
    <tbody>
      <tr class="<%= won ? 'bg-success/10' : 'bg-error/10' %>">
        <td>数据</td>
      </tr>
    </tbody>
  </table>
</div>
```

#### 状态徽章
```erb
<span class="badge badge-success">胜利</span>
<span class="badge badge-error">失败</span>
<span class="badge badge-warning">MVP</span>
<span class="badge badge-primary">最佳核心</span>
<span class="badge badge-secondary">最佳辅助</span>
```

完整组件文档：[docs/ARCH/daisyui-components.md](docs/ARCH/daisyui-components.md)

---

## API 集成细节

### Stratz GraphQL 查询
- 批量查询：每批最多 50 个玩家
- 字段：比赛数据 + 玩家档案
- 错误处理：RateLimitError, ApiError

### 段位计算
```ruby
# Match#rank_name
def rank_name
  return nil if average_rank.nil?
  
  tier = average_rank / 10
  star = (average_rank % 10) + 1
  tier_name = RANK_NAMES[tier]
  
  tier >= 7 ? tier_name : "#{tier_name} #{star}星"
end
```

---

## 测试

### 测试结构
```
test/
├── fixtures/           # 测试数据
├── models/            # 模型测试
├── integration/       # 集成测试
└── test_helper.rb     # 测试配置
```

### 登录测试辅助
```ruby
# test/test_helper.rb
def sign_in(user)
  get "/test/sign_in/#{user.id}"
end
```

### 运行测试
```bash
bin/rails test
bundle exec rubocop
```

---

## 环境变量

```bash
STRATZ_API_TOKEN=xxx    # Stratz API 令牌
RAILS_ENV=production
```

---

## 部署

使用 Kamal 2 部署：
```bash
bin/kamal deploy
```

---

## 更新日志

### 2025-04-03
- 删除 CoachingRequest 模块（复盘系统）
- 修复批量同步优化（50玩家/请求）
- 修复段位显示（中军 3星 格式）
- 修复游戏模式映射（ALL_PICK_RANKED）
- 修复测试套件，所有测试通过
