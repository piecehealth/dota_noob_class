# DOTA2 萌新班管理系统

本系统是为 B 站 UP 主[就是 Ray](https://space.bilibili.com/3219088) 组织的 DOTA2 萌新班提供的辅助系统。

萌新班计划招募 1000 名学员、200 名教练、辅导员若干。所有成员分成 20 个班，每班 5 个组。最小单位为组：每组 10 名学员 + 2 名教练。

---

## 用户角色

| 角色 | 说明 |
|------|------|
| 辅导员 | 系统管理员，负责协调全局资源 |
| 教练 | 辅导本班练习生，在系统认领并处理指导请求 |
| 学员 | DOTA2 练习生，绑定 DOTA2 账号，发起指导请求，需每周保持对战活跃 |
| 匿名用户 | 可查看公开信息（如上周 MMR 涨分 Top 10 学员） |

---

## 系统功能

### 1. 用户录入

由开发人员通过 Rails console 批量创建用户，创建时需提供：

- 登录用户名
- 角色（学员 / 教练 / 辅导员）
- 班级
- 组
- DOTA2 Player ID（仅学员）

创建成功后系统为每个用户生成唯一激活链接，由管理员线下分发。用户通过链接激活账号并设置密码。

---

### 2. 游戏数据收集

线下要求学员在 DOTA2 客户端开启 **Expose Public Match Data** 选项，以便系统通过 OpenDota API 拉取对战记录。

**API**：`GET https://api.opendota.com/api/players/{player_id}/matches`

同步方式有两种：

**主动同步（学员触发）**
1. 学员在浏览器点击「同步我最近的对战记录」
2. 前端 JS 直接请求 OpenDota API
3. 拿到数据后 POST 到我们的后端接口写入数据库

优点：绕过 OpenDota 的 rate limit（请求来自学员各自 IP）；match 数据本身易于校验，安全风险低。

**后端定时同步（保底）**
后端定时任务对超过 N 天未更新的学员自动拉取最新 match 数据。

---

### 3. 学员 / 教练指导系统

类似 Jira ticket 系统。学员找到自己的比赛记录，发起指导请求；教练认领后在系统内留下 comment，实际复盘可在站外（语音、Discord 等）进行。

#### 指导请求状态流转

```
(无) ──→ requested ──→ in_progress ──→ completed
                                           │
                                        reopen
                                           │
                                           ▼
                                       requested
```

| 状态 | 触发方 | 说明 |
|------|--------|------|
| `requested` | 学员 | 学员对某场比赛发起指导请求 |
| `in_progress` | 教练 | 教练认领，进入指导中 |
| `completed` | 学员或教练 | 标记指导完毕 |
| reopen → `requested` | 学员 | 对已完毕的请求重新发起，复用同一条记录 |

每次状态流转写入 audit log（记录 from_status / to_status / 操作人 / 时间）。

#### 规则

- 每场比赛对应最多 1 条 CoachingRequest（1 对 1）
- 每名学员每周最多提交 **3 条**指导请求（`MAX_WEEKLY_COACHING_REQUESTS = 3`）
- 所有人（学员、教练、辅导员）均可在比赛下方留 comment

#### 教练视角优先级

教练登录后看到待指导请求，优先级：**本组 → 本班 → 全部**（无系统推送，教练主动查看）

#### 管理员视角

辅导员可查看长时间无人认领的指导请求，便于协调教练资源。

---

### 4. 学员活跃度展示

类似 GitHub 贡献墙：一行代表一名学员，每格代表一周，颜色深浅反映该周对战数量。匿名用户、辅导员均可查看。

---

## 数据模型概览

```
User
  - role: enum(student, coach, assistant)
  - class_id, group_id
  - dota2_player_id       # 仅学员

Class（班）
  - has many Group

Group（组）
  - belongs to Class
  - has many User

Match
  - belongs to User(student)
  - opendota 数据（match_id, hero, result, played_at 等）
  - has one CoachingRequest

CoachingRequest                     # 与 Match 1 对 1
  - belongs to Match
  - belongs to User(student)
  - belongs to User(coach)
  - status: requested / in_progress / completed
  - has many CoachingRequestEvent   # audit log
  - has many Comment

CoachingRequestEvent                # audit log
  - coaching_request_id
  - from_status, to_status
  - operator(User)
  - created_at

Comment
  - belongs to Match
  - belongs to User

WeeklyActivity                      # 活跃度贡献墙
  - belongs to User(student)
  - week(date)
  - match_count
```
