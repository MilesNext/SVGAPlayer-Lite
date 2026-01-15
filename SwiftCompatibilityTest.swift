//
//  SwiftCompatibilityTest.swift
//  SVGAPlayerLite Swift 兼容性测试
//
//  此文件用于验证 SVGAPlayerLite 在 Swift 中的使用体验
//

import UIKit
import SVGAPlayerLite

class SwiftCompatibilityTest {

    // MARK: - 基本使用测试

    func testBasicUsage() {
        // ✅ 创建播放器 - 完全兼容
        let player = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        // ✅ 设置属性 - 完全兼容
        player.loops = 0
        player.clearsAfterStop = true
        player.fillMode = "Forward"

        // ✅ 创建解析器 - 完全兼容
        let parser = SVGAParser()
        parser.enabledMemoryCache = true
    }

    // MARK: - 网络加载测试

    func testNetworkLoading() {
        let player = SVGAPlayer()
        let parser = SVGAParser()

        // ✅ 闭包语法 - 完全兼容
        if let url = URL(string: "https://example.com/animation.svga") {
            parser.parse(with: url, completionBlock: { videoItem in
                // ✅ 可选类型处理 - 完全兼容
                if let item = videoItem {
                    player.videoItem = item
                    player.startAnimation()
                }
            }, failureBlock: { error in
                // ✅ 错误处理 - 完全兼容
                if let err = error {
                    print("加载失败: \(err.localizedDescription)")
                }
            })
        }
    }

    // MARK: - 本地加载测试

    func testLocalLoading() {
        let player = SVGAPlayer()
        let parser = SVGAParser()

        // ✅ 本地资源加载 - 完全兼容
        parser.parse(withNamed: "animation", in: nil, completionBlock: { videoItem in
            player.videoItem = videoItem
            player.startAnimation()
        }, failureBlock: nil)
    }

    // MARK: - 代理方法测试

    func testDelegate() {
        let player = SVGAPlayer()
        // ✅ 代理设置 - 完全兼容
        // player.delegate = self
    }

    // MARK: - 播放控制测试

    func testPlaybackControl() {
        let player = SVGAPlayer()

        // ✅ 播放控制 - 完全兼容
        player.startAnimation()
        player.pauseAnimation()
        player.stopAnimation()
        player.clear()

        // ✅ 跳转到指定帧 - 完全兼容
        player.step(toFrame: 10, andPlay: true)
        player.step(toPercentage: 0.5, andPlay: false)

        // ✅ 范围播放 - 完全兼容
        player.startAnimation(with: NSRange(location: 0, length: 30), reverse: false)
    }

    // MARK: - 动态替换测试

    func testDynamicReplacement() {
        let player = SVGAPlayer()

        // ✅ 替换图片 - 完全兼容
        if let image = UIImage(named: "replacement") {
            player.setImage(image, forKey: "key")
        }

        // ✅ 网络图片 - 完全兼容
        if let url = URL(string: "https://example.com/image.png") {
            player.setImage(with: url, forKey: "key")
        }

        // ✅ 替换文本 - 完全兼容
        let text = NSAttributedString(string: "Hello", attributes: [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.red
        ])
        player.setAttributedText(text, forKey: "key")

        // ✅ 自定义绘制 - 完全兼容
        player.setDrawingBlock({ layer, frameIndex in
            // 自定义绘制逻辑
            print("Drawing frame: \(frameIndex)")
        }, forKey: "key")

        // ✅ 隐藏元素 - 完全兼容
        player.setHidden(true, forKey: "key")

        // ✅ 清除动态对象 - 完全兼容
        player.clearDynamicObjects()
    }

    // MARK: - 数据加载测试

    func testDataLoading() {
        let player = SVGAPlayer()
        let parser = SVGAParser()

        // ✅ 从 Data 加载 - 完全兼容
        if let data = try? Data(contentsOf: URL(fileURLWithPath: "/path/to/file.svga")) {
            parser.parse(with: data, cacheKey: "cache_key", completionBlock: { videoItem in
                player.videoItem = videoItem
                player.startAnimation()
            }, failureBlock: { error in
                print("Error: \(error)")
            })
        }
    }
}

// MARK: - 代理实现示例

extension SwiftCompatibilityTest: SVGAPlayerDelegate {

    // ✅ 代理方法 - 完全兼容
    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer) {
        print("动画播放完成")
    }

    func svgaPlayer(_ player: SVGAPlayer, didAnimatedToFrame frame: Int) {
        print("当前帧: \(frame)")
    }

    func svgaPlayer(_ player: SVGAPlayer, didAnimatedToPercentage percentage: CGFloat) {
        print("播放进度: \(percentage * 100)%")
    }
}

// MARK: - 实际使用示例

class ExampleViewController: UIViewController {

    private var player: SVGAPlayer!
    private let parser = SVGAParser()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayer()
        loadAnimation()
    }

    private func setupPlayer() {
        // ✅ 创建和配置播放器 - Swift 语法完美
        player = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        player.center = view.center
        player.loops = 0 // 无限循环
        player.clearsAfterStop = false
        player.delegate = self
        view.addSubview(player)
    }

    private func loadAnimation() {
        // ✅ 使用 Swift 的尾随闭包语法
        guard let url = URL(string: "https://example.com/animation.svga") else {
            return
        }

        parser.parse(with: url) { [weak self] videoItem in
            guard let self = self, let item = videoItem else { return }

            // ✅ 可选绑定和弱引用 - 完美支持
            self.player.videoItem = item
            self.player.startAnimation()

            // ✅ 动态替换 - 链式调用
            self.setupDynamicContent()
        } failureBlock: { error in
            // ✅ 错误处理
            if let error = error {
                print("加载失败: \(error.localizedDescription)")
            }
        }
    }

    private func setupDynamicContent() {
        // ✅ 替换图片
        if let image = UIImage(named: "avatar") {
            player.setImage(image, forKey: "avatar")
        }

        // ✅ 替换文本
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.white
        ]
        let text = NSAttributedString(string: "Hello Swift!", attributes: attributes)
        player.setAttributedText(text, forKey: "title")
    }
}

extension ExampleViewController: SVGAPlayerDelegate {

    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer) {
        print("✅ 动画播放完成")
    }

    func svgaPlayer(_ player: SVGAPlayer, didAnimatedToFrame frame: Int) {
        // 可以在这里更新 UI
    }
}

// MARK: - SwiftUI 兼容性示例

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
struct SVGAPlayerView: UIViewRepresentable {
    let url: URL
    let loops: Int

    func makeUIView(context: Context) -> SVGAPlayer {
        let player = SVGAPlayer()
        player.loops = Int32(loops)
        player.delegate = context.coordinator
        return player
    }

    func updateUIView(_ player: SVGAPlayer, context: Context) {
        let parser = SVGAParser()
        parser.parse(with: url) { videoItem in
            player.videoItem = videoItem
            player.startAnimation()
        } failureBlock: { error in
            print("Error: \(String(describing: error))")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, SVGAPlayerDelegate {
        func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer) {
            print("SwiftUI: 动画完成")
        }
    }
}

// ✅ SwiftUI 中使用
@available(iOS 13.0, *)
struct ContentView: View {
    var body: some View {
        VStack {
            if let url = URL(string: "https://example.com/animation.svga") {
                SVGAPlayerView(url: url, loops: 0)
                    .frame(width: 200, height: 200)
            }
        }
    }
}
#endif
