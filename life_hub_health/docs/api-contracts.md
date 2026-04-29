# LifeHub Health API 接口文档

**版本：** 1.0  
**日期：** 2026-04-29  
**基础URL：** `https://api.lifehub.com`  
**认证方式：** `Authorization: Bearer {token}`

---

## 统一响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": { ... },
  "success": true
}
```

---

## 1. 认证模块

### 1.1 登录
```
POST /auth/login
Body: { "username": string, "password": string }
Response.data: { "token": string, "refreshToken": string?, "user": AuthUser }
```

### 1.2 微信登录
```
POST /auth/wx-login
Body: { "code": string }
Response.data: { "token": string, "refreshToken": string?, "user": AuthUser }
```

### 1.3 获取用户信息
```
GET /auth/profile
Response.data: { "id": long, "username": string, "nickname": string?, "avatar": string? }
```

### 1.4 刷新Token
```
POST /auth/refresh
Body: { "refreshToken": string }
Response.data: { "token": string, "refreshToken": string?, "expiresIn": long }
```

---

## 2. 健康数据模块

### 2.1 用户健康档案
```
GET  /health/user-profiles/my
POST /health/user-profiles/init
Body: { "birthDate": date?, "gender": string?, "heightCm": decimal?, "baselineWeightKg": decimal?, "targetWeightKg": decimal? }
```

### 2.2 每日活动汇总
```
GET /health/daily-summaries/date/{recordDate}
GET /health/daily-summaries/my
GET /health/daily-summaries/range?startDate=&endDate=
Response.data: DailySummary | [DailySummary]
```

### 2.3 运动记录
```
POST /health/activities
Body: { "activityType": string, "startTime": datetime?, "durationMinutes": int, "caloriesBurned": decimal?, "description": string? }

GET /health/activities/my?activityType=
Response.data: [HealthActivity]
```

### 2.4 饮食记录
```
POST /health/diet-logs
Body: { "mealTime": datetime, "mealType": string, "foodItems": string, "totalCalories": decimal?, "proteinG": decimal?, "carbsG": decimal?, "fatG": decimal? }

GET /health/diet-logs/my?mealType=
GET /health/diet-logs/date/{date}
Response.data: [DietLog]
```

### 2.5 体重记录
```
POST /health/weight-logs
Body: { "recordDate": date, "weightKg": decimal, "bodyFatPercentage": decimal?, "bmi": decimal? }

GET /health/weight-logs/my
GET /health/weight-logs/latest
GET /health/weight-logs/range?startDate=&endDate=
Response.data: WeightLog | [WeightLog]
```

---

## 3. AI 聊天模块

### 3.1 流式聊天
```
POST /health/chat/stream
Body: { "message": string, "historyLimit": int?, "useAgent": bool? }
Response: SSE Stream
  event: delta → data: { "type": "delta", "content": string }
  event: complete → data: { "type": "complete" }
```

---

## 4. 心理健康模块

### 4.1 心理档案
```
GET  /health/psychology/profiles/my
POST /health/psychology/profiles/init
Body: { "mbtiType": string?, "enneagramType": string?, "baselineStressLevel": int? }
```

### 4.2 每日心情
```
POST /health/psychology/daily-moods
Body: { "moodScore": int, "primaryEmotion": string?, "journalText": string? }

GET /health/psychology/daily-moods/my
GET /health/psychology/daily-moods/latest
GET /health/psychology/daily-moods/range?startDate=&endDate=
Response.data: DailyMood | [DailyMood]
```

### 4.3 心理评估
```
POST /health/psychology/assessments
Body: { "scaleName": string, "totalScore": int, "severityLevel": string?, "resultAnalysis": string? }

GET /health/psychology/assessments/my?scaleName=
GET /health/psychology/assessments/latest
Response.data: PsyAssessment | [PsyAssessment]
```

### 4.4 聊天记录
```
POST /health/psychology/chat-memories
Body: { "role": string, "content": string, "emotionTags": string? }

GET /health/psychology/chat-memories/my?role=
GET /health/psychology/chat-memories/recent?limit=
```

---

## 5. AI Agent 模块

### 5.1 AI建议记录
```
GET /health/agent/advice-records/my?agentType=&activeOnly=
Response.data: [AdviceRecord]
```

### 5.2 跟踪计划
```
GET /health/agent/followup-plans/my?activeOnly=
Response.data: [FollowupPlan]
```

### 5.3 打卡记录
```
POST /health/agent/checkins
Body: { "adviceRecordId": long?, "followupPlanId": long?, "checkinDate": date, "completionStatus": string?, "adherenceScore": int?, "effectScore": int?, "userFeedback": string?, "blockerReason": string? }

GET /health/agent/checkins/my?followupPlanId=
Response.data: [Checkin]
```

### 5.4 用户偏好
```
GET  /health/agent/user-preferences/my
POST /health/agent/user-preferences
Body: { "preferredDietStyle": string?, "dislikedFoods": string?, "preferredExerciseTypes": string?, "preferredSupportStyle": string?, "routinePattern": string?, "motivationTags": string?, "habitProfile": json? }
Response.data: UserPreferences | true
```

---

## 数据模型对照

| 模型 | 文件 | 对应表 |
|------|------|--------|
| AuthUser | shared/models/auth_user.dart | sys_user |
| DailySummary | shared/models/daily_summary.dart | healthy_daily_summaries |
| HealthActivity | shared/models/health_activity.dart | healthy_activities |
| DietLog | shared/models/diet_log.dart | healthy_diet_logs |
| WeightLog | shared/models/weight_log.dart | healthy_weight_logs |
| UserProfile | shared/models/user_profile.dart | healthy_user_profiles |
| DailyMood | shared/models/daily_mood.dart | health_psy_daily_moods |
| PsyProfile | shared/models/psy_profile.dart | health_psy_profiles |
| PsyAssessment | shared/models/psy_assessment.dart | health_psy_assessments |
| ChatMessage | shared/models/chat_message.dart | health_psy_chat_memories |
| AdviceRecord | shared/models/agent_models.dart | health_agent_advice_records |
| FollowupPlan | shared/models/agent_models.dart | health_agent_followup_plans |
| Checkin | shared/models/agent_models.dart | health_agent_checkins |
| UserPreferences | shared/models/user_preferences.dart | health_agent_user_preferences |

---

## 实现状态

| 接口 | Repository | Provider | UI |
|------|------------|----------|-----|
| POST /auth/login | ✅ | ✅ | ✅ |
| GET /auth/profile | ✅ | ✅ | ✅ |
| GET daily-summaries/** | ✅ | ✅ | ✅ |
| GET weight-logs/latest | ✅ | ✅ | ✅ |
| POST/GET activities/** | ✅ | ✅ | ✅ |
| POST/GET diet-logs/** | ✅ | ✅ | ✅ |
| POST/GET weight-logs/** | ✅ | ✅ | ✅ |
| POST /chat/stream (SSE) | ✅ | ✅ | ✅ |
| GET/POST profiles | ✅ | ✅ | ✅ |
| POST/GET daily-moods | ✅ | ✅ | ✅ |
| POST/GET assessments | ✅ | ✅ | ✅ |
| GET/POST advice-records | ✅ | ✅ | ✅ |
| GET/POST followup-plans | ✅ | ✅ | ✅ |
| GET/POST checkins | ✅ | ✅ | ✅ |
| GET/POST user-preferences | ✅ | ✅ | ✅ |
