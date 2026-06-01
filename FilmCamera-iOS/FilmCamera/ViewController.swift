//
//  ViewController.swift
//  胶片相机
//
//  诸葛 · iOS 原生封装
//  用 WKWebView 承载 WebGL 胶片相机页面，
//  原生侧通过 JS Bridge 提供图片保存、相册写入能力。
//

import UIKit
import WebKit
import Photos

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    private var saveImageCallback: ((Bool) -> Void)?

    // MARK: - 生命周期

    override func loadView() {
        configureWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        setupNavigationBar()
        loadFilmCameraPage()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    // MARK: - WebView 配置

    private func configureWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // 允许 WebGL 和摄像头
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences

        // 用户脚本：JS → Native Bridge
        let bridgeScript = WKUserScript(
            source: """
            window.__iosBridge = {
                saveImage: function(dataURL) {
                    window.webkit.messageHandlers.saveImage.postMessage(dataURL);
                },
                saveVideo: function(dataURL) {
                    window.webkit.messageHandlers.saveVideo.postMessage(dataURL);
                },
                log: function(msg) {
                    window.webkit.messageHandlers.log.postMessage(msg);
                }
            };
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(bridgeScript)
        config.userContentController.add(self, name: "saveImage")
        config.userContentController.add(self, name: "saveVideo")
        config.userContentController.add(self, name: "log")

        // 自定义 UA，让页面知道是 iOS App
        config.applicationNameForUserAgent = "FilmCamera/1.0"

        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
    }

    // MARK: - UI 组件

    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }

    private func setupNavigationBar() {
        // 全屏沉浸，不显示导航栏
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - 加载页面

    private func loadFilmCameraPage() {
        guard let filePath = Bundle.main.path(forResource: "film-camera", ofType: "html") else {
            // 如果本地资源不存在，尝试从 Documents 加载（开发调试用）
            let documentsPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first ?? ""
            let devPath = (documentsPath as NSString)
                .appendingPathComponent("film-camera.html")
            if FileManager.default.fileExists(atPath: devPath) {
                let url = URL(fileURLWithPath: devPath)
                webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            } else {
                showError("无法加载胶片相机页面")
            }
            return
        }
        let url = URL(fileURLWithPath: filePath)
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    private func showError(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showError("加载失败: \(error.localizedDescription)")
    }

    // MARK: - 图片保存到相册

    private func saveImageToAlbum(dataURL: String) {
        guard let data = Data(base64Encoded: dataURL.components(separatedBy: ",").last ?? ""),
              let image = UIImage(data: data) else {
            callBridgeCallback(false)
            return
        }

        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    self?.showAlbumPermissionAlert()
                    self?.callBridgeCallback(false)
                    return
                }
                self?.performSaveImage(image)
            }
        }
    }

    private func performSaveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(imageSaveCompletion(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }

    @objc private func imageSaveCompletion(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeMutableRawPointer?
    ) {
        if let error = error {
            print("保存失败: \(error.localizedDescription)")
            callBridgeCallback(false)
            showToast("保存失败")
        } else {
            callBridgeCallback(true)
            showToast("已保存到相册")
        }
    }

    private func callBridgeCallback(_ success: Bool) {
        let js = success ? "true" : "false"
        webView.evaluateJavaScript("window.__saveCallback && window.__saveCallback(\(js))", completionHandler: nil)
    }

    private func showAlbumPermissionAlert() {
        let alert = UIAlertController(
            title: "需要相册权限",
            message: "请在设置中允许胶片相机访问您的相册",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    private func showToast(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.alpha = 0
        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
        ])
        label.layoutIfNeeded()
        label.layer.cornerRadius = 20

        UIView.animate(withDuration: 0.3, animations: {
            label.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 1.5, delay: 1.0, options: [], animations: {
                label.alpha = 0
            }) { _ in
                label.removeFromSuperview()
            }
        }
    }
}

// MARK: - WKScriptMessageHandler

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        switch message.name {
        case "saveImage":
            if let dataURL = message.body as? String {
                saveImageToAlbum(dataURL: dataURL)
            }
        case "saveVideo":
            if let dataURL = message.body as? String {
                print("视频保存暂未实现: \(dataURL.prefix(50))...")
                showToast("视频保存功能开发中")
            }
        case "log":
            if let msg = message.body as? String {
                print("[JS Bridge] \(msg)")
            }
        default:
            break
        }
    }
}
