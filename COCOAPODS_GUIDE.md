# SVGAPlayer-Lite CocoaPods Integration Guide

[中文文档](COCOAPODS_GUIDE_CN.md) | English

## Overview

SVGAPlayer-Lite now supports integration via CocoaPods. This guide will help you quickly integrate SVGAPlayer-Lite into your project.

## Method 1: Local Pod Integration (Recommended for Development)

If you have already downloaded the SVGAPlayer-Lite source code, you can integrate it using the local Pod method:

### 1. Add Local Path in Podfile

```ruby
# Specify local path
pod 'SVGAPlayerLite', :path => '/Users/ourtalk/Desktop/SVGAPlayer-Lite'

# Or use relative path (if Podfile and SVGAPlayer-Lite are in the same directory)
pod 'SVGAPlayerLite', :path => '../SVGAPlayer-Lite'
```

### 2. Install Dependencies

```bash
cd YourProject
pod install
```

### 3. Open Project with Workspace

```bash
open YourProject.xcworkspace
```

## Method 2: Git Repository Integration

If your SVGAPlayer-Lite has been pushed to a Git repository, you can reference it directly:

### 1. Add Git URL in Podfile

```ruby
# Use Git repository
pod 'SVGAPlayerLite', :git => 'https://github.com/yourusername/SVGAPlayer-Lite.git', :tag => '1.0.0'

# Or use branch
pod 'SVGAPlayerLite', :git => 'https://github.com/yourusername/SVGAPlayer-Lite.git', :branch => 'main'

# Or use commit
pod 'SVGAPlayerLite', :git => 'https://github.com/yourusername/SVGAPlayer-Lite.git', :commit => 'abc123'
```

### 2. Install Dependencies

```bash
pod install
```

## Method 3: Publish to CocoaPods Trunk (For Public Release)

If you want to publish SVGAPlayer-Lite to the official CocoaPods repository:

### 1. Register CocoaPods Trunk Account

```bash
pod trunk register your-email@example.com 'Your Name' --description='Your Description'
```

### 2. Verify Email

Check your email and click the verification link.

### 3. Update Podspec File

Edit `SVGAPlayerLite.podspec` and change `s.source` to your actual Git repository URL:

```ruby
s.source = { :git => "https://github.com/yourusername/SVGAPlayer-Lite.git", :tag => s.version }
```

### 4. Create Git Tag

```bash
git tag 1.0.0
git push origin 1.0.0
```

### 5. Validate Podspec

```bash
pod spec lint SVGAPlayerLite.podspec --allow-warnings
```

### 6. Publish to CocoaPods

```bash
pod trunk push SVGAPlayerLite.podspec --allow-warnings
```

### 7. Use in Projects

After successful publication, other developers can add it directly in their Podfile:

```ruby
pod 'SVGAPlayerLite'
```

## Complete Podfile Example

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  # Local integration method
  pod 'SVGAPlayerLite', :path => '../SVGAPlayer-Lite'

  # Or Git integration method
  # pod 'SVGAPlayerLite', :git => 'https://github.com/yourusername/SVGAPlayer-Lite.git', :tag => '1.0.0'

  # Or after public release
  # pod 'SVGAPlayerLite', '~> 1.0.0'

  # Other dependencies...
end
```

## Usage in Code

### Objective-C

```objective-c
#import <SVGAPlayerLite/SVGA.h>

// Create player
SVGAPlayer *player = [[SVGAPlayer alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
[self.view addSubview:player];

// Load and play animation
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

// Create player
let player = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
view.addSubview(player)

// Load and play animation
let parser = SVGAParser()
parser.parse(with: URL(string: "https://example.com/animation.svga"), completionBlock: { videoItem in
    player.videoItem = videoItem
    player.startAnimation()
}, failureBlock: nil)
```

## Common Issues

### 1. Header File Not Found

Make sure to use the module name when importing:
```objective-c
#import <SVGAPlayerLite/SVGA.h>  // Correct
// Instead of
#import "SVGA.h"  // Incorrect
```

### 2. Compilation Warnings

Some warnings may appear during podspec validation, which is normal. Use the `--allow-warnings` parameter to ignore these warnings.

### 3. Minimum Deployment Target

SVGAPlayer-Lite requires iOS 12.0 or higher. Make sure your project deployment target is not lower than this version.

### 4. Dependency Conflicts

If you encounter dependency conflicts, try:
```bash
pod deintegrate
pod install
```

## Updating Versions

### Update Local Pod

```bash
pod update SVGAPlayerLite
```

### Update All Pods

```bash
pod update
```

## Uninstallation

Remove the `pod 'SVGAPlayerLite'` line from your Podfile, then run:

```bash
pod install
```

## Technical Support

For questions, please visit:
- GitHub Issues: [Submit Issue](https://github.com/yourusername/SVGAPlayer-Lite/issues)
- SVGA Official Website: http://svga.io/

## License

Apache License 2.0
