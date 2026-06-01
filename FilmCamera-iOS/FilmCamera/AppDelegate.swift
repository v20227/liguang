//
//  AppDelegate.swift
//  胶片相机
//  诸葛 · iOS 应用入口
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        window?.overrideUserInterfaceStyle = .dark
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // 释放摄像头资源
        // WKWebView 会自动处理
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // 重新激活摄像头
    }

    // 支持所有方向
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
}
