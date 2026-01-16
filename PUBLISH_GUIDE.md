# Publishing SVGAPlayerLite to CocoaPods Trunk Guide

[中文文档](PUBLISH_GUIDE_CN.md) | English

## Current Status

✅ Project pushed to GitHub: https://github.com/jfyGiveMeFive/SVGAPlayer-Lite
✅ Version tag created: 1.0.1
✅ Podspec validation passed

## Publishing Steps

### 1. Register CocoaPods Trunk Account

If you haven't registered a CocoaPods Trunk account yet, you need to register first:

```bash
pod trunk register YOUR_EMAIL@example.com 'Your Name' --description='MacBook Pro'
```

**Example:**
```bash
pod trunk register aygtech@qq.com 'jfyGiveMeFive' --description='MacBook Pro'
```

After execution, CocoaPods will send a verification email to your mailbox.

### 2. Verify Email

1. Check your email inbox (including spam folder)
2. Click the verification link in the email
3. After successful verification, you can publish Pods

### 3. Verify Your Trunk Account

```bash
pod trunk me
```

This will display your account information and published Pods.

### 4. Publish to CocoaPods Trunk

```bash
cd /Users/ourtalk/Desktop/SVGAPlayer-Lite
pod trunk push SVGAPlayerLite.podspec --allow-warnings
```

**Note:**
- Use `--allow-warnings` because there are some warnings that don't affect functionality
- The publishing process may take a few minutes
- After successful publication, CocoaPods will automatically update the index

### 5. Verify Successful Publication

After successful publication, wait 5-10 minutes, then you can search for your Pod:

```bash
pod search SVGAPlayerLite
```

Or visit the CocoaPods website to check:
https://cocoapods.org/pods/SVGAPlayerLite

## Usage

After successful publication, other developers can use it in the following ways:

### Method 1: Direct Use (Recommended)

```ruby
pod 'SVGAPlayerLite'
```

### Method 2: Specify Version

```ruby
pod 'SVGAPlayerLite', '~> 1.0.1'
```

### Method 3: Use Git (Before Publishing or for Testing)

```ruby
pod 'SVGAPlayerLite', :git => 'https://github.com/jfyGiveMeFive/SVGAPlayer-Lite.git', :tag => '1.0.1'
```

## Updating Versions

When you need to publish a new version:

### 1. Modify Code and Test

### 2. Update Version Number

Edit `SVGAPlayerLite.podspec` and modify the version number:
```ruby
s.version = "1.0.2"
```

### 3. Commit and Push

```bash
git add .
git commit -m "Release version 1.0.2"
git push origin main
```

### 4. Create New Tag

```bash
git tag 1.0.2
git push origin 1.0.2
```

### 5. Validate Podspec

```bash
pod spec lint SVGAPlayerLite.podspec --allow-warnings
```

### 6. Publish New Version

```bash
pod trunk push SVGAPlayerLite.podspec --allow-warnings
```

## Common Issues

### Q: Publication failed with "Unable to find a pod with name"
A: This is normal for the first publication. Continue with the publish command.

### Q: Cannot find Pod after publication
A: Wait 5-10 minutes for CocoaPods to update the index, then update your local Pod repository:
```bash
pod repo update
pod search SVGAPlayerLite
```

### Q: How to delete a published version
A: CocoaPods does not support deleting published versions. If there's an issue, you can only publish a new version to fix it.

### Q: Permission error during publication
A: Make sure you have registered and verified your CocoaPods Trunk account. Run `pod trunk me` to check.

### Q: How to transfer Pod ownership
A: Use the following command to add other maintainers:
```bash
pod trunk add-owner SVGAPlayerLite other-email@example.com
```

## Maintenance Recommendations

1. **Semantic Versioning**
   - Major version: Incompatible API changes
   - Minor version: Backward-compatible functionality additions
   - Patch version: Backward-compatible bug fixes

2. **Changelog**
   - Maintain a CHANGELOG in README.md
   - Record major changes with each release

3. **Testing**
   - Test in actual projects before publishing
   - Ensure podspec validation passes

4. **Documentation**
   - Keep README.md updated
   - Provide clear usage examples

## Related Links

- GitHub Repository: https://github.com/jfyGiveMeFive/SVGAPlayer-Lite
- CocoaPods Official Site: https://cocoapods.org
- CocoaPods Trunk Guide: https://guides.cocoapods.org/making/getting-setup-with-trunk.html

## Current Version Information

- **Version**: 1.0.1
- **Minimum Support**: iOS 12.0+
- **Dependencies**:
  - SSZipArchive >= 1.8.1
  - Protobuf ~> 3.27
- **License**: Apache 2.0
