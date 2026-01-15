//
//  SVGAImage.m
//  SVGAPlayer
//
//  Created by ourtalk on 1/15/26.
//  Copyright © 2026 UED Center. All rights reserved.
//

#import "SVGAImage.h"
#import <ImageIO/ImageIO.h>

@interface SVGAImage () {
    NSData *_imageData;              // 原始图片数据
    CGImageSourceRef _imageSource;   // CGImageSource（用于读取元数据）
    CGFloat _scale;                  // 图片缩放比例
    CGImageRef _decodedImage;        // 解码后的 CGImage
    BOOL _isDecoded;                 // 是否已解码
    dispatch_semaphore_t _lock;      // 线程安全锁
}

@end

@implementation SVGAImage

#pragma mark - Initialization

- (nullable instancetype)initWithData:(NSData *)data {
    return [self initWithData:data scale:1.0];
}

- (nullable instancetype)initWithData:(NSData *)data scale:(CGFloat)scale {
    if (!data || data.length == 0) {
        return nil;
    }

    // 调用父类的 init 方法（不传递 data，避免父类立即解码）
    self = [super init];
    if (self) {
        // 保存原始数据
        _imageData = [data copy];
        _scale = scale;
        _isDecoded = NO;
        _decodedImage = NULL;
        _lock = dispatch_semaphore_create(1);

        // 创建 CGImageSource（只读取元数据，不解码）
        _imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        if (!_imageSource) {
            return nil;
        }

        // 验证图片格式
        if (CGImageSourceGetCount(_imageSource) == 0) {
            CFRelease(_imageSource);
            _imageSource = NULL;
            return nil;
        }
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc {
    // 释放 CGImageSource
    if (_imageSource) {
        CFRelease(_imageSource);
        _imageSource = NULL;
    }

    // 释放解码后的 CGImage
    if (_decodedImage) {
        CGImageRelease(_decodedImage);
        _decodedImage = NULL;
    }
}

#pragma mark - Override UIImage Properties

/**
 * 重写 CGImage 属性，实现按需解码
 * 这是关键方法：只在真正需要 CGImage 时才解码
 */
- (CGImageRef)CGImage {
    // 如果已经解码，直接返回
    if (_isDecoded && _decodedImage) {
        return _decodedImage;
    }

    // 线程安全：加锁
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);

    // 双重检查：防止多线程重复解码
    if (_isDecoded && _decodedImage) {
        dispatch_semaphore_signal(_lock);
        return _decodedImage;
    }

    // 执行解码
    _decodedImage = [self decodeImage];
    _isDecoded = (_decodedImage != NULL);

    // 解锁
    dispatch_semaphore_signal(_lock);

    return _decodedImage;
}

/**
 * 重写 scale 属性
 */
- (CGFloat)scale {
    return _scale;
}

/**
 * 重写 size 属性（从元数据读取，不触发解码）
 */
- (CGSize)size {
    if (!_imageSource) {
        return CGSizeZero;
    }

    // 从 CGImageSource 读取图片尺寸（不解码）
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL);
    if (!properties) {
        return CGSizeZero;
    }

    CGFloat width = 0;
    CGFloat height = 0;

    CFNumberRef widthNum = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
    CFNumberRef heightNum = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);

    if (widthNum) {
        CFNumberGetValue(widthNum, kCFNumberCGFloatType, &width);
    }
    if (heightNum) {
        CFNumberGetValue(heightNum, kCFNumberCGFloatType, &height);
    }

    CFRelease(properties);

    // 根据 scale 调整尺寸
    return CGSizeMake(width / _scale, height / _scale);
}

#pragma mark - Custom Decoding

/**
 * 核心方法：自定义解码过程
 *
 * 实现原理：
 * 1. 从 CGImageSource 创建 CGImage（会进入 ImageIO 缓存）
 * 2. 强制解码到自己的位图（避免依赖 ImageIO 缓存）
 * 3. 释放原始 CGImage（降低 ImageIO 缓存引用计数）
 * 4. 返回新的 CGImage（完全由我们控制）
 */
- (CGImageRef)decodeImage {
    if (!_imageSource) {
        return NULL;
    }

    // 步骤 1: 从 CGImageSource 创建 CGImage
    // ⚠️ 这里会触发解码，并进入 ImageIO 缓存
    CGImageRef sourceImage = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
    if (!sourceImage) {
        return NULL;
    }

    // 步骤 2: 强制解码到自己的位图
    // ✅ 这是关键：创建一个新的、完全解码的 CGImage
    // ✅ 这个 CGImage 不依赖 ImageIO 缓存
    CGImageRef decodedImage = [self createDecodedImageFromImage:sourceImage];

    // 步骤 3: 释放原始 CGImage
    // ✅ 降低 ImageIO 缓存的引用计数，使其更容易被 LRU 淘汰
    CGImageRelease(sourceImage);

    return decodedImage;
}

/**
 * 强制解码：将 CGImage 解码到自己的位图
 *
 * 参考 YYImage 的 YYCGImageCreateDecodedCopy 实现
 */
- (CGImageRef)createDecodedImageFromImage:(CGImageRef)imageRef {
    if (!imageRef) {
        return NULL;
    }

    // 获取图片尺寸
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) {
        return NULL;
    }

    // 创建颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace) {
        return NULL;
    }

    // 创建 bitmap context
    // ✅ 关键：这里分配的内存完全由我们控制
    CGContextRef context = CGBitmapContextCreate(
        NULL,                                                           // data (NULL = 系统自动分配)
        width,                                                          // width
        height,                                                         // height
        8,                                                              // bitsPerComponent
        0,                                                              // bytesPerRow (0 = 自动计算)
        colorSpace,                                                     // colorSpace
        kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst    // bitmapInfo
    );

    CGColorSpaceRelease(colorSpace);

    if (!context) {
        return NULL;
    }

    // 将原始图片绘制到 context
    // ✅ 此时图片被强制解码到 context 的内存中
    // ✅ 这块内存完全由我们控制，不在 ImageIO 缓存中
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

    // 从 context 创建新的 CGImage
    // ✅ 这个 CGImage 的解码位图在我们自己分配的内存中
    // ✅ 不在 ImageIO 缓存中
    // ✅ 当 CGImageRelease 时，内存立即释放
    CGImageRef decodedImage = CGBitmapContextCreateImage(context);

    CGContextRelease(context);

    return decodedImage;
}

#pragma mark - Public Properties

- (BOOL)isDecoded {
    return _isDecoded;
}

@end
