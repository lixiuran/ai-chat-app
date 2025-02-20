# AI Chat App

一个基于 Flutter 开发的智能聊天应用，支持多种 AI 模型，提供丰富的交互功能。

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
├── providers/       # 状态管理
├── screens/         # 页面
├── services/        # 服务
├── theme/          # 主题
├── widgets/         # 组件
│   ├── home/       # 主页组件
│   └── ...
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

## 贡献指南

欢迎提交 Issue 和 Pull Request。在提交 PR 之前，请确保：

1. 代码经过格式化
2. 所有测试通过
3. 遵循项目的代码规范
4. 提供清晰的提交信息

## 许可证

[添加许可证信息]
