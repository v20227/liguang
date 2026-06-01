# 胶片相机 · 免开发者账号编译指南
# 只需要 Xcode（免费 Apple ID 即可）

## 第一步：用 Xcode 创建项目（30 秒）

1. 打开 Xcode → File → New → Project
2. 选择 iOS → App → Next
3. 配置：
   - Product Name: `FilmCamera`
   - Team: 选你的 Apple ID（免费账号就行）
   - Organization Identifier: `com.zhuge`
   - Interface: SwiftUI → 选 **SwiftUI**（只是为了快速生成项目）
   - Language: Swift
   - 取消勾选所有选项（Core Data、Tests 等都不需要）
4. 点击 Next，选择桌面或任意目录保存

## 第二步：替换项目文件

项目创建好后，把源码文件加到项目里：

```bash
# 假设项目创建在 ~/Desktop/FilmCamera/
cp -R /Users/mima0000/Desktop/羊的草料/FilmCamera-iOS/FilmCamera/* ~/Desktop/FilmCamera/FilmCamera/
```

然后在 Xcode 中：
1. 右键 `FilmCamera` 文件夹 → Add Files to "FilmCamera"
2. 选择 `ViewController.swift` → Add
3. 选择 `Resources/film-camera.html` → Add
4. 删除 Xcode 自动生成的 `ContentView.swift`、`FilmCameraApp.swift`

## 第三步：配置 Info.plist

Xcode 会自动合并 Info.plist。确保以下几点：

1. 在 Xcode 中选择 `FilmCamera` target → Info
2. 确保以下权限描述存在：
   - Privacy - Camera Usage Description: "胶片相机需要访问您的相机"
   - Privacy - Microphone Usage Description: "录制视频时需要麦克风"
   - Privacy - Photo Library Additions Usage Description: "保存照片到相册"

## 第四步：修改 App 入口

删除自动生成的 `FilmCameraApp.swift`，在 AppDelegate 中修改：

找到 `Info.plist` 中的 `UIApplicationSceneManifest` 并删除它（或者删除整个 Scene Configuration 字典），
因为我们的 App 不使用 SceneDelegate，直接用 AppDelegate 管理窗口。

或者更简单的方式：

**替换 AppDelegate.swift**，把 `@main` 移到 AppDelegate，删掉自动生成的 `FilmCameraApp.swift`。

## 第五步：签名并运行

1. 用数据线连接 iPhone
2. 在 Xcode 顶部选择你的 iPhone 作为目标设备
3. 如果提示 "No signing team"，点 "Add Account" 登录你的 Apple ID
4. 选择你的个人 team（显示 "Personal Team"）
5. Xcode 会自动生成开发证书
6. 按 Cmd+R 运行

## 首次运行的注意事项

- 会提示 "未受信任的开发者"：去 iPhone 的 设置 → 通用 → VPN 与设备管理 → 点击开发者 App → 信任
- 摄像头权限：允许
- 相册权限：允许

---

## 更简单的替代方案：PWA

如果你不想折腾 Xcode，还有一个更快捷的方式——

我把 film-camera.html 改成一个 **PWA（渐进式 Web 应用）**，你只需要：

1. 把文件 AirDrop 到 iPhone
2. 用 Safari 打开
3. 点击分享按钮 → 添加到主屏幕

以后它就像原生 App 一样出现在桌面上。不过摄像头需要 HTTPS 服务，你每次使用前需要在 Mac 上跑：

```bash
cd /Users/mima0000/Desktop/羊的草料
python3 serve-zhuge-camera.py
```

然后 iPhone Safari 访问终端打印的 HTTPS 地址。

你选哪种？
