# LifeHub Health API 接口契约

**版本：** 2.0
**日期：** 2026-04-30
**基础URL：** `https://api.lifehub.com`
**认证方式：** `Authorization: Bearer {token}`
**范围声明：** 本文档为移动端（App）面向的接口契约，仅包含 App 需要调用的端点。服务端还暴露了通用 CRUD（按 ID 查询、分页、删除、更新等），此处不逐一列出。

---

## 通用约定

### 日期与时间格式

| 类型 | 格式 | 示例 | 说明 |
|------|------|------|------|
| `date` | `yyyy-MM-dd` | `2026-04-30` | 纯日期，对应 Java `LocalDate`，本地日期 |
| `datetime` | `yyyy-MM-dd'T'HH:mm:ss` | `2026-04-30T14:30:00` | 日期时间，对应 Java `LocalDateTime`，不含时区偏移 |

### 统一响应格式

所有接口返回 JSON 信封：

```json
{
  "code": 200,
  "message": "success",
  "data": "<T | null>",
  "timestamp": 1746000000000,
  "success": true
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `code` | `int` | 业务状态码，200 = 成功，500 = 服务端错误 |
| `message` | `string` | 人类可读描述 |
| `data` | `T?` | 业务数据，可能为 `null` |
| `timestamp` | `long` | 服务器时间戳（毫秒） |
| `success` | `bool` | `code == 200` 的快捷判断 |

### 错误响应

HTTP 状态码与业务码的关系：

| HTTP Status | 业务 `code` | 含义 |
|-------------|------------|------|
| 200 | 200 | 成功 |
| 400 | 500 | 请求参数无效（校验失败） |
| 401 | 500 | Token 缺失或已过期 |
| 403 | 500 | 无权限访问该资源 |
| 500 | 500 | 服务端内部错误 |

校验错误响应示例（字段级校验由 Spring `@Valid` 触发）：

```json
{
  "code": 500,
  "message": "username: 用户名只能包含字母数字下划线",
  "data": null,
  "timestamp": 1746000000000,
  "success": false
}
```

### 认证要求

除 `POST /auth/login`、`POST /auth/wx-login` 外，所有端点均需在请求头携带有效 JWT Token。服务端从 Token 中提取 `userId`，拒绝跨用户访问。

### 字符串枚举约定

服务端模型字段为 `String` 类型，无强约束。以下为前后端约定的取值范围：

| 字段 | 约定值 |
|------|--------|
| `gender` | `"male"` / `"female"` / `"other"` |
| `activityType` | `"running"` / `"walking"` / `"cycling"` / `"swimming"` / `"yoga"` / `"strength"` / `"other"` |
| `mealType` | `"breakfast"` / `"lunch"` / `"dinner"` / `"snack"` |
| `role`（聊天） | `"user"` / `"assistant"` / `"system"` |
| `scaleName` | `"PHQ-9"` / `"GAD-7"` / `"PSS"` / `"DASS-21"` |
| `severityLevel` | `"normal"` / `"mild"` / `"moderate"` / `"severe"` |
| `completionStatus` | `"completed"` / `"partial"` / `"skipped"` |
| `goalType` | `"weight_loss"` / `"weight_gain"` / `"exercise"` / `"diet"` / `"sleep"` / `"other"` |
| `goalStatus` | `"active"` / `"achieved"` / `"abandoned"` |
| `agentType` | `"diet"` / `"exercise"` / `"psychology"` / `"sleep"` / `"general"` |

---

## 1. 认证模块

### 1.1 登录

```
POST /auth/login
认证：无
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `username` | `string` | 是 | 3-50 字符，仅 `[a-zA-Z0-9_]` |
| `password` | `string` | 是 | 6-100 字符 |

**成功响应 `data`：**

```json
{
  "token": "eyJhbGciOi...",
  "user": {
    "id": 1,
    "username": "zhangsan",
    "nickname": "张三",
    "avatar": null
  }
}
```

> **注意：** 登录接口仅返回 `token` 和 `user`，**不返回 `refreshToken`**。Token 刷新机制见 1.4。

### 1.2 微信登录

```
POST /auth/wx-login
认证：无
```

**请求 Body：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `code` | `string` | 是 | 微信小程序 `wx.login()` 获取的临时凭证 |

**成功响应 `data`：** 与 1.1 相同格式 `{ token, user }`。

### 1.3 获取当前用户信息

```
GET /auth/profile
认证：Bearer Token
```

**成功响应 `data`：**

```json
{
  "id": 1,
  "username": "zhangsan",
  "nickname": "张三",
  "avatar": "https://..."
}
```

### 1.4 刷新 Token

```
POST /auth/refresh
认证：无
```

**请求 Body：** 纯字符串（非 JSON 对象），即直接发送 refresh token 原文。

```
Content-Type: text/plain

eyJhbGciOi...
```

> **注意：** 服务端接收 `@RequestBody String refreshToken`，是原始字符串而非 JSON 对象。

**成功响应 `data`：**

```json
{
  "token": "eyJhbGciOi...",
  "refreshToken": "eyJhbGciOi...",
  "tokenType": "Bearer",
  "expiresIn": 86400000,
  "username": "zhangsan",
  "avatar": null
}
```

---

## 2. 健康数据模块

### 2.1 用户健康档案

#### 获取我的健康档案

```
GET /health/user-profiles/my
认证：Bearer Token
```

**成功响应 `data`：**

```json
{
  "id": 1,
  "userId": 1,
  "birthDate": "1995-06-15",
  "gender": "male",
  "heightCm": 175.0,
  "baselineWeightKg": 70.0,
  "targetWeightKg": 65.0,
  "createdAt": "2026-04-01T10:00:00",
  "updatedAt": "2026-04-30T08:00:00"
}
```

**无档案时：** `data` 为 `null`。

#### 初始化/更新健康档案

```
POST /health/user-profiles/init
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `birthDate` | `date?` | 否 | `yyyy-MM-dd` |
| `gender` | `string?` | 否 | 见枚举约定 |
| `heightCm` | `decimal?` | 否 | 单位 cm |
| `baselineWeightKg` | `decimal?` | 否 | 单位 kg |
| `targetWeightKg` | `decimal?` | 否 | 单位 kg |

> 该接口为 upsert 语义：无档案则创建，有则更新传入的字段。

**成功响应 `data`：** 更新后的档案对象。`success` 为 `true`。

### 2.2 每日活动汇总

#### 获取指定日期汇总

```
GET /health/daily-summaries/date/{recordDate}
认证：Bearer Token
路径参数：recordDate — yyyy-MM-dd
```

**成功响应 `data`：** 单个 `DailySummary` 对象，无数据时为 `null`。

#### 获取我的所有汇总

```
GET /health/daily-summaries/my
认证：Bearer Token
```

**成功响应 `data`：** `[DailySummary]`

#### 按日期范围查询

```
GET /health/daily-summaries/range?startDate=2026-04-24&endDate=2026-04-30
认证：Bearer Token
查询参数：startDate, endDate — 均为 yyyy-MM-dd
```

**成功响应 `data`：** `[DailySummary]`

**DailySummary 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `recordDate` | `date` | 记录日期 |
| `totalSteps` | `int` | 总步数，默认 0 |
| `activeCaloriesKcal` | `decimal` | 活动消耗卡路里，默认 0 |
| `restingCaloriesKcal` | `decimal` | 静息消耗卡路里，默认 0 |
| `totalDistanceMeters` | `decimal` | 总距离（米），默认 0 |
| `activeMinutes` | `int` | 活动时长（分钟），默认 0 |
| `createdAt` | `datetime?` | 创建时间 |
| `updatedAt` | `datetime?` | 更新时间 |

### 2.3 运动记录

#### 创建运动记录

```
POST /health/activities
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `activityType` | `string` | 是 | 见枚举约定 |
| `startTime` | `datetime?` | 否 | 默认当前时间 |
| `durationMinutes` | `int` | 是 | ≥ 1 |
| `caloriesBurned` | `decimal?` | 否 | 单位 kcal |
| `description` | `string?` | 否 | 备注描述 |

**成功响应 `data`：** 创建后的 `HealthActivity` 对象。

#### 获取我的运动记录

```
GET /health/activities/my?activityType=
认证：Bearer Token
查询参数：activityType — 可选，按类型筛选
```

**成功响应 `data`：** `[HealthActivity]`

**HealthActivity 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `activityType` | `string` | 运动类型 |
| `startTime` | `datetime?` | 开始时间 |
| `durationMinutes` | `int` | 时长（分钟） |
| `caloriesBurned` | `decimal?` | 消耗卡路里 |
| `description` | `string?` | 描述 |
| `createdAt` | `datetime?` | 创建时间 |

### 2.4 饮食记录

#### 创建饮食记录

```
POST /health/diet-logs
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `mealTime` | `datetime` | 是 | 就餐时间 |
| `mealType` | `string` | 是 | 见枚举约定 |
| `foodItems` | `string` | 是 | 食物描述 |
| `totalCalories` | `decimal?` | 否 | 单位 kcal |
| `proteinG` | `decimal?` | 否 | 蛋白质（克） |
| `carbsG` | `decimal?` | 否 | 碳水（克） |
| `fatG` | `decimal?` | 否 | 脂肪（克） |

**成功响应 `data`：** 创建后的 `DietLog` 对象。

#### 获取我的饮食记录

```
GET /health/diet-logs/my?mealType=
认证：Bearer Token
查询参数：mealType — 可选，按餐次筛选
```

#### 按日期查询

```
GET /health/diet-logs/date/{date}
认证：Bearer Token
路径参数：date — yyyy-MM-dd
```

**成功响应 `data`：** `[DietLog]`

**DietLog 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `mealTime` | `datetime` | 就餐时间 |
| `mealType` | `string` | 餐次类型 |
| `foodItems` | `string` | 食物描述 |
| `totalCalories` | `decimal?` | 总卡路里 |
| `proteinG` | `decimal?` | 蛋白质（g） |
| `carbsG` | `decimal?` | 碳水（g） |
| `fatG` | `decimal?` | 脂肪（g） |
| `createdAt` | `datetime?` | 创建时间 |

### 2.5 体重记录

#### 创建体重记录

```
POST /health/weight-logs
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `recordDate` | `date` | 是 | `yyyy-MM-dd` |
| `weightKg` | `decimal` | 是 | 单位 kg |
| `bodyFatPercentage` | `decimal?` | 否 | 体脂率（%） |
| `bmi` | `decimal?` | 否 | 服务端自动计算时可留空 |

**成功响应 `data`：** 创建后的 `WeightLog` 对象。

#### 获取我的体重记录

```
GET /health/weight-logs/my
认证：Bearer Token
```

#### 获取最新体重

```
GET /health/weight-logs/latest
认证：Bearer Token
```

**成功响应 `data`：** 单个 `WeightLog`，无数据时为 `null`。

#### 按日期范围查询

```
GET /health/weight-logs/range?startDate=2026-04-01&endDate=2026-04-30
认证：Bearer Token
```

**成功响应 `data`：** `[WeightLog]`

**WeightLog 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `recordDate` | `date` | 记录日期 |
| `weightKg` | `decimal` | 体重（kg） |
| `bodyFatPercentage` | `decimal?` | 体脂率（%） |
| `bmi` | `decimal?` | BMI |
| `createdAt` | `datetime?` | 创建时间 |

### 2.6 健康目标

#### 获取我的目标

```
GET /health/goals/my?status=&goalType=
认证：Bearer Token
查询参数：status、goalType — 均可选
```

**成功响应 `data`：** `[HealthGoal]`

**HealthGoal 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `goalType` | `string` | 目标类型，见枚举约定 |
| `targetValue` | `decimal` | 目标值 |
| `deadline` | `date?` | 截止日期 |
| `status` | `string` | 状态：active/achieved/abandoned |
| `createdAt` | `datetime?` | 创建时间 |

---

## 3. AI 聊天模块

### 3.1 流式聊天（SSE）

```
POST /health/chat/stream
认证：Bearer Token
Content-Type: application/json
Accept: text/event-stream
```

**请求 Body：**

| 字段 | 类型 | 必填 | 默认值 | 约束 |
|------|------|------|--------|------|
| `message` | `string` | 是 | — | `@NotBlank` |
| `historyLimit` | `int?` | 否 | `10` | `@Min(0)`, `@Max(20)` |
| `useAgent` | `bool?` | 否 | `true` | 是否启用 Agent 模式 |

> **安全边界：** 服务端模型还包含 `systemPrompt` 和 `userIdForAgent` 字段。**客户端不得传递这两个字段。** 系统提示词和用户身份均由服务端从 JWT Token 中派生，客户端控制这些字段会带来注入风险。

**响应：** Server-Sent Events 流，事件类型与数据结构：

| 事件顺序 | `type` | `data` 结构 | 说明 |
|----------|--------|-------------|------|
| 首个 | `start` | `{ "type": "start", "content": "", "done": false, "timestamp": 1746000000 }` | 流开始 |
| 中间（0-N 次） | `delta` | `{ "type": "delta", "content": "文本片段", "done": false, "timestamp": 1746000001 }` | 增量内容 |
| 结束 | `complete` | `{ "type": "complete", "content": "", "done": true, "timestamp": 1746000005 }` | 流结束 |
| 异常 | `error` | `{ "type": "error", "content": "错误描述", "done": true, "timestamp": 1746000002 }` | 出错终止 |

**HealthChatStreamChunk 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `type` | `string` | 事件类型：`start` / `delta` / `complete` / `error` |
| `content` | `string` | 内容片段 |
| `done` | `bool` | 是否结束 |
| `timestamp` | `long` | 事件时间戳（秒） |

### 3.2 Agent 同步调用

```
POST /health/chat/agent
认证：Bearer Token
```

**请求 Body：** 与 3.1 相同的 `HealthChatStreamRequest`。

**成功响应 `data`：**

```json
{
  "state": { ... },
  "summary": { ... },
  "record_payload": { ... }
}
```

---

## 4. 心理健康模块

> **隐私与安全声明：** 本模块涉及心理评估结果、情绪日记（`journalText`）、聊天记忆等敏感个人数据。前后端需共同遵守以下规则：
>
> - 所有端点强制 JWT 认证，禁止跨用户访问。
> - `journalText` 在传输层使用 HTTPS，在客户端不得缓存到磁盘（仅内存态）。
> - 心理评估结果仅供用户本人和 AI 建议引擎使用，不向第三方接口暴露。
> - 聊天记忆（`chat-memories`）由服务端管理生命周期，客户端不实现本地持久化。
> - 涉及自伤/危机关键词时，AI 回复应包含危机干预引导信息（服务端负责）。

### 4.1 心理档案

#### 获取我的心理档案

```
GET /health/psychology/profiles/my
认证：Bearer Token
```

**成功响应 `data`：** `PsyProfile` 对象，未初始化时为 `null`。

#### 初始化心理档案

```
POST /health/psychology/profiles/init
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `mbtiType` | `string?` | 否 | 如 `"INTJ"` |
| `enneagramType` | `string?` | 否 | 如 `"Type 5"` |
| `baselineStressLevel` | `int?` | 否 | 0-10 |

> 该接口为 upsert 语义。所有字段均可选，传入空对象 `{}` 也合法。

**成功响应 `data`：** `true`

**PsyProfile 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `int?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `mbtiType` | `string?` | MBTI 类型 |
| `enneagramType` | `string?` | 九型人格 |
| `baselineStressLevel` | `int?` | 压力基线 (0-10) |
| `createdAt` | `datetime?` | 创建时间 |
| `updatedAt` | `datetime?` | 更新时间 |

### 4.2 每日心情

#### 记录心情

```
POST /health/psychology/daily-moods
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `moodScore` | `int` | 是 | 1-10，1 = 极差，10 = 极好 |
| `primaryEmotion` | `string?` | 否 | 主要情绪描述 |
| `journalText` | `string?` | 否 | 日记内容（敏感字段，见隐私声明） |

**成功响应 `data`：** 创建后的 `DailyMood` 对象。

#### 获取我的心情记录

```
GET /health/psychology/daily-moods/my
认证：Bearer Token
```

#### 获取最新心情

```
GET /health/psychology/daily-moods/latest
认证：Bearer Token
```

**成功响应 `data`：** 单个 `DailyMood`，无数据时为 `null`。

#### 按日期范围查询

```
GET /health/psychology/daily-moods/range?startDate=2026-04-01&endDate=2026-04-30
认证：Bearer Token
```

**成功响应 `data`：** `[DailyMood]`

**DailyMood 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `moodScore` | `int` | 心情分数 (1-10) |
| `primaryEmotion` | `string?` | 主要情绪 |
| `journalText` | `string?` | 日记文本 |
| `recordDate` | `date?` | 记录日期 |
| `createdAt` | `datetime?` | 创建时间 |

### 4.3 心理评估

#### 创建评估

```
POST /health/psychology/assessments
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `scaleName` | `string` | 是 | 量表名称，见枚举约定 |
| `totalScore` | `int` | 是 | 总分 |
| `severityLevel` | `string?` | 否 | 严重程度，见枚举约定 |
| `resultAnalysis` | `string?` | 否 | 结果分析文本 |

**成功响应 `data`：** 创建后的 `PsyAssessment` 对象。

#### 获取我的评估记录

```
GET /health/psychology/assessments/my?scaleName=
认证：Bearer Token
查询参数：scaleName — 可选，按量表筛选
```

#### 获取最新评估

```
GET /health/psychology/assessments/latest
认证：Bearer Token
```

**成功响应 `data`：** 单个 `PsyAssessment`，无数据时为 `null`。

**PsyAssessment 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `scaleName` | `string` | 量表名称 |
| `totalScore` | `int` | 总分 |
| `severityLevel` | `string?` | 严重程度 |
| `resultAnalysis` | `string?` | 分析结果 |
| `createdAt` | `datetime?` | 创建时间 |

### 4.4 聊天记忆

#### 创建聊天记忆

```
POST /health/psychology/chat-memories
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `role` | `string` | 是 | `"user"` / `"assistant"` / `"system"` |
| `content` | `string` | 是 | 消息内容 |
| `emotionTags` | `string?` | 否 | 情绪标签 |

#### 获取我的聊天记忆

```
GET /health/psychology/chat-memories/my?role=
认证：Bearer Token
查询参数：role — 可选，按角色筛选
```

#### 获取最近聊天记忆

```
GET /health/psychology/chat-memories/recent?limit=
认证：Bearer Token
查询参数：limit — 可选，默认 10
```

**成功响应 `data`：** `[ChatMessage]`

**ChatMessage 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `int?` | 记录 ID |
| `userId` | `int?` | 用户 ID |
| `role` | `string` | 角色：user/assistant/system |
| `content` | `string` | 消息内容 |
| `emotionTags` | `string?` | 情绪标签 |
| `createdAt` | `datetime?` | 创建时间 |

---

## 5. AI Agent 模块

### 5.1 AI 建议记录

```
GET /health/agent/advice-records/my?agentType=&activeOnly=
认证：Bearer Token
查询参数：agentType — 可选；activeOnly — 可选，传 "true" 仅返回未过期建议
```

**成功响应 `data`：** `[AdviceRecord]`

**AdviceRecord 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `agentType` | `string` | Agent 类型 |
| `adviceType` | `string?` | 建议类型 |
| `title` | `string?` | 标题 |
| `content` | `string?` | 建议内容 |
| `sourceSummary` | `string?` | 来源摘要 |
| `priorityLevel` | `string?` | 优先级 |
| `status` | `string?` | 状态 |
| `validUntil` | `date?` | 有效期至 |
| `createdAt` | `datetime?` | 创建时间 |
| `updatedAt` | `datetime?` | 更新时间 |

### 5.2 跟踪计划

```
GET /health/agent/followup-plans/my?activeOnly=
认证：Bearer Token
查询参数：activeOnly — 可选，传 "true" 仅返回进行中的计划
```

**成功响应 `data`：** `[FollowupPlan]`

**FollowupPlan 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `planType` | `string?` | 计划类型 |
| `title` | `string?` | 标题 |
| `planJson` | `string?` | 计划详情 JSON |
| `goalSummary` | `string?` | 目标摘要 |
| `relatedAdviceId` | `long?` | 关联建议 ID |
| `status` | `string?` | 状态 |
| `startDate` | `date?` | 开始日期 |
| `endDate` | `date?` | 结束日期 |
| `createdAt` | `datetime?` | 创建时间 |
| `updatedAt` | `datetime?` | 更新时间 |

### 5.3 打卡记录

#### 创建打卡

```
POST /health/agent/checkins
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `adviceRecordId` | `long?` | 否 | 关联建议 ID |
| `followupPlanId` | `long?` | 否 | 关联计划 ID |
| `checkinDate` | `date` | 是 | `yyyy-MM-dd` |
| `completionStatus` | `string?` | 否 | 见枚举约定 |
| `adherenceScore` | `int?` | 否 | 遵从度评分 (0-10) |
| `effectScore` | `int?` | 否 | 效果评分 (0-10) |
| `userFeedback` | `string?` | 否 | 用户反馈 |
| `blockerReason` | `string?` | 否 | 阻碍原因 |

#### 获取我的打卡记录

```
GET /health/agent/checkins/my?followupPlanId=
认证：Bearer Token
查询参数：followupPlanId — 可选，按计划筛选
```

**成功响应 `data`：** `[Checkin]`

**Checkin 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `adviceRecordId` | `long?` | 关联建议 ID |
| `followupPlanId` | `long?` | 关联计划 ID |
| `checkinDate` | `date` | 打卡日期 |
| `completionStatus` | `string?` | 完成状态 |
| `adherenceScore` | `int?` | 遵从度 (0-10) |
| `effectScore` | `int?` | 效果 (0-10) |
| `userFeedback` | `string?` | 反馈 |
| `blockerReason` | `string?` | 阻碍原因 |
| `createdAt` | `datetime?` | 创建时间 |
| `updatedAt` | `datetime?` | 更新时间 |

### 5.4 用户偏好

#### 获取我的偏好

```
GET /health/agent/user-preferences/my
认证：Bearer Token
```

#### 保存偏好

```
POST /health/agent/user-preferences
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `preferredDietStyle` | `string?` | 否 | 饮食风格偏好 |
| `dislikedFoods` | `string?` | 否 | 忌口食物 |
| `preferredExerciseTypes` | `string?` | 否 | 偏好运动类型 |
| `preferredSupportStyle` | `string?` | 否 | 支持方式偏好 |
| `routinePattern` | `string?` | 否 | 作息模式 |
| `motivationTags` | `string?` | 否 | 动力标签 |
| `habitProfile` | `json?` | 否 | 习惯画像 |

**UserPreferences 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `preferredDietStyle` | `string?` | 饮食风格 |
| `dislikedFoods` | `string?` | 忌口 |
| `preferredExerciseTypes` | `string?` | 偏好运动 |
| `preferredSupportStyle` | `string?` | 支持方式 |
| `routinePattern` | `string?` | 作息 |
| `motivationTags` | `string?` | 动力标签 |
| `habitProfile` | `json?` | 习惯画像 |
| `createdAt` | `datetime?` | 创建时间 |
| `updatedAt` | `datetime?` | 更新时间 |

---

## 附录 A：数据模型与数据库对照

| 模型 | 文件 | 数据库表 |
|------|------|----------|
| AuthUser | `shared/models/auth_user.dart` | `sys_user` |
| DailySummary | `shared/models/daily_summary.dart` | `healthy_daily_summaries` |
| HealthActivity | `shared/models/health_activity.dart` | `healthy_activities` |
| DietLog | `shared/models/diet_log.dart` | `healthy_diet_logs` |
| WeightLog | `shared/models/weight_log.dart` | `healthy_weight_logs` |
| UserProfile | `shared/models/user_profile.dart` | `healthy_user_profiles` |
| DailyMood | `shared/models/daily_mood.dart` | `health_psy_daily_moods` |
| PsyProfile | `shared/models/psy_profile.dart` | `health_psy_profiles` |
| PsyAssessment | `shared/models/psy_assessment.dart` | `health_psy_assessments` |
| ChatMessage | `shared/models/chat_message.dart` | `health_psy_chat_memories` |
| AdviceRecord | `shared/models/agent_models.dart` | `health_agent_advice_records` |
| FollowupPlan | `shared/models/agent_models.dart` | `health_agent_followup_plans` |
| Checkin | `shared/models/agent_models.dart` | `health_agent_checkins` |
| UserPreferences | `shared/models/user_preferences.dart` | `health_agent_user_preferences` |

## 附录 B：App 端实现状态

| 接口 | Repository | Provider | UI |
|------|------------|----------|-----|
| `POST /auth/login` | ✅ | ✅ | ✅ |
| `GET /auth/profile` | ✅ | ✅ | ✅ |
| `GET /health/user-profiles/my` | ✅ | ✅ | ✅ |
| `POST /health/user-profiles/init` | ✅ | ✅ | ✅ |
| `GET /health/daily-summaries/**` | ✅ | ✅ | ✅ |
| `POST /health/activities` | ✅ | ✅ | ✅ |
| `GET /health/activities/my` | ✅ | ✅ | ✅ |
| `POST /health/diet-logs` | ✅ | ✅ | ✅ |
| `GET /health/diet-logs/my` | ✅ | ✅ | ✅ |
| `POST /health/weight-logs` | ✅ | ✅ | ✅ |
| `GET /health/weight-logs/my` | ✅ | ✅ | ✅ |
| `GET /health/weight-logs/latest` | ✅ | ✅ | ✅ |
| `POST /health/chat/stream` (SSE) | ✅ | ✅ | ✅ |
| `GET /health/psychology/profiles/my` | ✅ | ✅ | ✅ |
| `POST /health/psychology/profiles/init` | ✅ | ✅ | ✅ |
| `POST /health/psychology/daily-moods` | ✅ | ✅ | ✅ |
| `GET /health/psychology/daily-moods/my` | ✅ | ✅ | ✅ |
| `GET /health/psychology/daily-moods/latest` | ✅ | ✅ | ✅ |
| `POST /health/psychology/assessments` | ✅ | ✅ | ✅ |
| `GET /health/psychology/assessments/my` | ✅ | ✅ | ✅ |
| `GET /health/psychology/assessments/latest` | ✅ | ✅ | ✅ |
| `POST /health/psychology/chat-memories` | ✅ | ✅ | ✅ |
| `GET /health/psychology/chat-memories/my` | ✅ | ✅ | ✅ |
| `GET /health/agent/advice-records/my` | ✅ | ✅ | ✅ |
| `GET /health/agent/followup-plans/my` | ✅ | ✅ | ✅ |
| `POST /health/agent/checkins` | ✅ | ✅ | ✅ |
| `GET /health/agent/checkins/my` | ✅ | ✅ | ✅ |
| `GET /health/agent/user-preferences/my` | ✅ | ✅ | ✅ |
| `POST /health/agent/user-preferences` | ✅ | ✅ | ✅ |


---

## 6. 睡眠追踪模块（新增）

> **状态：** 待后端开发。前端 App 已实现。

### 6.1 创建睡眠记录

```
POST /health/sleep-logs
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `sleepDate` | `date` | 是 | 入睡日期 `yyyy-MM-dd` |
| `bedTime` | `datetime?` | 否 | 上床时间 |
| `wakeTime` | `datetime?` | 否 | 起床时间 |
| `durationMinutes` | `int?` | 否 | 总睡眠时长（分钟） |
| `qualityScore` | `int?` | 否 | 质量评分 (1-10) |
| `deepSleepMinutes` | `int?` | 否 | 深睡时长 |
| `lightSleepMinutes` | `int?` | 否 | 浅睡时长 |
| `awakeMinutes` | `int?` | 否 | 清醒时长 |
| `notes` | `string?` | 否 | 备注 |

**成功响应 `data`：** 创建后的 `SleepLog` 对象。

### 6.2 获取我的睡眠记录

```
GET /health/sleep-logs/my
认证：Bearer Token
```

**成功响应 `data`：** `[SleepLog]`

### 6.3 获取最新睡眠记录

```
GET /health/sleep-logs/latest
认证：Bearer Token
```

**成功响应 `data`：** 单个 `SleepLog`，无数据时为 `null`。

### 6.4 按日期范围查询

```
GET /health/sleep-logs/range?startDate=2026-04-01&endDate=2026-04-30
认证：Bearer Token
```

**成功响应 `data`：** `[SleepLog]`

**SleepLog 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `sleepDate` | `date` | 睡眠日期 |
| `bedTime` | `datetime?` | 上床时间 |
| `wakeTime` | `datetime?` | 起床时间 |
| `durationMinutes` | `int?` | 总时长（分钟） |
| `qualityScore` | `int?` | 质量评分 (1-10) |
| `deepSleepMinutes` | `int?` | 深睡时长 |
| `lightSleepMinutes` | `int?` | 浅睡时长 |
| `awakeMinutes` | `int?` | 清醒时长 |
| `notes` | `string?` | 备注 |
| `createdAt` | `datetime?` | 创建时间 |

---

## 7. 饮水追踪模块（新增）

> **状态：** 待后端开发。前端 App 已实现。

### 7.1 创建饮水记录

```
POST /health/water-logs
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `recordTime` | `datetime` | 是 | 记录时间 |
| `amountMl` | `int` | 是 | 饮水量（毫升） |
| `drinkType` | `string?` | 否 | 类型：`water`/`tea`/`coffee`/`other` |

**成功响应 `data`：** 创建后的 `WaterLog` 对象。

### 7.2 按日期查询饮水记录

```
GET /health/water-logs/date/{date}
认证：Bearer Token
路径参数：date — yyyy-MM-dd
```

**成功响应 `data`：** `[WaterLog]`

**WaterLog 结构：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `long?` | 记录 ID |
| `userId` | `int` | 用户 ID |
| `recordTime` | `datetime` | 记录时间 |
| `amountMl` | `int` | 饮水量（ml） |
| `drinkType` | `string?` | 饮品类型 |
| `createdAt` | `datetime?` | 创建时间 |

---

## 8. 健康目标模块（新增端点）

> **状态：** 后端已有 `GET /health/goals/my`。以下为需要新增的端点。

### 8.1 创建健康目标

```
POST /health/goals
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `goalType` | `string` | 是 | 见枚举约定 |
| `targetValue` | `decimal` | 是 | 目标值 |
| `deadline` | `date?` | 否 | 截止日期 |

**成功响应 `data`：** 创建后的 `HealthGoal` 对象。

### 8.2 更新健康目标

```
PUT /health/goals/{id}
认证：Bearer Token
```

**请求 Body：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `status` | `string?` | 否 | active/achieved/abandoned |
| `targetValue` | `decimal?` | 否 | 更新目标值 |
| `deadline` | `date?` | 否 | 更新截止日期 |

**成功响应 `data`：** 更新后的 `HealthGoal` 对象。

---

## 附录 C：新增数据模型与数据库对照

| 模型 | 文件 | 数据库表 | 状态 |
|------|------|----------|------|
| HealthGoal | `shared/models/health_goal.dart` | `healthy_goals` | ✅ 已有 |
| SleepLog | `shared/models/sleep_log.dart` | `health_sleep_logs` | ✅ 已建 |
| WaterLog | `shared/models/water_log.dart` | `health_water_logs` | ✅ 已建 |

## 附录 D：新增 App 端实现状态

| 接口 | Repository | Provider | UI | 后端 |
|------|------------|----------|-----|------|
| `GET /health/goals/my` | ✅ | ✅ | ✅ | ✅ |
| `POST /health/goals` | ✅ | ✅ | ✅ | ✅ |
| `PUT /health/goals/{id}` | ✅ | ✅ | ✅ | ✅ |
| `POST /health/sleep-logs` | ✅ | ✅ | ✅ | ✅ |
| `GET /health/sleep-logs/my` | ✅ | ✅ | ✅ | ✅ |
| `GET /health/sleep-logs/latest` | ✅ | ✅ | ✅ | ✅ |
| `GET /health/sleep-logs/range` | ✅ | ✅ | ✅ | ✅ |
| `POST /health/water-logs` | ✅ | ✅ | ✅ | ✅ |
| `GET /health/water-logs/date/{date}` | ✅ | ✅ | ✅ | ✅ |


---

## 9. AI 综合分析模块（新增）

> **状态：** 后端已实现。前端 App 已实现。
> 调用链：App → 后端聚合用户数据 → Python Agent (LifeHubAI) → 持久化为 advice records

### 9.1 触发综合分析

```
POST /health/agent/analyze?agentType={type}
认证：Bearer Token
```

**查询参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `agentType` | `string` | 否 | 分析维度，默认 `general`。可选：`diet`/`exercise`/`psychology`/`sleep`/`general` |

**流程说明：**

1. 后端从数据库收集用户最近 7 天的运动、饮食、体重、心情数据，构造摘要文本
2. 后端基于 `agentType` 构造 prompt，调用 Python Agent (`LifeHubAI`) 的 SSE 流式接口
3. 解析 Agent 返回的 `record_payload.advice_list` 或 `state.final_response`
4. 持久化为 `advice_records` 表记录（自动设置 7 天有效期）
5. 失败时返回降级的通用建议

**成功响应 `data`：** `[AdviceRecord]` —— 新生成的建议列表（参见 5.1）

**示例响应：**

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 101,
      "userId": 1,
      "agentType": "diet",
      "adviceType": "auto_generated",
      "title": "增加蔬菜摄入",
      "content": "近期饮食记录中蔬菜比例偏低...",
      "priorityLevel": "medium",
      "status": "active",
      "validUntil": "2026-05-28",
      "sourceSummary": "基于最近 7 天数据自动生成",
      "createdAt": "2026-05-21T10:00:00"
    }
  ],
  "success": true
}
```


---

## 10. 智能健康报告（新增）

> **状态：** 后端已实现。前端 App 已实现。
> 调用链：App → 后端聚合 7/30 天数据 + 计算评分 → AI Agent 生成解读 → 返回完整报告

### 10.1 生成智能报告

```
GET /health/agent/reports?period={weekly|monthly}
认证：Bearer Token
```

**查询参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `period` | `string` | 否 | `weekly`（默认） / `monthly` |

**流程说明：**

1. 后端聚合用户当周/月数据（运动/饮食/体重/心情/睡眠）
2. 同时聚合上个周期数据用于趋势对比
3. 计算综合评分 + 分项评分（运动/饮食/睡眠/心理/体重 0-100）
4. 调用 Python Agent 生成自然语言解读 + 关键洞察 + 建议
5. AI 失败时降级到模板化文本

**成功响应 `data`：** `HealthReport`

```json
{
  "period": "weekly",
  "startDate": "2026-05-14",
  "endDate": "2026-05-21",
  "overallScore": 78,
  "scores": {
    "exercise": 82, "diet": 70, "sleep": 75, "psychology": 85, "weight": 80
  },
  "metrics": {
    "totalSteps": 56000,
    "totalActiveMinutes": 180,
    "activityCount": 5,
    "dietLogCount": 18,
    "avgCaloriesIntake": 1850,
    "currentWeight": 68.5,
    "weightChange": -0.3,
    "moodLogCount": 6,
    "avgMoodScore": 7.5,
    "avgSleepHours": 7.2,
    "avgSleepQuality": 8.0
  },
  "aiNarrative": "本周状态不错！运动方面表现优秀...",
  "keyInsights": [
    "本周运动频次较上周提升 20%",
    "饮食记录充实，营养均衡",
    "心情整体稳定向上"
  ],
  "recommendations": [
    "继续保持每周 3 次以上有氧运动",
    "增加蔬果摄入比例",
    "睡前 30 分钟避免使用电子设备"
  ],
  "trends": {
    "stepsTrend": "up",
    "stepsChangePercent": 15.3,
    "moodTrend": "up",
    "moodChangePercent": 8.2,
    "weightTrend": "down",
    "weightChangeKg": -0.3
  }
}
```


---

## 11. 财务 AI 模块（新增）

> **状态：** 后端已实现。uni-app 财务小程序已实现。
> 调用链：财务小程序 → 后端聚合财务数据 → Python Agent → 返回结构化建议

### 11.1 财务 AI 流式聊天

```
POST /app/fin/ai/chat/stream
认证：Bearer Token
Content-Type: application/json
Accept: text/event-stream
```

**请求 Body：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `message` | `string` | 是 | 用户问题 |
| `bookId` | `long?` | 否 | 账本 ID |

**响应：** SSE 流，事件类型同 3.1 (start/delta/complete/error)

> 后端会自动注入用户当前财务上下文（资产总览、本月报表、Top 5 支出分类）作为 prompt 增强

### 11.2 月度财务智能分析

```
POST /app/fin/ai/analyze?year=&month=&bookId=
认证：Bearer Token
```

**查询参数：** `year`, `month`, `bookId` 均可选（默认当前月）

**成功响应 `data`：** `FinanceInsightReport`

```json
{
  "period": "2026-05",
  "healthScore": 85,
  "narrative": "本月财务表现良好，储蓄率达到 23%...",
  "keyFindings": ["发现1", "发现2", "发现3"],
  "recommendations": ["建议1", "建议2", "建议3"],
  "warnings": ["注意事项"],
  "budgetSuggestion": "下月可保持 8000 元支出预算"
}
```

### 11.3 支出异常检测

```
GET /app/fin/ai/anomalies?bookId=
认证：Bearer Token
```

**成功响应 `data`：** 与 11.2 同结构的 `FinanceInsightReport`，重点输出 `warnings` 字段
