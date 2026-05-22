# LifeHub Health App 增强与后端联动规划

**版本：** 1.0  
**日期：** 2026-05-21  
**状态：** ✅ 前端全部实施完成（Phase 1-8），后端部分待开发

---

## 一、项目现状分析

### 1.1 已完成功能

| 模块 | 前端 | 后端 | 联动状态 |
|------|------|------|----------|
| 认证（登录/Token刷新） | ✅ | ✅ | ✅ 已联通 |
| 健康档案 | ✅ | ✅ | ✅ 已联通 |
| 每日活动汇总 | ✅ | ✅ | ✅ 已联通 |
| 运动记录 CRUD | ✅ | ✅ | ✅ 已联通 |
| 饮食记录 CRUD | ✅ | ✅ | ✅ 已联通 |
| 体重记录 CRUD | ✅ | ✅ | ✅ 已联通 |
| AI 聊天（SSE 流式） | ✅ | ✅ | ✅ 已联通 |
| 心理档案 | ✅ | ✅ | ✅ 已联通 |
| 每日心情 | ✅ | ✅ | ✅ 已联通 |
| 心理评估（PHQ-9/GAD-7） | ✅ | ✅ | ✅ 已联通 |
| 聊天记忆 | ✅ | ✅ | ✅ 已联通 |
| AI 建议记录 | ✅ | ✅ | ✅ 已联通 |
| 跟踪计划 | ✅ | ✅ | ✅ 已联通 |
| 打卡系统 | ✅ | ✅ | ✅ 已联通 |
| 用户偏好 | ✅ | ✅ | ✅ 已联通 |

### 1.2 现有问题与不足

1. **首页仪表板过于简单** — 仅显示步数、卡路里、活动时长、体重四个指标，AI 建议区域为静态占位文本
2. **缺乏数据可视化** — 无趋势图表（体重变化、心情波动、运动频率）
3. **健康目标模块未在 UI 中体现** — 后端已支持 `/health/goals/my`，但前端无目标设置/追踪界面
4. **睡眠数据缺失** — 后端 goalType 支持 "sleep"，但无专门的睡眠记录模块
5. **饮水量追踪缺失** — 日常健康管理的基础功能
6. **通知/提醒系统空白** — 代码中有 TODO 标记，未实现
7. **AI 建议与首页未联动** — agent/advice-records 数据未在首页动态展示
8. **打卡系统缺乏激励机制** — 无连续打卡统计、成就徽章
9. **周/月报告功能缺失** — 无阶段性健康报告生成
10. **数据导出功能缺失** — 用户无法导出个人健康数据

---

## 二、增强规划

### Phase 1：首页仪表板升级 + AI 建议联动（优先级：高）

**目标：** 让首页成为用户每天打开 App 的信息中枢

#### 1.1 动态 AI 建议卡片
- 调用 `GET /health/agent/advice-records/my?activeOnly=true` 获取当前有效建议
- 按 `agentType`（diet/exercise/psychology/sleep）分类展示
- 点击跳转到建议详情或关联的跟踪计划

#### 1.2 今日打卡进度
- 调用 `GET /health/agent/checkins/my` 筛选今日数据
- 显示今日计划完成率（环形进度条）
- 快捷打卡入口

#### 1.3 健康趋势迷你图
- 体重 7 天趋势线（`GET /health/weight-logs/range`）
- 心情 7 天趋势线（`GET /health/psychology/daily-moods/range`）
- 使用 fl_chart 的 LineChart 组件

#### 1.4 今日心情快捷记录
- 首页直接选择心情分数（emoji 选择器）
- 调用 `POST /health/psychology/daily-moods` 一键记录

**涉及文件：**
```
lib/features/home/presentation/screens/home_screen.dart  (重构)
lib/features/home/presentation/widgets/                   (新增组件)
  ├── ai_advice_card.dart
  ├── checkin_progress_card.dart
  ├── mini_trend_chart.dart
  └── quick_mood_card.dart
lib/features/home/presentation/providers/home_provider.dart (增强)
lib/features/home/data/repositories/home_repository.dart    (增强)
```

---

### Phase 2：健康目标系统（优先级：高）

**目标：** 让用户设定并追踪健康目标，与 AI 建议形成闭环

#### 2.1 目标设置页面（新增）
- 支持目标类型：减重、增重、运动、饮食、睡眠、其他
- 设置目标值、截止日期
- 调用 `POST /health/goals`（后端已有，需确认端点）

#### 2.2 目标进度追踪
- 根据 goalType 自动关联数据源：
  - `weight_loss/weight_gain` → 体重记录对比
  - `exercise` → 活动时长/频率统计
  - `diet` → 卡路里控制统计
- 显示进度百分比 + 预计达成时间

#### 2.3 目标与 AI 建议联动
- AI Agent 根据目标进度自动生成建议
- 目标偏离时推送提醒

**新增文件：**
```
lib/features/goals/                              (新 feature 模块)
  ├── data/
  │   ├── datasources/goals_remote_datasource.dart
  │   ├── models/health_goal_model.dart
  │   └── repositories/goals_repository_impl.dart
  ├── domain/
  │   ├── entities/health_goal.dart
  │   ├── repositories/goals_repository.dart
  │   └── usecases/
  └── presentation/
      ├── providers/goals_provider.dart
      ├── screens/
      │   ├── goals_screen.dart
      │   └── add_goal_screen.dart
      └── widgets/
          ├── goal_progress_card.dart
          └── goal_timeline.dart
```

**后端需要确认/新增：**
- `POST /health/goals` — 创建目标
- `PUT /health/goals/{id}` — 更新目标状态
- `GET /health/goals/progress` — 目标进度统计（可能需要新增）

---

### Phase 3：睡眠追踪模块（优先级：中）

**目标：** 补全健康管理的睡眠维度

#### 3.1 睡眠记录
- 记录入睡时间、起床时间、睡眠质量评分
- 自动计算睡眠时长
- 支持标记深睡/浅睡/清醒时段（手动）

#### 3.2 睡眠趋势分析
- 7/30 天睡眠时长柱状图
- 睡眠质量折线图
- 最佳入睡时间建议（基于历史数据）

**后端需要新增：**
```
POST /health/sleep-logs          — 创建睡眠记录
GET  /health/sleep-logs/my       — 获取我的睡眠记录
GET  /health/sleep-logs/date/{date}  — 按日期查询
GET  /health/sleep-logs/range    — 按范围查询
GET  /health/sleep-logs/latest   — 获取最新记录
```

**SleepLog 数据模型：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `sleepDate` | `date` | 睡眠日期（入睡那天） |
| `bedTime` | `datetime` | 上床时间 |
| `wakeTime` | `datetime` | 起床时间 |
| `durationMinutes` | `int` | 总睡眠时长（分钟） |
| `qualityScore` | `int` | 质量评分 (1-10) |
| `deepSleepMinutes` | `int?` | 深睡时长 |
| `lightSleepMinutes` | `int?` | 浅睡时长 |
| `awakeMinutes` | `int?` | 清醒时长 |
| `notes` | `string?` | 备注 |
| `createdAt` | `datetime?` | 创建时间 |

---

### Phase 4：饮水量追踪（优先级：中）

**目标：** 帮助用户养成良好饮水习惯

#### 4.1 饮水记录
- 快捷按钮（250ml / 500ml / 自定义）
- 今日饮水总量 + 目标进度
- 首页快捷入口

#### 4.2 饮水提醒
- 可设置间隔提醒（如每2小时）
- 本地通知实现

**后端需要新增：**
```
POST /health/water-logs          — 创建饮水记录
GET  /health/water-logs/date/{date}  — 按日期查询
GET  /health/water-logs/today-total  — 今日总量
```

**WaterLog 数据模型：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `recordTime` | `datetime` | 记录时间 |
| `amountMl` | `int` | 饮水量（毫升） |
| `drinkType` | `string?` | 类型（water/tea/coffee/other） |
| `createdAt` | `datetime?` | 创建时间 |

---

### Phase 5：数据可视化增强（优先级：中）

**目标：** 让用户直观看到健康数据变化趋势

#### 5.1 健康数据页面图表升级
- 体重趋势图（折线图 + 目标线）
- 运动频率热力图（类似 GitHub contribution）
- 营养摄入分布（饼图：蛋白质/碳水/脂肪占比）
- 卡路里收支平衡（摄入 vs 消耗对比柱状图）

#### 5.2 心理健康可视化
- 心情日历热力图（按日显示颜色深浅）
- 评估分数历史对比图
- 情绪词云（基于 primaryEmotion 统计）

#### 5.3 综合健康评分
- 基于多维数据（运动、饮食、睡眠、心理）计算综合得分
- 雷达图展示各维度状态
- 与上周/上月对比

**技术方案：**
- 图表库：继续使用 `fl_chart`
- 热力图：自定义 Widget 或引入 `flutter_heatmap_calendar`
- 数据聚合：前端本地计算 + 后端可选聚合 API

---

### Phase 6：通知与提醒系统（优先级：中）

**目标：** 帮助用户建立健康习惯

#### 6.1 本地提醒
- 饮水提醒（定时本地通知）
- 运动提醒（自定义时间）
- 打卡提醒（关联跟踪计划）
- 睡眠提醒（入睡时间到了）

#### 6.2 智能提醒（需后端支持）
- AI 根据用户行为模式推送建议时机
- 久坐提醒（基于活动数据）
- 目标偏离预警

**技术方案：**
- 本地通知：`flutter_local_notifications`
- 推送通知：后续可接入 FCM/APNs
- 提醒配置存储：`Hive` 本地 + `UserPreferences` 后端同步

---

### Phase 7：周/月报告（优先级：低）

**目标：** 阶段性总结用户健康状况

#### 7.1 周报
- 本周运动总时长 / 总卡路里消耗
- 体重变化
- 平均心情分数
- AI 生成的总结语

#### 7.2 月报
- 月度各指标趋势
- 目标完成情况
- 健康评分变化
- AI 综合分析与下月建议

**实现方案：**
- 前端聚合：利用已有的 range 查询 API 拉取数据，本地计算统计
- AI 总结：调用 `POST /health/chat/agent`，传入统计数据让 AI 生成报告文案
- 后端可选：新增 `GET /health/reports/weekly` / `GET /health/reports/monthly` 预计算端点

---

### Phase 8：打卡激励与成就系统（优先级：低）

**目标：** 提升用户黏性和使用积极性

#### 8.1 连续打卡统计
- 当前连续打卡天数
- 历史最长连续天数
- 打卡日历视图

#### 8.2 成就徽章
- 里程碑：首次记录、7天连续、30天连续、100天连续
- 数据类：累计运动100小时、减重达标、完成首次评估
- 展示：个人中心成就墙

**后端需要新增：**
```
GET /health/agent/checkins/streak    — 连续打卡统计
GET /health/achievements/my          — 我的成就列表
POST /health/achievements/check      — 检查并解锁成就
```

---

## 三、后端联动增强清单

### 3.1 现有 API 的深度利用（无需后端改动）

| 前端增强点 | 使用的 API | 说明 |
|-----------|-----------|------|
| 首页 AI 建议动态化 | `GET /health/agent/advice-records/my?activeOnly=true` | 展示最新有效建议 |
| 首页打卡进度 | `GET /health/agent/checkins/my` + `GET /health/agent/followup-plans/my?activeOnly=true` | 计算今日完成率 |
| 体重趋势图 | `GET /health/weight-logs/range` | 7/30天折线图 |
| 心情趋势图 | `GET /health/psychology/daily-moods/range` | 7/30天折线图 |
| 目标列表展示 | `GET /health/goals/my` | 目标卡片 + 进度 |
| 评估历史对比 | `GET /health/psychology/assessments/my` | 分数变化图 |
| 运动类型统计 | `GET /health/activities/my` | 按 activityType 分组统计 |
| 饮食营养分析 | `GET /health/diet-logs/my` | 按日期聚合营养素 |

### 3.2 需要后端新增的 API

| API | 模块 | 优先级 | 用途 |
|-----|------|--------|------|
| `POST /health/goals` | goals | 高 | 创建健康目标 |
| `PUT /health/goals/{id}/status` | goals | 高 | 更新目标状态 |
| `POST /health/sleep-logs` | sleep | 中 | 创建睡眠记录 |
| `GET /health/sleep-logs/my` | sleep | 中 | 睡眠记录列表 |
| `GET /health/sleep-logs/range` | sleep | 中 | 睡眠范围查询 |
| `POST /health/water-logs` | water | 中 | 饮水记录 |
| `GET /health/water-logs/date/{date}` | water | 中 | 当日饮水 |
| `GET /health/agent/checkins/streak` | agent | 低 | 连续打卡统计 |
| `GET /health/reports/weekly` | reports | 低 | 周报数据 |
| `GET /health/reports/monthly` | reports | 低 | 月报数据 |

### 3.3 后端数据库新增表

```sql
-- 睡眠记录表
CREATE TABLE healthy_sleep_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    sleep_date DATE NOT NULL,
    bed_time DATETIME,
    wake_time DATETIME,
    duration_minutes INT,
    quality_score INT,
    deep_sleep_minutes INT,
    light_sleep_minutes INT,
    awake_minutes INT,
    notes VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_date (user_id, sleep_date)
);

-- 饮水记录表
CREATE TABLE healthy_water_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    record_time DATETIME NOT NULL,
    amount_ml INT NOT NULL,
    drink_type VARCHAR(50) DEFAULT 'water',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_time (user_id, record_time)
);
```

---

## 四、实施路线图

```
Phase 1 (1-2周)    ▓▓▓▓▓▓▓▓░░  首页升级 + AI 建议联动
Phase 2 (1周)      ▓▓▓▓▓░░░░░  健康目标系统
Phase 3 (1周)      ▓▓▓▓░░░░░░  睡眠追踪
Phase 4 (3天)      ▓▓▓░░░░░░░  饮水追踪
Phase 5 (1周)      ▓▓▓▓▓░░░░░  数据可视化增强
Phase 6 (3天)      ▓▓▓░░░░░░░  通知与提醒
Phase 7 (3天)      ▓▓░░░░░░░░  周/月报告
Phase 8 (3天)      ▓▓░░░░░░░░  打卡激励
```

**总预估：** 5-6 周

---

## 五、技术要点

### 5.1 前端架构原则
- 继续遵循 Clean Architecture 分层
- 新模块统一使用 Riverpod 管理状态
- 图表组件封装为可复用 Widget
- 网络请求统一走 `ApiService`，复用 Token 刷新机制

### 5.2 后端开发原则
- 新增模块遵循已有 Controller → Service → Mapper 结构
- 统一响应格式（`{ code, message, data, timestamp, success }`）
- JWT 认证一致，自动提取 userId
- MyBatis-Plus 生成基础 CRUD

### 5.3 前后端联调流程
1. 后端先开发 API 并自测
2. 更新 `docs/api-contracts.md` 契约文档
3. 前端按契约开发 Repository + Provider
4. 联调验证

---

## 六、下一步行动

1. **立即可做（Phase 1）：** 首页重构 — 不需要后端改动，直接利用现有 API
2. **同步推进：** 与后端沟通确认 Goals 模块的创建/更新端点
3. **后端排期：** Sleep 和 Water 模块的数据库表 + API 开发

---

> 💡 建议从 Phase 1 开始实施，因为它不依赖后端新增功能，可以立即提升用户体验。
