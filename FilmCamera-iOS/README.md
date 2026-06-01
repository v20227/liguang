# 胶片相机 · iOS 编译指导
# 使用 XcodeGen 生成 Xcode 项目

## 前置条件

1. 安装 XcodeGen：
   ```bash
   brew install xcodegen
   ```

2. 安装 CocoaPods（可选，本项目无依赖）：
   ```bash
   brew install cocoapods
   ```

## 编译步骤

### 1. 生成 Xcode 项目

```bash
cd /Users/mima0000/Desktop/羊的草料/FilmCamera-iOS
xcodegen generate
```

### 2. 打开项目

```bash
open FilmCamera.xcodeproj
```

### 3. 配置签名

- 在 Xcode 中打开项目
- 选择 FilmCamera target
- Signing & Capabilities → Team → 选择你的 Apple 开发者账号
- Bundle Identifier 保持 `com.zhuge.filmcamera`

### 4. 连接真机

- 用数据线连接 iPhone 到 Mac
- 在 Xcode 顶部选择你的 iPhone 作为目标设备
- 按 Cmd+R 编译运行

### 5. 首次运行

- iOS 会弹出摄像头权限请求 → 允许
- iOS 会弹出相册权限请求 → 允许
- 应用会加载胶片相机页面，实时预览摄像头画面

## 项目结构

```
FilmCamera-iOS/
├── project.yml              # XcodeGen 项目配置
├── FilmCamera/
│   ├── AppDelegate.swift     # 应用入口
│   ├── ViewController.swift  # 主控制器（WKWebView）
│   ├── Info.plist            # 应用配置（权限声明）
│   ├── LaunchScreen.storyboard  # 启动屏幕
│   ├── Assets.xcassets/      # 应用图标等资源
│   └── Resources/
│       └── film-camera.html  # 胶片相机 WebGL 页面
└── README.md                # 本文件
```

## 常见问题

### WebGL 不工作？
iOS 15+ 原生支持 WebGL 2.0，如果遇到问题，检查 Info.plist 中是否包含 `arm64` 和 `opengles-3` 的 Required Device Capabilities。

### 摄像头黑屏？
确保在 iPhone 的「设置 → 隐私 → 相机」中允许「胶片相机」访问摄像头。
