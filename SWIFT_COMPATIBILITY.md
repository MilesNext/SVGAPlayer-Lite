# SVGAPlayer-Lite Swift 兼容性说明

## 兼容性评级：⭐️⭐️⭐️⭐️⭐️ (5/5)

SVGAPlayer-Lite 对 Swift 提供了**完美的兼容性**。作为一个 Objective-C 框架，它遵循了所有 Swift 互操作性的最佳实践。

## ✅ 完全兼容的特性

### 1. 类型安全

所有 API 都使用了正确的可空性注解（`nullable`/`nonnull`），在 Swift 中自动转换为可选类型：

```swift
// Objective-C 定义
- (void)parseWithURL:(nonnull NSURL *)URL
     completionBlock:(void (^_Nonnull)(SVGAVideoEntity *_Nullable videoItem))completionBlock
        failureBlock:(void (^_Nullable)(NSError *_Nullable error))failureBlock;

// Swift 中使用 - 类型安全
parser.parse(with: url) { videoItem in  // videoItem 是 SVGAVideoEntity?
    if let item = videoItem {
        // 安全解包
    }
} failureBlock: { error in  // error 是 Error?
    if let err = error {
        print(err.localizedDescription)
    }
}
```

### 2. 闭包语法

完美支持 Swift 的尾随闭包语法：

```swift
// ✅ 尾随闭包
parser.parse(with: url) { videoItem in
    player.videoItem = videoItem
    player.startAnimation()
} failureBlock: { error in
    print("Error: \(error)")
}

// ✅ 简化语法
parser.parse(withNamed: "animation", in: nil) { videoItem in
    player.videoItem = videoItem
    player.startAnimation()
} failureBlock: nil
```

### 3. 属性访问

所有属性都可以直接访问，支持点语法：

```swift
// ✅ 属性读写
player.loops = 0
player.clearsAfterStop = true
player.fillMode = "Forward"
player.videoItem = videoItem

// ✅ 代理设置
player.delegate = self

// ✅ 解析器配置
parser.enabledMemoryCache = true
```

### 4. 方法调用

方法名自动转换为 Swift 风格：

```swift
// Objective-C: [player startAnimation]
player.startAnimation()

// Objective-C: [player stepToFrame:10 andPlay:YES]
player.step(toFrame: 10, andPlay: true)

// Objective-C: [player setImage:image forKey:@"key"]
player.setImage(image, forKey: "key")
```

### 5. 代理协议

完美支持 Swift 的协议实现：

```swift
extension MyViewController: SVGAPlayerDelegate {
    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer) {
        print("动画完成")
    }

    func svgaPlayer(_ player: SVGAPlayer, didAnimatedToFrame frame: Int) {
        print("当前帧: \(frame)")
    }

    func svgaPlayer(_ player: SVGAPlayer, didAnimatedToPercentage percentage: CGFloat) {
        print("进度: \(percentage * 100)%")
    }
}
```

### 6. 枚举和常量

支持 Swift 的类型推断：

```swift
// ✅ 字符串常量
player.fillMode = "Forward"  // 或 "Backward"

// ✅ 整数类型
player.loops = 0  // Int32 自动转换
```

### 7. 错误处理

虽然不是 Swift 的 `throws` 风格，但闭包方式同样优雅：

```swift
parser.parse(with: url) { videoItem in
    // 成功处理
} failureBlock: { error in
    // 错误处理 - 类型安全
    if let error = error {
        // error 是 Error 类型
        print(error.localizedDescription)
    }
}
```

## 🎯 Swift 使用示例

### 基础使用

```swift
import UIKit
import SVGAPlayerLite

class ViewController: UIViewController {

    private var player: SVGAPlayer!
    private let parser = SVGAParser()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 创建播放器
        player = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        player.center = view.center
        player.loops = 0
        player.delegate = self
        view.addSubview(player)

        // 加载动画
        loadAnimation()
    }

    private func loadAnimation() {
        guard let url = URL(string: "https://example.com/animation.svga") else {
            return
        }

        parser.parse(with: url) { [weak self] videoItem in
            guard let self = self, let item = videoItem else { return }
            self.player.videoItem = item
            self.player.startAnimation()
        } failureBlock: { error in
            print("加载失败: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}

extension ViewController: SVGAPlayerDelegate {
    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer) {
        print("动画播放完成")
    }
}
```

### 动态替换

```swift
// 替换图片
if let image = UIImage(named: "avatar") {
    player.setImage(image, forKey: "avatar")
}

// 网络图片
if let url = URL(string: "https://example.com/image.png") {
    player.setImage(with: url, forKey: "avatar")
}

// 替换文本
let attributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.boldSystemFont(ofSize: 24),
    .foregroundColor: UIColor.white
]
let text = NSAttributedString(string: "Hello", attributes: attributes)
player.setAttributedText(text, forKey: "title")

// 自定义绘制
player.setDrawingBlock({ layer, frameIndex in
    // 自定义绘制
    print("Frame: \(frameIndex)")
}, forKey: "custom")
```

### 本地资源加载

```swift
// 从 Bundle 加载
parser.parse(withNamed: "animation", in: nil) { videoItem in
    player.videoItem = videoItem
    player.startAnimation()
} failureBlock: nil

// 从 Data 加载
if let path = Bundle.main.path(forResource: "animation", ofType: "svga"),
   let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
    parser.parse(with: data, cacheKey: "animation") { videoItem in
        player.videoItem = videoItem
        player.startAnimation()
    } failureBlock: nil
}
```

### 播放控制

```swift
// 开始播放
player.startAnimation()

// 范围播放
player.startAnimation(with: NSRange(location: 0, length: 30), reverse: false)

// 暂停
player.pauseAnimation()

// 停止
player.stopAnimation()

// 清除
player.clear()

// 跳转到指定帧
player.step(toFrame: 10, andPlay: true)

// 跳转到百分比
player.step(toPercentage: 0.5, andPlay: false)
```

## 🔥 SwiftUI 支持

虽然 SVGAPlayer-Lite 是 UIKit 框架，但可以轻松集成到 SwiftUI：

```swift
import SwiftUI
import SVGAPlayerLite

struct SVGAPlayerView: UIViewRepresentable {
    let url: URL
    let loops: Int
    var onFinished: (() -> Void)?

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
        Coordinator(onFinished: onFinished)
    }

    class Coordinator: NSObject, SVGAPlayerDelegate {
        let onFinished: (() -> Void)?

        init(onFinished: (() -> Void)?) {
            self.onFinished = onFinished
        }

        func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer) {
            onFinished?()
        }
    }
}

// 使用
struct ContentView: View {
    var body: some View {
        VStack {
            if let url = URL(string: "https://example.com/animation.svga") {
                SVGAPlayerView(url: url, loops: 0) {
                    print("动画完成")
                }
                .frame(width: 200, height: 200)
            }

            Text("SVGA Animation")
        }
    }
}
```

## 🎨 Swift 特性支持

### 1. 可选链

```swift
player.videoItem?.videoSize
player.delegate?.svgaPlayerDidFinishedAnimation?(player)
```

### 2. Guard 语句

```swift
guard let url = URL(string: urlString) else { return }
guard let videoItem = videoItem else { return }
```

### 3. 弱引用

```swift
parser.parse(with: url) { [weak self] videoItem in
    guard let self = self else { return }
    self.player.videoItem = videoItem
}
```

### 4. 类型推断

```swift
let player = SVGAPlayer()  // 自动推断类型
player.loops = 0           // Int 自动转换为 Int32
```

### 5. 扩展

```swift
extension SVGAPlayer {
    func loadAndPlay(url: URL) {
        let parser = SVGAParser()
        parser.parse(with: url) { [weak self] videoItem in
            self?.videoItem = videoItem
            self?.startAnimation()
        } failureBlock: nil
    }
}

// 使用
player.loadAndPlay(url: url)
```

### 6. 协议扩展

```swift
protocol SVGAPlayable {
    var player: SVGAPlayer { get }
}

extension SVGAPlayable {
    func play(url: URL) {
        let parser = SVGAParser()
        parser.parse(with: url) { [weak self] videoItem in
            self?.player.videoItem = videoItem
            self?.player.startAnimation()
        } failureBlock: nil
    }
}
```

## 📊 兼容性对比

| 特性 | 支持程度 | 说明 |
|------|---------|------|
| 类型安全 | ⭐️⭐️⭐️⭐️⭐️ | 完整的可空性注解 |
| 闭包语法 | ⭐️⭐️⭐️⭐️⭐️ | 支持尾随闭包 |
| 属性访问 | ⭐️⭐️⭐️⭐️⭐️ | 完美的点语法 |
| 方法调用 | ⭐️⭐️⭐️⭐️⭐️ | 自动转换为 Swift 风格 |
| 代理协议 | ⭐️⭐️⭐️⭐️⭐️ | 完整支持 |
| 错误处理 | ⭐️⭐️⭐️⭐️ | 闭包方式（非 throws） |
| SwiftUI | ⭐️⭐️⭐️⭐️ | 通过 UIViewRepresentable |
| Combine | ⭐️⭐️⭐️ | 可以封装为 Publisher |
| Async/Await | ⭐️⭐️⭐️ | 可以封装为 async 函数 |

## 🚀 现代 Swift 特性封装

### Combine 支持

```swift
import Combine

extension SVGAParser {
    func parsePublisher(url: URL) -> AnyPublisher<SVGAVideoEntity, Error> {
        Future { promise in
            self.parse(with: url) { videoItem in
                if let item = videoItem {
                    promise(.success(item))
                } else {
                    promise(.failure(NSError(domain: "SVGAParser", code: -1)))
                }
            } failureBlock: { error in
                promise(.failure(error ?? NSError(domain: "SVGAParser", code: -1)))
            }
        }
        .eraseToAnyPublisher()
    }
}

// 使用
parser.parsePublisher(url: url)
    .sink { completion in
        // 处理完成
    } receiveValue: { videoItem in
        player.videoItem = videoItem
        player.startAnimation()
    }
    .store(in: &cancellables)
```

### Async/Await 支持

```swift
extension SVGAParser {
    func parse(url: URL) async throws -> SVGAVideoEntity {
        try await withCheckedThrowingContinuation { continuation in
            self.parse(with: url) { videoItem in
                if let item = videoItem {
                    continuation.resume(returning: item)
                } else {
                    continuation.resume(throwing: NSError(domain: "SVGAParser", code: -1))
                }
            } failureBlock: { error in
                continuation.resume(throwing: error ?? NSError(domain: "SVGAParser", code: -1))
            }
        }
    }
}

// 使用
Task {
    do {
        let videoItem = try await parser.parse(url: url)
        player.videoItem = videoItem
        player.startAnimation()
    } catch {
        print("Error: \(error)")
    }
}
```

## ⚠️ 注意事项

### 1. 内存管理

使用 `[weak self]` 避免循环引用：

```swift
parser.parse(with: url) { [weak self] videoItem in
    guard let self = self else { return }
    self.player.videoItem = videoItem
}
```

### 2. 线程安全

UI 更新需要在主线程：

```swift
parser.parse(with: url) { videoItem in
    DispatchQueue.main.async {
        self.player.videoItem = videoItem
        self.player.startAnimation()
    }
}
```

### 3. 可选类型处理

正确处理可选类型：

```swift
// ✅ 推荐
if let videoItem = videoItem {
    player.videoItem = videoItem
}

// ✅ 或使用 guard
guard let videoItem = videoItem else { return }
player.videoItem = videoItem
```

## 📝 总结

SVGAPlayer-Lite 对 Swift 的兼容性评级：**⭐️⭐️⭐️⭐️⭐️ (5/5)**

### 优点

✅ **完整的类型安全** - 所有 API 都有正确的可空性注解
✅ **优雅的闭包语法** - 支持 Swift 尾随闭包
✅ **完美的属性访问** - 点语法和自动转换
✅ **代理协议支持** - 完整的协议实现
✅ **SwiftUI 兼容** - 可通过 UIViewRepresentable 集成
✅ **现代化封装** - 可轻松封装为 Combine/Async-Await

### 建议

1. **直接使用** - 无需任何额外封装即可在 Swift 项目中使用
2. **类型安全** - 充分利用 Swift 的可选类型系统
3. **内存管理** - 注意使用 `[weak self]` 避免循环引用
4. **现代化** - 可根据需要封装为 Combine 或 Async/Await

### 结论

SVGAPlayer-Lite 是一个**对 Swift 非常友好**的框架，可以无缝集成到任何 Swift 项目中，无论是 UIKit 还是 SwiftUI。所有 API 都遵循 Swift 的最佳实践，提供了出色的开发体验。

---

**完整示例代码**: [SwiftCompatibilityTest.swift](SwiftCompatibilityTest.swift)
