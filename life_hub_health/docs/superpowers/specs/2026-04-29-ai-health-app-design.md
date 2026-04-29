# AI 健康管理 App 设计文档

**日期：** 2026-04-29
**版本：** 2.1
**状态：** 设计完成，待实施
**更新：** 基于 v2.0 审阅反馈，补充 SSE 方案、API 错误格式、离线策略说明

---

## 1. 项目概述

### 1.1 项目目标
开发一个基于 AI 的健康管理应用，帮助用户追踪健康数据、获取个性化健康建议、管理医疗记录。

### 1.2 目标用户
- **普通大众** - 追踪日常健康数据（运动、饮食、睡眠）
- **健身爱好者** - 需要专业训练计划和营养建议
- **慢性病患者** - 管理特定健康状况（如糖尿病、高血压）

### 1.3 核心功能
- **健康数据追踪** (核心) - 记录运动、饮食、睡眠、体重等日常数据
- **AI 健康建议** (核心) - 基于用户数据提供个性化健康建议
- **训练计划生成** - 为健身爱好者生成定制训练计划
- **营养管理** - 饮食记录、卡路里计算、营养建议
- **慢性病管理** - 血糖/血压追踪、用药提醒、健康预警
- **医疗记录** - 存储体检报告、病历、过敏信息等
- **心理健康** - 情绪追踪、心理评估、AI心理陪伴

### 1.4 AI 健康建议形式
- **聊天机器人** - 用户可以随时与 AI 对话，询问健康问题
- **每日推送通知** - AI 分析数据后主动推送个性化建议
- **健康仪表板** - 在主页展示 AI 分析结果和建议卡片
- **报告生成** - 定期生成健康分析报告（周报/月报）

---

## 2. 技术栈

### 2.1 前端
- **框架：** Flutter (优先 Android)
- **状态管理：** Riverpod
- **路由：** GoRouter
- **网络请求：** Dio
- **SSE 客户端：** eventsource（用于 AI 聊天流式响应）
- **本地存储：** Hive + flutter_secure_storage
- **图表：** fl_chart

### 2.2 后端（已有实现）
- **框架：** Spring Boot 3.5.9 + Java 17
- **Web框架：** Spring WebFlux (响应式编程)
- **ORM：** MyBatis-Plus 3.5.15
- **数据库：** PostgreSQL + pgvector (向量数据库)
- **缓存：** Redis
- **认证：** JWT (jjwt 0.12.6)
- **AI集成：** Spring AI (智谱AI、DeepSeek)
- **服务注册：** Nacos
- **对象存储：** MinIO
- **API风格：** RESTful API + SSE (Server-Sent Events)

### 2.3 数据存储
- **云端存储** - PostgreSQL + pgvector (支持向量检索)
- **本地缓存** - Hive 缓存常用数据，支持离线使用
- **实时同步** - 数据变更立即同步到云端

### 2.4 离线策略说明

**MVP 阶段（暂不实现完整离线支持）：**
- 本地仅做读取缓存，加速数据加载
- 写入操作必须在线完成
- 网络不可用时显示友好提示，引导用户稍后重试

**后续版本规划：**
- 离线优先策略：本地写入优先，后台同步
- 冲突解决：基于时间戳的 Last-Write-Wins 策略
- 同步队列：网络恢复后自动重试失败的写入操作

**架构扩展性：**
- Repository 模式已预留本地/远程数据源切换接口
- 数据模型已支持 JSON 序列化，便于本地存储

---

## 3. 应用架构

### 3.1 整体架构（三层架构）

```
┌─────────────────────────────────────┐
│       Presentation Layer (UI)       │
│   Screens, Widgets, Providers       │
├─────────────────────────────────────┤
│       Domain Layer (Business)       │
│   Models, Repositories, Use Cases   │
├─────────────────────────────────────┤
│         Data Layer                  │
│   API Services, Local DB, Repos     │
└─────────────────────────────────────┘
```

### 3.2 项目目录结构

```
lib/
├── app/
│   ├── app.dart                    # 应用入口
│   └── router.dart                 # 路由配置
├── core/
│   ├── constants/                  # 常量定义
│   ├── theme/                      # 主题配置
│   │   ├── app_theme.dart
│   │   └── colors.dart
│   ├── utils/                      # 工具类
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   └── widgets/                    # 通用组件
│       ├── loading_widget.dart
│       └── error_widget.dart
├── features/
│   ├── auth/                       # 认证模块
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── home/                       # 首页模块
│   ├── health_data/                # 健康数据模块
│   ├── ai_chat/                    # AI 聊天模块
│   ├── psychology/                 # 心理健康模块
│   └── profile/                    # 个人中心模块
├── shared/
│   ├── models/                     # 共享数据模型
│   ├── services/                   # 共享服务
│   │   ├── api_service.dart
│   │   ├── local_storage_service.dart
│   │   └── sync_service.dart
│   └── providers/                  # 共享 Provider
└── main.dart
```

---

## 4. 数据库表结构（后端已有）

### 4.1 健康数据表

**1. healthy_user_profiles - 用户健康档案**
```sql
CREATE TABLE healthy_user_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL,
    birth_date DATE,
    gender VARCHAR(10),
    height_cm NUMERIC(5, 2),
    baseline_weight_kg NUMERIC(5, 2),
    target_weight_kg NUMERIC(5, 2),
    health_profile_embedding VECTOR(2048),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**2. healthy_daily_summaries - 每日活动汇总**
```sql
CREATE TABLE healthy_daily_summaries (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    record_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_steps INTEGER NOT NULL DEFAULT 0,
    active_calories_kcal NUMERIC(7, 2) DEFAULT 0.00,
    resting_calories_kcal NUMERIC(7, 2) DEFAULT 0.00,
    total_distance_meters NUMERIC(8, 2) DEFAULT 0.00,
    active_minutes INTEGER DEFAULT 0,
    daily_context_embedding VECTOR(1024),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, record_date)
);
```

**3. healthy_weight_logs - 体重记录**
```sql
CREATE TABLE healthy_weight_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    record_date DATE NOT NULL DEFAULT CURRENT_DATE,
    weight_kg NUMERIC(5, 2) NOT NULL,
    body_fat_percentage NUMERIC(5, 2),
    bmi NUMERIC(5, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**4. healthy_activities - 运动记录**
```sql
CREATE TABLE healthy_activities (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER NOT NULL,
    calories_burned NUMERIC(7, 2),
    description TEXT,
    activity_embedding VECTOR(512),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**5. healthy_diet_logs - 饮食记录**
```sql
CREATE TABLE healthy_diet_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    meal_time TIMESTAMP WITH TIME ZONE NOT NULL,
    meal_type VARCHAR(20) NOT NULL,
    food_items TEXT NOT NULL,
    total_calories NUMERIC(7, 2),
    protein_g NUMERIC(6, 2),
    carbs_g NUMERIC(6, 2),
    fat_g NUMERIC(6, 2),
    food_embedding VECTOR(256),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**6. healthy_goals - 健康目标**
```sql
CREATE TABLE healthy_goals (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    goal_type VARCHAR(50) NOT NULL,
    target_value NUMERIC(10, 2),
    deadline DATE,
    status VARCHAR(20) DEFAULT 'active',
    goal_embedding VECTOR(1024),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 4.2 心理健康表

**7. health_psy_profiles - 心理档案**
```sql
CREATE TABLE health_psy_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL,
    mbti_type VARCHAR(10),
    enneagram_type VARCHAR(10),
    baseline_stress_level INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**8. health_psy_daily_moods - 每日心情记录**
```sql
CREATE TABLE health_psy_daily_moods (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    mood_score INT NOT NULL,
    primary_emotion VARCHAR(50),
    journal_text TEXT,
    record_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**9. health_psy_assessments - 心理评估**
```sql
CREATE TABLE health_psy_assessments (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    scale_name VARCHAR(100) NOT NULL,
    total_score INT NOT NULL,
    severity_level VARCHAR(50),
    result_analysis TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**10. health_psy_chat_memories - 心理聊天记录**
```sql
CREATE TABLE health_psy_chat_memories (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    emotion_tags VARCHAR(100),
    content_vector VECTOR(1024),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**11. health_psy_knowledge_base - 心理知识库**
```sql
CREATE TABLE health_psy_knowledge_base (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    content_vector VECTOR(1024),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 4.3 AI Agent表

**12. health_agent_advice_records - AI建议记录**
```sql
CREATE TABLE health_agent_advice_records (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    agent_type VARCHAR(64) NOT NULL,
    advice_type VARCHAR(64) NOT NULL,
    title VARCHAR(255),
    content TEXT NOT NULL,
    source_summary TEXT,
    source_snapshot JSONB,
    priority_level VARCHAR(32),
    status VARCHAR(32) DEFAULT 'active',
    valid_until DATE,
    advice_vector VECTOR(1024),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

**13. health_agent_followup_plans - AI跟踪计划**
```sql
CREATE TABLE health_agent_followup_plans (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    plan_type VARCHAR(64) NOT NULL,
    title VARCHAR(255) NOT NULL,
    plan_json JSONB NOT NULL,
    goal_summary TEXT,
    related_advice_id BIGINT,
    status VARCHAR(32) DEFAULT 'active',
    start_date DATE,
    end_date DATE,
    followup_vector VECTOR(1024),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

**14. health_agent_checkins - AI打卡记录**
```sql
CREATE TABLE health_agent_checkins (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    advice_record_id BIGINT,
    followup_plan_id BIGINT,
    checkin_date DATE NOT NULL,
    completion_status VARCHAR(32) DEFAULT 'pending',
    adherence_score INTEGER,
    effect_score INTEGER,
    user_feedback TEXT,
    blocker_reason TEXT,
    checkin_vector VECTOR(1024),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

**15. health_agent_user_preferences - 用户偏好**
```sql
CREATE TABLE health_agent_user_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    preferred_diet_style VARCHAR(64),
    disliked_foods TEXT,
    preferred_exercise_types TEXT,
    preferred_support_style VARCHAR(64),
    routine_pattern TEXT,
    motivation_tags TEXT,
    habit_profile JSONB,
    preference_vector VECTOR(1024),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

**16. health_risk_flags - 健康风险标记**
```sql
CREATE TABLE health_risk_flags (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    risk_type VARCHAR(100) NOT NULL,
    level VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

---

## 5. API 契约（基于后端实现）

**API 范围说明：**
- ✅ MVP：MVP 阶段必须实现
- 🔜 后续版本：MVP 后逐步实现

### 5.0 统一响应格式

**成功响应：**
```json
{
  "code": 200,
  "message": "success",
  "data": { ... },
  "success": true
}
```

**错误响应：**
```json
{
  "code": 400,
  "message": "错误描述",
  "data": null,
  "success": false
}
```

**错误码定义：**
| HTTP 状态码 | code | 说明 | 前端处理 |
|-------------|------|------|----------|
| 400 | 400 | 请求参数错误 | 显示错误信息，提示用户修改 |
| 401 | 401 | 未认证/Token 过期 | 尝试刷新 Token，失败则跳转登录 |
| 403 | 403 | 无权限访问 | 显示无权限提示 |
| 404 | 404 | 资源不存在 | 显示资源不存在提示 |
| 500 | 500 | 服务器内部错误 | 显示通用错误提示，可重试 |

**分页响应格式（如需要）：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [ ... ],
    "total": 100,
    "page": 1,
    "pageSize": 20
  },
  "success": true
}
```

### 5.1 认证 API

**登录** ✅ MVP
```dart
POST /auth/login
Request:
  username: string (required, 3-50字符, 只能包含字母数字下划线)
  password: string (required, 6-100字符)
Response:
  200:
    code: 200
    message: "success"
    data:
      token: string
      user:
        id: long
        username: string
        nickname: string
        avatar: string
    success: true
```

**微信登录** ✅ MVP
```dart
POST /auth/wx-login
Request:
  code: string (required)
Response:
  200:
    code: 200
    data:
      token: string
      user: AuthUserProfile
```

**获取用户信息** ✅ MVP
```dart
GET /auth/profile
Headers:
  Authorization: Bearer {token}
Response:
  200:
    code: 200
    data:
      id: long
      username: string
      nickname: string
      avatar: string
```

**刷新Token** ✅ MVP
```dart
POST /auth/refresh
Request:
  refreshToken: string
Response:
  200:
    code: 200
    data:
      token: string
      refreshToken: string
      expiresIn: long
```

### 5.2 健康数据 API

**用户健康档案** ✅ MVP
```dart
// 获取我的健康档案
GET /health/user-profiles/my
Response:
  200:
    code: 200
    data:
      id: long
      userId: long
      birthDate: date
      gender: string
      heightCm: decimal
      baselineWeightKg: decimal
      targetWeightKg: decimal

// 初始化或更新健康档案
POST /health/user-profiles/init
Request:
  birthDate: date
  gender: string
  heightCm: decimal
  baselineWeightKg: decimal
  targetWeightKg: decimal
Response:
  200:
    code: 200
    data: true
```

**每日活动汇总** ✅ MVP
```dart
// 获取我的每日汇总列表
GET /health/daily-summaries/my
Response:
  200:
    code: 200
    data: [DailySummary]

// 根据日期查询
GET /health/daily-summaries/date/{recordDate}
Response:
  200:
    code: 200
    data:
      id: long
      userId: long
      recordDate: date
      totalSteps: int
      activeCaloriesKcal: decimal
      restingCaloriesKcal: decimal
      totalDistanceMeters: decimal
      activeMinutes: int

// 根据日期范围查询
GET /health/daily-summaries/range?startDate=2026-01-01&endDate=2026-01-31
Response:
  200:
    code: 200
    data: [DailySummary]
```

**体重记录** ✅ MVP
```dart
// 新增体重记录
POST /health/weight-logs
Request:
  recordDate: date
  weightKg: decimal (required)
  bodyFatPercentage: decimal
  bmi: decimal
Response:
  200:
    code: 200
    data: true

// 获取我的体重记录列表
GET /health/weight-logs/my
Response:
  200:
    code: 200
    data: [WeightLog]

// 获取最新体重记录
GET /health/weight-logs/latest
Response:
  200:
    code: 200
    data:
      id: long
      userId: long
      recordDate: date
      weightKg: decimal
      bodyFatPercentage: decimal
      bmi: decimal

// 根据日期范围查询
GET /health/weight-logs/range?startDate=2026-01-01&endDate=2026-01-31
Response:
  200:
    code: 200
    data: [WeightLog]
```

**运动记录** ✅ MVP
```dart
// 新增运动记录
POST /health/activities
Request:
  activityType: string (required) // running, swimming, weightlifting等
  startTime: datetime
  durationMinutes: int (required)
  caloriesBurned: decimal
  description: string
Response:
  200:
    code: 200
    data: true

// 获取我的运动记录列表
GET /health/activities/my
Query:
  activityType: string (optional)
Response:
  200:
    code: 200
    data: [Activity]
```

**饮食记录** ✅ MVP
```dart
// 新增饮食记录
POST /health/diet-logs
Request:
  mealTime: datetime (required)
  mealType: string (required) // breakfast, lunch, dinner, snack
  foodItems: string (required)
  totalCalories: decimal
  proteinG: decimal
  carbsG: decimal
  fatG: decimal
Response:
  200:
    code: 200
    data: true

// 获取我的饮食记录列表
GET /health/diet-logs/my
Query:
  mealType: string (optional)
Response:
  200:
    code: 200
    data: [DietLog]

// 根据日期查询
GET /health/diet-logs/date/{date}
Response:
  200:
    code: 200
    data: [DietLog]
```

**健康目标** 🔜 后续版本
```dart
// 新增健康目标
POST /health/goals
Request:
  goalType: string (required) // weight_loss, step_goal, muscle_gain
  targetValue: decimal
  deadline: date
  status: string // active, achieved, abandoned
Response:
  200:
    code: 200
    data: true

// 获取我的健康目标列表
GET /health/goals/my
Query:
  status: string (optional)
  goalType: string (optional)
Response:
  200:
    code: 200
    data: [HealthGoal]
```

### 5.3 AI 聊天 API

**流式聊天** ✅ MVP
```dart
POST /health/chat/stream
Request:
  message: string (required)
  historyLimit: int (default: 10, max: 20)
  systemPrompt: string (optional)
  useAgent: bool (default: true)
  userIdForAgent: string (optional)
Response:
  SSE Stream:
    event: start
    data: {type: "start", content: "", done: false, timestamp: long}

    event: delta
    data: {type: "delta", content: "回复内容片段", done: false, timestamp: long}

    event: complete
    data: {type: "complete", content: "", done: true, timestamp: long}
```

**调用AI Agent** 🔜 后续版本
```dart
POST /health/chat/agent
Request:
  message: string (required)
  historyLimit: int (default: 10)
  useAgent: bool (default: true)
Response:
  200:
    code: 200
    data:
      state: map // Agent执行状态
      summary: map // 快速摘要
      record_payload: map // 结构化记录数据
```

**SSE 前端实现方案（使用 eventsource 包）：**

```dart
import 'package:eventsource/eventsource.dart';

class SseChatService {
  Future<Stream<SSEEvent>> streamChat({
    required String message,
    int historyLimit = 10,
    String? systemPrompt,
    bool useAgent = true,
  }) async {
    final uri = Uri.parse('$baseUrl/health/chat/stream');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'message': message,
      'historyLimit': historyLimit,
      'systemPrompt': systemPrompt,
      'useAgent': useAgent,
    });

    final eventSource = await EventSource.connect(
      uri.toString(),
      method: 'POST',
      headers: headers,
      body: body,
    );

    return eventSource.stream;
  }
}
```

**在 Provider 中使用：**
```dart
final chatStreamProvider = StreamProvider.family<ChatMessage, String>((ref, message) async* {
  final sseService = ref.read(sseChatServiceProvider);
  final stream = await sseService.streamChat(message: message);

  await for (final event in stream) {
    if (event.event == 'delta') {
      final data = jsonDecode(event.data!);
      yield ChatMessage(
        content: data['content'],
        isComplete: data['done'],
      );
    }
  }
});
```

**调用AI Agent**
```dart
POST /health/chat/agent
Request:
  message: string (required)
  historyLimit: int (default: 10)
  useAgent: bool (default: true)
Response:
  200:
    code: 200
    data:
      state: map // Agent执行状态
      summary: map // 快速摘要
      record_payload: map // 结构化记录数据
```

### 5.4 心理健康 API

**心理档案** ✅ MVP
```dart
// 获取我的心理档案
GET /health/psychology/profiles/my
Response:
  200:
    code: 200
    data:
      id: long
      userId: long
      mbtiType: string
      enneagramType: string
      baselineStressLevel: int

// 初始化或更新心理档案
POST /health/psychology/profiles/init
Request:
  mbtiType: string
  enneagramType: string
  baselineStressLevel: int
Response:
  200:
    code: 200
    data: true
```

**每日心情记录** ✅ MVP
```dart
// 新增心情记录
POST /health/psychology/daily-moods
Request:
  moodScore: int (required, 1-10)
  primaryEmotion: string
  journalText: string
  recordDate: date
Response:
  200:
    code: 200
    data: true

// 获取我的心情记录列表
GET /health/psychology/daily-moods/my
Response:
  200:
    code: 200
    data: [DailyMood]

// 获取最新心情记录
GET /health/psychology/daily-moods/latest
Response:
  200:
    code: 200
    data:
      id: long
      userId: long
      moodScore: int
      primaryEmotion: string
      journalText: string
      recordDate: date

// 根据日期范围查询
GET /health/psychology/daily-moods/range?startDate=2026-01-01&endDate=2026-01-31
Response:
  200:
    code: 200
    data: [DailyMood]
```

**心理评估** 🔜 后续版本
```dart
// 新增心理评估记录
POST /health/psychology/assessments
Request:
  scaleName: string (required) // PHQ-9, GAD-7等
  totalScore: int (required)
  severityLevel: string
  resultAnalysis: string
Response:
  200:
    code: 200
    data: true

// 获取我的心理评估记录列表
GET /health/psychology/assessments/my
Query:
  scaleName: string (optional)
Response:
  200:
    code: 200
    data: [PsyAssessment]

// 获取最新心理评估
GET /health/psychology/assessments/latest
Response:
  200:
    code: 200
    data: PsyAssessment
```

**心理聊天记录** ✅ MVP
```dart
// 新增聊天记录
POST /health/psychology/chat-memories
Request:
  role: string (required) // user, assistant, system
  content: string (required)
  emotionTags: string
Response:
  200:
    code: 200
    data: true

// 获取我的聊天记录列表
GET /health/psychology/chat-memories/my
Query:
  role: string (optional)
Response:
  200:
    code: 200
    data: [ChatMemory]

// 获取最近聊天记录
GET /health/psychology/chat-memories/recent?limit=10
Response:
  200:
    code: 200
    data: [ChatMemory]
```

### 5.5 AI Agent API

**AI建议记录** 🔜 后续版本
```dart
// 获取我的AI建议列表
GET /health/agent/advice-records/my
Query:
  agentType: string (optional) // health_manager, diet_agent, weight_trend_agent
  activeOnly: bool (optional)
Response:
  200:
    code: 200
    data: [AdviceRecord]
```

**AI跟踪计划** 🔜 后续版本
```dart
// 获取我的跟踪计划列表
GET /health/agent/followup-plans/my
Query:
  activeOnly: bool (optional)
Response:
  200:
    code: 200
    data: [FollowupPlan]
```

**AI打卡记录** 🔜 后续版本
```dart
// 新增打卡记录
POST /health/agent/checkins
Request:
  adviceRecordId: long
  followupPlanId: long
  checkinDate: date (required)
  completionStatus: string // pending, done, partial, missed
  adherenceScore: int (1-5)
  effectScore: int (1-5)
  userFeedback: string
  blockerReason: string
Response:
  200:
    code: 200
    data: true

// 获取我的打卡记录列表
GET /health/agent/checkins/my
Query:
  followupPlanId: long (optional)
Response:
  200:
    code: 200
    data: [Checkin]
```

**用户偏好** 🔜 后续版本
```dart
// 获取我的偏好设置
GET /health/agent/user-preferences/my
Response:
  200:
    code: 200
    data:
      id: long
      userId: long
      preferredDietStyle: string
      dislikedFoods: string
      preferredExerciseTypes: string
      preferredSupportStyle: string
      routinePattern: string
      motivationTags: string
      habitProfile: json

// 创建或更新偏好
POST /health/agent/user-preferences
Request:
  preferredDietStyle: string
  dislikedFoods: string
  preferredExerciseTypes: string
  preferredSupportStyle: string
  routinePattern: string
  motivationTags: string
  habitProfile: json
Response:
  200:
    code: 200
    data: true
```

---

## 6. Flutter数据模型（匹配后端）

### 6.1 命名规范

- **类名使用单数形式**：`UserProfile` 而非 `HealthyUserProfiles`
- **所有模型必须包含 `toJson()` 方法**：便于本地存储和 API 请求
- **使用 json_serializable 生成序列化代码**：减少手写错误

### 6.2 用户健康档案

```dart
@JsonSerializable()
class UserProfile {
  final int? id;
  final int userId;
  final DateTime? birthDate;
  final String? gender;
  final double? heightCm;
  final double? baselineWeightKg;
  final double? targetWeightKg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    this.id,
    required this.userId,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.baselineWeightKg,
    this.targetWeightKg,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
```

### 6.3 每日活动汇总

```dart
@JsonSerializable()
class DailySummary {
  final int? id;
  final int userId;
  final DateTime recordDate;
  final int totalSteps;
  final double activeCaloriesKcal;
  final double restingCaloriesKcal;
  final double totalDistanceMeters;
  final int activeMinutes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailySummary({
    this.id,
    required this.userId,
    required this.recordDate,
    this.totalSteps = 0,
    this.activeCaloriesKcal = 0,
    this.restingCaloriesKcal = 0,
    this.totalDistanceMeters = 0,
    this.activeMinutes = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) => _$DailySummaryFromJson(json);
  Map<String, dynamic> toJson() => _$DailySummaryToJson(this);
}
```

### 6.4 体重记录

```dart
@JsonSerializable()
class WeightLog {
  final int? id;
  final int userId;
  final DateTime recordDate;
  final double weightKg;
  final double? bodyFatPercentage;
  final double? bmi;
  final DateTime? createdAt;

  WeightLog({
    this.id,
    required this.userId,
    required this.recordDate,
    required this.weightKg,
    this.bodyFatPercentage,
    this.bmi,
    this.createdAt,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) => _$WeightLogFromJson(json);
  Map<String, dynamic> toJson() => _$WeightLogToJson(this);
}
```

### 6.5 运动记录

```dart
@JsonSerializable()
class Activity {
  final int? id;
  final int userId;
  final String activityType;
  final DateTime? startTime;
  final int durationMinutes;
  final double? caloriesBurned;
  final String? description;
  final DateTime? createdAt;

  Activity({
    this.id,
    required this.userId,
    required this.activityType,
    this.startTime,
    required this.durationMinutes,
    this.caloriesBurned,
    this.description,
    this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
```

### 6.6 饮食记录

```dart
@JsonSerializable()
class DietLog {
  final int? id;
  final int userId;
  final DateTime mealTime;
  final String mealType;
  final String foodItems;
  final double? totalCalories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final DateTime? createdAt;

  DietLog({
    this.id,
    required this.userId,
    required this.mealTime,
    required this.mealType,
    required this.foodItems,
    this.totalCalories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.createdAt,
  });

  factory DietLog.fromJson(Map<String, dynamic> json) => _$DietLogFromJson(json);
  Map<String, dynamic> toJson() => _$DietLogToJson(this);
}
```

### 6.7 健康目标

```dart
@JsonSerializable()
class HealthGoal {
  final int? id;
  final int userId;
  final String goalType;
  final double? targetValue;
  final DateTime? deadline;
  final String status;
  final DateTime? createdAt;

  HealthGoal({
    this.id,
    required this.userId,
    required this.goalType,
    this.targetValue,
    this.deadline,
    this.status = 'active',
    this.createdAt,
  });

  factory HealthGoal.fromJson(Map<String, dynamic> json) => _$HealthGoalFromJson(json);
  Map<String, dynamic> toJson() => _$HealthGoalToJson(this);
}
```

### 6.8 心理健康模型

```dart
@JsonSerializable()
class PsyProfile {
  final int? id;
  final int userId;
  final String? mbtiType;
  final String? enneagramType;
  final int? baselineStressLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PsyProfile({
    this.id,
    required this.userId,
    this.mbtiType,
    this.enneagramType,
    this.baselineStressLevel,
    this.createdAt,
    this.updatedAt,
  });

  factory PsyProfile.fromJson(Map<String, dynamic> json) => _$PsyProfileFromJson(json);
  Map<String, dynamic> toJson() => _$PsyProfileToJson(this);
}

@JsonSerializable()
class DailyMood {
  final int? id;
  final int userId;
  final int moodScore;
  final String? primaryEmotion;
  final String? journalText;
  final DateTime recordDate;
  final DateTime? createdAt;

  DailyMood({
    this.id,
    required this.userId,
    required this.moodScore,
    this.primaryEmotion,
    this.journalText,
    required this.recordDate,
    this.createdAt,
  });

  factory DailyMood.fromJson(Map<String, dynamic> json) => _$DailyMoodFromJson(json);
  Map<String, dynamic> toJson() => _$DailyMoodToJson(this);
}

@JsonSerializable()
class PsyAssessment {
  final int? id;
  final int userId;
  final String scaleName;
  final int totalScore;
  final String? severityLevel;
  final String? resultAnalysis;
  final DateTime? createdAt;

  PsyAssessment({
    this.id,
    required this.userId,
    required this.scaleName,
    required this.totalScore,
    this.severityLevel,
    this.resultAnalysis,
    this.createdAt,
  });

  factory PsyAssessment.fromJson(Map<String, dynamic> json) => _$PsyAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$PsyAssessmentToJson(this);
}
```

### 6.9 AI Agent模型

```dart
@JsonSerializable()
class AdviceRecord {
  final int? id;
  final int userId;
  final String agentType;
  final String adviceType;
  final String? title;
  final String content;
  final String? sourceSummary;
  final String? priorityLevel;
  final String status;
  final DateTime? validUntil;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdviceRecord({
    this.id,
    required this.userId,
    required this.agentType,
    required this.adviceType,
    this.title,
    required this.content,
    this.sourceSummary,
    this.priorityLevel,
    this.status = 'active',
    this.validUntil,
    this.createdAt,
    this.updatedAt,
  });

  factory AdviceRecord.fromJson(Map<String, dynamic> json) => _$AdviceRecordFromJson(json);
  Map<String, dynamic> toJson() => _$AdviceRecordToJson(this);
}

@JsonSerializable()
class Checkin {
  final int? id;
  final int userId;
  final int? adviceRecordId;
  final int? followupPlanId;
  final DateTime checkinDate;
  final String completionStatus;
  final int? adherenceScore;
  final int? effectScore;
  final String? userFeedback;
  final String? blockerReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Checkin({
    this.id,
    required this.userId,
    this.adviceRecordId,
    this.followupPlanId,
    required this.checkinDate,
    this.completionStatus = 'pending',
    this.adherenceScore,
    this.effectScore,
    this.userFeedback,
    this.blockerReason,
    this.createdAt,
    this.updatedAt,
  });

  factory Checkin.fromJson(Map<String, dynamic> json) => _$CheckinFromJson(json);
  Map<String, dynamic> toJson() => _$CheckinToJson(this);
}
```

---

## 7. 功能模块设计

### 7.1 首页仪表板

**功能：**
- 显示今日健康概览（步数、卡路里、睡眠、体重）
- 展示健康评分
- AI 建议卡片
- 快捷操作按钮（记录饮食、记录运动）

**数据流：**
```
用户打开首页 → HomeProvider.loadDashboard()
→ 调用 GET /health/daily-summaries/date/{today}
→ 调用 GET /health/weight-logs/latest
→ 调用 GET /health/agent/advice-records/my?activeOnly=true
→ 显示数据
```

### 7.2 健康数据模块

**功能：**
- 数据分类标签（运动、饮食、睡眠、体重）
- 数据图表展示（柱状图、折线图）
- 历史记录列表
- 数据录入表单

**API调用：**
- 运动：`/health/activities/**`
- 饮食：`/health/diet-logs/**`
- 体重：`/health/weight-logs/**`
- 每日汇总：`/health/daily-summaries/**`

### 7.3 AI 助手模块

**功能：**
- 聊天界面（用户消息 + AI 回复）
- 流式响应（SSE）
- 健康问题咨询
- 心理陪伴

**API调用：**
- 流式聊天：`POST /health/chat/stream`
- Agent调用：`POST /health/chat/agent`

### 7.4 心理健康模块

**功能：**
- 心理档案管理
- 每日心情记录
- 心理评估（PHQ-9、GAD-7等）
- 心理聊天记录

**API调用：**
- 心理档案：`/health/psychology/profiles/**`
- 心情记录：`/health/psychology/daily-moods/**`
- 心理评估：`/health/psychology/assessments/**`
- 聊天记录：`/health/psychology/chat-memories/**`

### 7.5 个人中心模块

**功能：**
- 用户信息展示
- 健康档案管理
- 心理档案管理
- 用户偏好设置
- 应用设置

**API调用：**
- 用户信息：`/auth/profile`
- 健康档案：`/health/user-profiles/**`
- 心理档案：`/health/psychology/profiles/**`
- 用户偏好：`/health/agent/user-preferences/**`

---

## 8. 认证流程

### 8.1 JWT 认证流程

```
1. 用户输入用户名/密码
2. POST /auth/login
3. 服务器返回 { token, user: { id, username, nickname, avatar } }
4. 本地存储 Token (flutter_secure_storage)
5. 后续请求自动附加 Authorization: Bearer {token}
6. Token 过期时使用 /auth/refresh 刷新
```

### 8.2 微信登录流程

```
1. 用户点击微信登录
2. 获取微信code
3. POST /auth/wx-login { code }
4. 服务器返回 { token, user }
5. 本地存储 Token
```

### 8.3 二维码登录流程

```
1. Web端生成二维码：POST /auth/qrcode/generate
2. 移动端扫码：POST /auth/qrcode/scan/{qrCodeId}
3. 移动端确认：POST /auth/qrcode/confirm/{qrCodeId}
4. Web端轮询状态：GET /auth/qrcode/status/{qrCodeId}
5. 确认后获取token
```

---

## 9. 医疗与 AI 安全边界

### 9.1 Wellness vs 医疗建议边界

**允许的 Wellness 建议：**
- 运动建议（"建议每天步行 30 分钟"）
- 饮食建议（"增加蔬菜摄入量"）
- 睡眠建议（"保持规律作息"）
- 生活方式建议（"减少久坐时间"）

**禁止的医疗建议：**
- 疾病诊断（"您可能患有..."）
- 处方药物建议（"建议服用..."）
- 治疗方案（"您的治疗方案应该是..."）
- 预后判断（"您的病情会..."）

### 9.2 禁答场景

AI 必须拒绝回答以下类型的问题：

```dart
enum ProhibitedQueryType {
  diagnosis,          // 疾病诊断
  prescription,       // 处方药物
  treatment,          // 治疗方案
  prognosis,          // 预后判断
  emergency,          // 急症处理
  mentalHealthCrisis, // 心理危机
}
```

### 9.3 风险分级系统

```dart
enum RiskLevel {
  low,      // 绿色 - 一般健康建议
  medium,   // 黄色 - 建议咨询专业人士
  high,     // 橙色 - 强烈建议就医
  critical, // 红色 - 紧急情况，立即就医
}
```

---

## 10. 隐私与安全设计

### 10.1 本地加密
- 使用 `flutter_secure_storage` 存储敏感信息（Token）
- Hive 数据库使用 AES-256 加密

### 10.2 云端加密
- 全站 HTTPS (TLS 1.3)
- 数据库字段级加密（敏感字段）

### 10.3 同意管理
- 首次启动时的用户协议
- 数据收集说明
- 用户明确同意

### 10.4 数据删除与导出
- 用户可请求删除所有数据
- 支持导出格式：JSON、CSV

---

## 11. 测试策略

### 11.1 单元测试
- 测试业务逻辑（Use Cases）
- 测试 Provider 状态管理
- 测试 Repository 数据处理

### 11.2 Widget 测试
- 测试 UI 组件渲染
- 测试用户交互响应

### 11.3 集成测试
- 测试完整用户流程
- 测试模块间交互

---

## 12. UI 设计规范

### 12.1 视觉风格
- **风格：** 现代简约
- **配色：** 绿色主题（健康、自然、活力）

### 12.2 颜色定义

```dart
class AppColors {
  static const Color primary = Color(0xFF43e97b);
  static const Color primaryDark = Color(0xFF38f9d7);
  static const Color secondary = Color(0xFF667eea);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFf5576c);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
}
```

### 12.3 导航结构
- **底部导航栏** - 5 个主要页面
  - 首页仪表板
  - 健康数据
  - AI 助手
  - 心理健康
  - 个人中心

---

## 13. 依赖清单

### 13.1 核心依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  go_router: ^12.1.3
  dio: ^5.4.0
  eventsource: ^1.0.0  # SSE 流式响应
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  fl_chart: ^0.66.0
  intl: ^0.19.0
  json_annotation: ^4.8.1
  connectivity_plus: ^5.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  mockito: ^5.4.4
```

---

## 14. MVP 范围与实施计划

### 14.1 MVP 定义

**MVP 目标：** 验证核心价值主张 - 健康记录 + 仪表盘 + AI聊天

**MVP 包含：**
- ✅ 用户认证（JWT登录/微信登录/Token刷新）
- ✅ 健康数据记录（运动、饮食、体重）
- ✅ 首页仪表板（数据概览、图表）
- ✅ AI聊天（SSE 流式响应）
- ✅ 心理健康（心情记录、心理档案）
- ✅ 聊天记录存储

**MVP 不包含：**
- ❌ 健康目标管理
- ❌ 心理评估（PHQ-9、GAD-7）
- ❌ AI Agent建议记录
- ❌ 跟踪计划
- ❌ 打卡系统
- ❌ 用户偏好管理
- ❌ 向量检索功能
- ❌ 离线支持（后续版本）

### 14.2 分阶段实施计划

#### Phase 1: 基础架构 (Week 1-2)
- [ ] Flutter 项目初始化（flutter create + 目录结构）
- [ ] 核心依赖配置（pubspec.yaml）
- [ ] 主题系统（AppColors、AppTheme）
- [ ] 路由配置（GoRouter + 底部导航）
- [ ] API 服务层（Dio + 拦截器 + Token 管理）
- [ ] 本地存储服务（flutter_secure_storage + Hive）
- [ ] 认证模块（登录页 + JWT 认证流程）
- [ ] 通用 UI 组件（LoadingWidget、ErrorWidget）

#### Phase 2: 核心功能 (Week 3-4)
- [ ] 首页仪表板（数据概览卡片、AI 建议卡片）
- [ ] 健康数据模块 - 体重记录（列表 + 图表 + 新增）
- [ ] 健康数据模块 - 运动记录（列表 + 新增）
- [ ] 健康数据模块 - 饮食记录（列表 + 新增）
- [ ] 每日活动汇总展示
- [ ] fl_chart 图表集成（体重趋势、运动统计）

#### Phase 3: AI 功能 (Week 5-6)
- [ ] SSE 服务封装（eventsource 集成）
- [ ] AI 聊天界面（消息列表 + 输入框）
- [ ] 流式响应实时渲染
- [ ] 心理健康模块 - 心情记录（日历视图 + 新增）
- [ ] 心理健康模块 - 心理档案管理
- [ ] 聊天记录本地存储

#### Phase 4: 扩展功能 (Week 7-10)
- [ ] 心理评估（PHQ-9、GAD-7 量表）
- [ ] AI Agent 建议记录展示
- [ ] 跟踪计划管理
- [ ] 打卡系统
- [ ] 用户偏好设置
- [ ] 数据统计与分析

---

## 15. 待定事项

- [ ] 推送通知服务选择（Firebase/极光/个推）
- [ ] 可穿戴设备直接集成（小米手环等）
- [ ] 数据分析和统计功能
- [ ] 社交功能（如需要）

---

## 16. 参考资源

- [Flutter 官方文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev/)
- [Dio 文档](https://pub.dev/packages/dio)
- [Hive 文档](https://docs.hivedb.dev/)
- [Spring WebFlux 文档](https://docs.spring.io/spring-framework/reference/web/webflux.html)

---

**文档完成时间：** 2026-04-29
**作者：** AI Assistant
**审核人：** 待审核