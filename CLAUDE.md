# CLAUDE.md

## 项目文档

- 需求设计文档：[docs/PRD/DESIGN.md](docs/PRD/DESIGN.md)
- DaisyUI 组件参考：[docs/ARCH/daisyui-components.md](docs/ARCH/daisyui-components.md)

---

## 技术栈

- **Rails 8.1** + SQLite（Solid Cache / Solid Queue / Solid Cable）
- **Hotwire**：Turbo Drive、Turbo Frames、Turbo Streams + Stimulus
- **CSS**：Tailwind CSS 4 + DaisyUI 5.5+
- **JS bundler**：esbuild（propshaft 资产管道）
- **后台任务**：Solid Queue（Active Job）

---

## 开发准则

### Rails 惯例

- 严格遵循 Rails 8 约定（Convention over Configuration），不造轮子
- 充分使用 Rails 内置能力：`has_secure_password`、`has_many :through`、`enum`、`scope`、`concern`、`delegate` 等
- 路由使用 resourceful routing，嵌套不超过 2 层
- 胖 Model 瘦 Controller：业务逻辑放 Model 或 Service Object，Controller 只负责流程编排
- 复杂查询用 scope 或 Query Object 封装，避免 N+1（善用 `includes` / `eager_load`）
- 常量配置（如 `MAX_WEEKLY_COACHING_REQUESTS = 3`）定义在对应 Model 中

### Hotwire / Turbo 最佳实践

- 优先用 **Turbo Frames** 实现局部更新，避免不必要的全页刷新
- 状态变更（创建、更新）用 **Turbo Streams** 广播，保持页面实时性
- 只在 Turbo 无法满足时才引入 Stimulus Controller，保持 JS 最小化
- 表单提交后用 `redirect_to` + `flash` 或 `turbo_stream` 响应，不返回 JSON
- 不引入前端框架（React / Vue），页面渲染以服务端为主

### UI

- 所有 UI 组件使用 DaisyUI 5.x class（参考 [docs/ARCH/daisyui-components.md](docs/ARCH/daisyui-components.md)），不手写重复样式
- 布局用 Tailwind 工具类，不写自定义 CSS（除非必要）
- 响应式优先，移动端可用

### 数据库 / 模型

- migration 保持幂等，字段加适当 index（外键、频繁查询字段）
- 关联必须加 `foreign_key: true`，删除行为显式声明（`dependent:`）
- 时间字段统一用 `datetime`，带时区
- 枚举用 `enum`，并在数据库层加 check constraint

### 测试

- 使用 Rails 默认 Minitest
- Model 层写单元测试覆盖核心业务逻辑和 scope
- Controller / System 层写集成测试覆盖关键流程
- 不追求 100% 覆盖率，聚焦关键路径

### 代码风格

- 遵循 rubocop-rails-omakase（项目已配置）
- 方法保持短小，超过 15 行考虑拆分
- 不写无谓注释，代码即文档；复杂业务逻辑例外
- 命名用英文，贴近领域语义（如 `request_coaching`、`claim`、`reopen`）
