# LifeHub Health

AI 驱动的健康管理应用，基于 Flutter 构建。

## 功能特性

- **健康数据追踪** - 记录运动、饮食、体重，支持图表趋势分析
- **AI 健康助手** - 基于 SSE 流式响应的 AI 聊天
- **心理健康管理** - 心情记录、PHQ-9/GAD-7 心理评估、危机响应
- **个人中心** - 健康档案、心理档案、AI 建议、打卡系统

## 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter 3.6+ |
| 状态管理 | Riverpod |
| 路由 | GoRouter |
| 网络 | Dio + EventSource (SSE) |
| 本地存储 | Hive (AES-256) + flutter_secure_storage |
| 图表 | fl_chart |
| 架构 | Clean Architecture (Domain/Data/Presentation) |

## 项目结构

```
lib/
├── app/                    # 应用入口、路由
├── core/                   # 主题、常量、工具、通用组件
├── features/
│   ├── auth/               # 认证（登录、Token刷新）
│   ├── home/               # 首页仪表板
│   ├── health_data/        # 健康数据（运动/饮食/体重）
│   ├── ai_chat/            # AI 聊天（SSE 流式）
│   ├── psychology/         # 心理健康（心情/评估）
│   └── profile/            # 个人中心
└── shared/                 # 共享模型、服务、Provider
```

## 运行

```bash
# 安装依赖
flutter pub get

# 生成代码（json_serializable）
flutter pub run build_runner build --delete-conflicting-outputs

# 运行
flutter run
```

## API 文档

详见 [docs/api-contracts.md](docs/api-contracts.md)

## 设计文档

详见 [docs/superpowers/specs/](docs/superpowers/specs/)
