# AI Chat App

一个基于 Flutter 开发的智能聊天应用，支持多种 AI 模型，提供丰富的交互功能。

## 项目概述

AI Chat App 是一款功能丰富的聊天应用，允许用户与多种 AI 模型进行对话交流。应用采用 Flutter 框架开发，支持跨平台部署，具有现代化的 UI 设计和流畅的用户体验。

### 核心特点

- **多模型支持**：集成了多家 AI 服务提供商的多种模型
- **丰富的交互方式**：支持文本、语音输入和文件上传
- **对话管理**：完整的对话创建、保存和管理功能
- **主题切换**：支持明暗主题模式切换
- **本地化**：支持中文界面和语音识别

## 功能特性

### 1. 多模型支持
- DeepSeek Chat - 基础对话模型
- DeepSeek R1 - 支持联网搜索和深度思考的增强模型
- DeepSeek Coder - 专注于代码相关对话
- GPT-4 - OpenAI 的高级模型
- GPT-3.5 Turbo - OpenAI 的基础模型
- Claude 3 Opus - Anthropic 的高级模型
- Claude 3 Sonnet - Anthropic 的基础模型

### 2. 对话管理
- 创建新对话
- 对话列表管理
- 对话删除
- 一键清空所有对话

### 3. 输入方式
- 文本输入
- 语音输入（支持中文语音识别）
- 图片上传
- 文件上传

### 4. 界面特性
- 支持明暗主题切换
- 流式响应显示
- Markdown 格式渲染
- 代码高亮显示
- 消息时间戳显示
- 滚动到底部快捷按钮

### 5. 高级功能
- DeepSeek R1 模型特有的联网搜索功能
- DeepSeek R1 模型特有的深度思考功能
- 多语言支持
- 本地数据持久化

## 技术架构

### 架构设计
项目采用了清晰的分层架构设计：
- **表示层**：screens 和 widgets 目录，负责 UI 展示
- **业务逻辑层**：providers 目录，使用 Riverpod 管理状态
- **数据层**：models 目录，定义数据结构
- **服务层**：services 目录，处理 API 调用和本地存储

### 状态管理
使用 Riverpod 进行状态管理，主要包括：
- 对话状态管理 (ConversationsNotifier)
- 当前对话管理 (CurrentConversationNotifier)
- 聊天消息管理 (ChatMessagesNotifier)
- 主题状态管理 (ThemeNotifier)
- 模型选择管理 (selectedModelProvider)

### 数据流
1. 用户在 UI 层输入消息
2. 通过 Provider 将消息传递给业务逻辑层
3. 业务逻辑层调用服务层发送 API 请求
4. 服务层返回结果，更新状态
5. UI 层响应状态变化，更新界面

## 技术栈

### 核心框架
- Flutter SDK: ^3.6.0
- Dart SDK: ^3.6.0

### 状态管理
- flutter_riverpod: ^2.4.9
- riverpod_annotation: ^2.3.3

### UI 组件
- flutter_chat_ui: ^1.6.12
- flutter_markdown: ^0.6.18+2
- flutter_spinkit: ^5.2.0
- animated_text_kit: ^4.2.2
- google_fonts: ^6.1.0

### 网络请求
- dio: ^5.4.0
- http: ^1.2.0

### 数据持久化
- shared_preferences: ^2.2.2
- flutter_dotenv: ^5.1.0

### 功能支持
- speech_to_text: ^6.6.1
- image_picker: ^1.0.7
- file_picker: ^6.1.1
- url_launcher: ^6.2.4
- permission_handler: ^11.3.0

### 工具库
- uuid: ^4.3.3
- intl: 用于日期格式化
- json_annotation: ^4.8.1
- freezed_annotation: ^2.4.1

## 项目结构

```
lib/
├── models/          # 数据模型
│   ├── ai_model.dart            # AI模型定义
│   ├── conversation.dart        # 对话数据模型
│   └── ...                      # 自动生成的序列化文件
├── providers/       # 状态管理
│   ├── chat_provider.dart       # 聊天消息状态管理
│   ├── conversation_provider.dart # 对话列表状态管理
│   ├── model_provider.dart      # AI模型选择状态管理
│   └── theme_provider.dart      # 主题状态管理
├── screens/         # 页面
│   └── home_screen.dart         # 主页面
├── services/        # 服务
│   ├── chat_service.dart        # AI API调用服务
│   └── config_service.dart      # 配置和本地存储服务
├── theme/          # 主题
│   └── app_theme.dart           # 应用主题定义
├── widgets/         # 组件
│   ├── home/                    # 主页组件
│   │   ├── chat_input.dart      # 聊天输入组件
│   │   ├── feature_button.dart  # 功能按钮组件
│   │   ├── message_list.dart    # 消息列表组件
│   │   └── voice_input.dart     # 语音输入组件
│   ├── chat_view.dart           # 聊天视图组件
│   ├── conversation_drawer.dart # 对话抽屉组件
│   ├── markdown_text.dart       # Markdown渲染组件
│   └── model_selector.dart      # 模型选择组件
└── main.dart       # 入口文件
```

## 开始使用

### 环境要求
- Flutter 3.6.0 或更高版本
- Dart 3.6.0 或更高版本
- iOS 12.0 或更高版本
- Android 5.0 (API 21) 或更高版本

### 安装步骤

1. 克隆项目
```bash
git clone [项目地址]
```

2. 安装依赖
```bash
flutter pub get
```

3. 配置环境变量
创建 `.env` 文件并添加以下配置：
```
OPENAI_API_KEY=your_openai_api_key
ANTHROPIC_API_KEY=your_anthropic_api_key
DEEPSEEK_API_KEY=your_deepseek_api_key
```

4. 运行项目
```bash
flutter run
```

## 权限说明

### iOS
在 `Info.plist` 中配置：
- NSMicrophoneUsageDescription: 用于语音输入
- NSSpeechRecognitionUsageDescription: 用于语音识别

### Android
在 `AndroidManifest.xml` 中配置：
- android.permission.INTERNET: 用于网络访问
- android.permission.RECORD_AUDIO: 用于语音输入

## 开发指南

### 添加新模型
1. 在 `lib/models/ai_model.dart` 中的 `defaultModels` 列表中添加新模型定义
2. 在 `lib/services/chat_service.dart` 中添加对应的 API 调用方法

### 添加新功能
1. 创建新的组件或服务
2. 在 Provider 中添加相应的状态管理
3. 在 UI 层集成新功能

### 代码规范
- 使用 Dart 格式化工具保持代码风格一致
- 遵循 Flutter 官方推荐的最佳实践
- 为公共组件和方法添加文档注释

## 贡献指南

欢迎提交 Issue 和 Pull Request。在提交 PR 之前，请确保：

1. 代码经过格式化
2. 所有测试通过
3. 遵循项目的代码规范
4. 提供清晰的提交信息

## 许可证

[添加许可证信息]
