# SVGAPlayer-Lite CocoaPods 集成指南

中文文档 | [English](COCOAPODS_GUIDE.md)

## 概述

SVGAPlayer-Lite 现已支持通过 CocoaPods 进行集成。本指南将帮助你快速将 SVGAPlayer-Lite 集成到你的项目中。

## 方式一：本地 Pod 集成（推荐用于开发）

如果你已经下载了 SVGAPlayer-Lite 源码，可以使用本地 Pod 方式集成：

### 1. 在 Podfile 中添加本地路径

```ruby
# 指定本地路径
pod 'SVGAPlayerLite', :path => '/Users/ourtalk/Desktop/SVGAPlayer-Lite'

# 或使用相对路径（如果 Podfile 和 SVGAPlayer-Lite 在同一目录下）
pod 'SVGAPlayerLite', :path => '../SVGAPlayer-Lite'
```

### 2. 安装依赖

```bash
cd YourProject
pod install
```

### 3. 使用 workspace 打开项目

```bash
open YourProject.xcworkspace
```

## 方式二：Git 仓库集成

如果你的 SVGAPlayer-Lite 已经推送到 Git 仓库，可以直接引用：

### 1. 在 Podfile 中添加 Git 地址

```ruby
# 使用 Git 仓库
pod 'SVGAPlayerLite', :git => 'https://github.com/yourusername/SVGAPlayer-Lite.git', :tag => '1.0.0'

# 或使用分支
pod 'SVGAPlayerLite', :git => 'https://github.com/yourusername/SVGAPlayer-Lite.git', :branch => 'main'

# 或使用 commit
pod 'SVGAPlayerLite', :git => 'https://github.com/yourusername/SVGAPlayer-Lite.git', :commit => 'abc123'
```

### 2. 安装依赖

```bash
pod install
```

## 方式三：发布到 CocoaPods Trunk（用于公开发布）

如果你想将 SVGAPlayer-Lite 发布到 CocoaPods 官方仓库：

### 1. 注册 CocoaPods Trunk 账号

```bash
pod trunk register your-email@example.com 'Your Name' --description='Your Description'
```

### 2. 验证邮箱

检查你的邮箱并点击验证链接。

### 3. 更新 podspec 文件

编辑 `SVGAPlayerLite.podspec`，将 `s.source` 改为实际的 Git 仓库地址：

```ruby
s.source = { :git => "https://github.com/yourusername/SVGAPlayer-Lite.git", :tag => s.version }
```

### 4. 创建 Git Tag

```bash
git tag 1.0.0
git push origin 1.0.0
```

### 5. 验证 podspec

```bash
pod spec lint SVGAPlayerLite.podspec --allow-warnings
```

### 6. 发布到 CocoaPods

```bash
pod trunk push SVGAPlayerLite.podspec --allow-warnings
```

### 7. 在项目中使用

发布成功后，其他开发者可以直接在 Podfile 中添加：

```ruby
pod 'SVGAPlayerLite'
```

## 完整的 Podfile 示例

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  # 本地集成方式
  pod 'SVGAPlayerLite', :path => '../SVGAPlayer-Lite'

  # 或 Git 集成方式
  # pod 'SVGAPlayerLite', :git => 'https://github.com/yourusername/SVGAPlayer-Lite.git', :tag => '1.0.0'

  # 或公开发布后
  # pod 'SVGAPlayerLite', '~> 1.0.0'

  # 其他依赖...
end
```

## 在代码中使用

### Objective-C

```objective-c
#import <SVGAPlayerLite/SVGA.h>

// 创建播放器
SVGAPlayer *player = [[SVGAPlayer alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
[self.view addSubview:player];

// 加载并播放动画
SVGAParser *parser = [[SVGAParser alloc] init];
[parser parseWithURL:[NSURL URLWithString:@"https://example.com/animation.svga"]
     completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
    player.videoItem = videoItem;
    [player startAnimation];
} failureBlock:nil];
```

### Swift

```swift
import SVGAPlayerLite

// 创建播放器
let player = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
view.addSubview(player)

// 加载并播放动画
let parser = SVGAParser()
parser.parse(with: URL(string: "https://example.com/animation.svga"), completionBlock: { videoItem in
    player.videoItem = videoItem
    player.startAnimation()
}, failureBlock: nil)
```

## 常见问题

### 1. 找不到头文件

确保在导入时使用模块名称：
```objective-c
#import <SVGAPlayerLite/SVGA.h>  // 正确
// 而不是
#import "SVGA.h"  // 错误
```

### 2. 编译警告

podspec 验证时可能会出现一些警告，这是正常的。使用 `--allow-warnings` 参数可以忽略这些警告。

### 3. 最低部署目标

SVGAPlayer-Lite 要求 iOS 12.0 或更高版本。确保你的项目部署目标不低于此版本。

### 4. 依赖冲突

如果遇到依赖冲突，可以尝试：
```bash
pod deintegrate
pod install
```

## 更新版本

### 更新本地 Pod

```bash
pod update SVGAPlayerLite
```

### 更新所有 Pods

```bash
pod update
```

## 卸载

从 Podfile 中删除 `pod 'SVGAPlayerLite'` 这一行，然后运行：

```bash
pod install
```

## 技术支持

如有问题，请访问：
- GitHub Issues: [提交问题](https://github.com/yourusername/SVGAPlayer-Lite/issues)
- SVGA 官网: http://svga.io/

## 许可证

Apache License 2.0
