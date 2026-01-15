//
//  SVGAImageTests.m
//  SVGAPlayer
//
//  Created by ourtalk on 1/15/26.
//  Copyright © 2026 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGAImage.h"
#import <mach/mach.h>

/**
 * SVGAImage 测试类
 * 用于验证延迟解码和按需解码功能
 */
@interface SVGAImageTests : NSObject

/**
 * 获取当前内存使用量（MB）
 */
+ (NSUInteger)currentMemoryUsage;

/**
 * 测试 1: 延迟解码
 * 验证创建 SVGAImage 时不立即解码
 */
+ (void)testLazyDecoding;

/**
 * 测试 2: 按需解码
 * 验证只在访问 CGImage 时才解码
 */
+ (void)testOnDemandDecoding;

/**
 * 测试 3: 内存占用对比
 * 对比 UIImage 和 SVGAImage 的内存占用
 */
+ (void)testMemoryComparison;

/**
 * 测试 4: 批量加载
 * 测试加载多张图片的内存占用
 */
+ (void)testBatchLoading;

/**
 * 测试 5: 释放后内存
 * 验证释放后内存是否完全回收
 */
+ (void)testMemoryRelease;

/**
 * 运行所有测试
 */
+ (void)runAllTests;

@end

@implementation SVGAImageTests

#pragma mark - Memory Utilities

+ (NSUInteger)currentMemoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kerr == KERN_SUCCESS) {
        return info.resident_size / 1024 / 1024; // MB
    }
    return 0;
}

#pragma mark - Test Cases

+ (void)testLazyDecoding {
    NSLog(@"\n========================================");
    NSLog(@"测试 1: 延迟解码");
    NSLog(@"========================================");

    // 创建测试图片数据（1x1 像素的 PNG）
    NSData *imageData = [self createTestImageData];

    // 记录初始内存
    NSUInteger initialMemory = [self currentMemoryUsage];
    NSLog(@"初始内存: %lu MB", (unsigned long)initialMemory);

    // 创建 SVGAImage
    SVGAImage *image = [[SVGAImage alloc] initWithData:imageData scale:2.0];
    NSLog(@"创建 SVGAImage 后...");
    NSLog(@"  - isDecoded: %d", image.isDecoded);

    // 记录创建后内存
    NSUInteger afterCreateMemory = [self currentMemoryUsage];
    NSLog(@"  - 内存增长: %lu MB", (unsigned long)(afterCreateMemory - initialMemory));

    // 验证
    if (!image.isDecoded) {
        NSLog(@"✅ 测试通过：创建时未解码");
    } else {
        NSLog(@"❌ 测试失败：创建时已解码");
    }

    NSLog(@"========================================\n");
}

+ (void)testOnDemandDecoding {
    NSLog(@"\n========================================");
    NSLog(@"测试 2: 按需解码");
    NSLog(@"========================================");

    NSData *imageData = [self createTestImageData];

    // 创建 SVGAImage
    SVGAImage *image = [[SVGAImage alloc] initWithData:imageData scale:2.0];
    NSLog(@"创建 SVGAImage 后: isDecoded = %d", image.isDecoded);

    // 访问 CGImage（触发解码）
    CGImageRef cgImage = image.CGImage;
    NSLog(@"访问 CGImage 后: isDecoded = %d", image.isDecoded);

    // 验证
    if (image.isDecoded && cgImage != NULL) {
        NSLog(@"✅ 测试通过：访问 CGImage 时才解码");
    } else {
        NSLog(@"❌ 测试失败：解码失败");
    }

    // 再次访问 CGImage（应该直接返回缓存）
    CGImageRef cgImage2 = image.CGImage;
    if (cgImage == cgImage2) {
        NSLog(@"✅ 测试通过：第二次访问返回缓存的 CGImage");
    } else {
        NSLog(@"❌ 测试失败：第二次访问创建了新的 CGImage");
    }

    NSLog(@"========================================\n");
}

+ (void)testMemoryComparison {
    NSLog(@"\n========================================");
    NSLog(@"测试 3: 内存占用对比");
    NSLog(@"========================================");

    NSData *imageData = [self createTestImageData];

    // 测试 UIImage
    NSLog(@"\n--- UIImage ---");
    NSUInteger uiImageInitial = [self currentMemoryUsage];
    NSLog(@"初始内存: %lu MB", (unsigned long)uiImageInitial);

    UIImage *uiImage = [[UIImage alloc] initWithData:imageData scale:2.0];
    NSUInteger uiImageAfter = [self currentMemoryUsage];
    NSLog(@"创建后内存: %lu MB (+%lu MB)",
          (unsigned long)uiImageAfter,
          (unsigned long)(uiImageAfter - uiImageInitial));

    // 释放 UIImage
    uiImage = nil;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    NSUInteger uiImageReleased = [self currentMemoryUsage];
    NSLog(@"释放后内存: %lu MB (残留 %lu MB)",
          (unsigned long)uiImageReleased,
          (unsigned long)(uiImageReleased - uiImageInitial));

    // 测试 SVGAImage
    NSLog(@"\n--- SVGAImage ---");
    NSUInteger svgaImageInitial = [self currentMemoryUsage];
    NSLog(@"初始内存: %lu MB", (unsigned long)svgaImageInitial);

    SVGAImage *svgaImage = [[SVGAImage alloc] initWithData:imageData scale:2.0];
    NSUInteger svgaImageAfter = [self currentMemoryUsage];
    NSLog(@"创建后内存: %lu MB (+%lu MB)",
          (unsigned long)svgaImageAfter,
          (unsigned long)(svgaImageAfter - svgaImageInitial));

    // 访问 CGImage（触发解码）
    CGImageRef cgImage = svgaImage.CGImage;
    (void)cgImage;
    NSUInteger svgaImageDecoded = [self currentMemoryUsage];
    NSLog(@"解码后内存: %lu MB (+%lu MB)",
          (unsigned long)svgaImageDecoded,
          (unsigned long)(svgaImageDecoded - svgaImageInitial));

    // 释放 SVGAImage
    svgaImage = nil;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    NSUInteger svgaImageReleased = [self currentMemoryUsage];
    NSLog(@"释放后内存: %lu MB (残留 %lu MB)",
          (unsigned long)svgaImageReleased,
          (unsigned long)(svgaImageReleased - svgaImageInitial));

    NSLog(@"========================================\n");
}

+ (void)testBatchLoading {
    NSLog(@"\n========================================");
    NSLog(@"测试 4: 批量加载（20 张图片）");
    NSLog(@"========================================");

    NSData *imageData = [self createTestImageData];

    // 测试 UIImage
    NSLog(@"\n--- UIImage 批量加载 ---");
    NSUInteger uiImageInitial = [self currentMemoryUsage];
    NSLog(@"初始内存: %lu MB", (unsigned long)uiImageInitial);

    NSMutableArray *uiImages = [NSMutableArray array];
    for (int i = 0; i < 20; i++) {
        UIImage *image = [[UIImage alloc] initWithData:imageData scale:2.0];
        [uiImages addObject:image];
    }
    NSUInteger uiImageAfter = [self currentMemoryUsage];
    NSLog(@"加载 20 张后: %lu MB (+%lu MB)",
          (unsigned long)uiImageAfter,
          (unsigned long)(uiImageAfter - uiImageInitial));

    // 释放
    [uiImages removeAllObjects];
    uiImages = nil;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    NSUInteger uiImageReleased = [self currentMemoryUsage];
    NSLog(@"释放后: %lu MB (残留 %lu MB)",
          (unsigned long)uiImageReleased,
          (unsigned long)(uiImageReleased - uiImageInitial));

    // 测试 SVGAImage
    NSLog(@"\n--- SVGAImage 批量加载 ---");
    NSUInteger svgaImageInitial = [self currentMemoryUsage];
    NSLog(@"初始内存: %lu MB", (unsigned long)svgaImageInitial);

    NSMutableArray *svgaImages = [NSMutableArray array];
    for (int i = 0; i < 20; i++) {
        SVGAImage *image = [[SVGAImage alloc] initWithData:imageData scale:2.0];
        [svgaImages addObject:image];
    }
    NSUInteger svgaImageAfter = [self currentMemoryUsage];
    NSLog(@"加载 20 张后: %lu MB (+%lu MB)",
          (unsigned long)svgaImageAfter,
          (unsigned long)(svgaImageAfter - svgaImageInitial));

    // 解码第一张
    SVGAImage *firstImage = svgaImages[0];
    CGImageRef cgImage = firstImage.CGImage;
    (void)cgImage;
    NSUInteger svgaImageDecoded = [self currentMemoryUsage];
    NSLog(@"解码第 1 张后: %lu MB (+%lu MB)",
          (unsigned long)svgaImageDecoded,
          (unsigned long)(svgaImageDecoded - svgaImageInitial));

    // 释放
    [svgaImages removeAllObjects];
    svgaImages = nil;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    NSUInteger svgaImageReleased = [self currentMemoryUsage];
    NSLog(@"释放后: %lu MB (残留 %lu MB)",
          (unsigned long)svgaImageReleased,
          (unsigned long)(svgaImageReleased - svgaImageInitial));

    NSLog(@"\n--- 对比总结 ---");
    NSLog(@"UIImage 加载时内存增长: %lu MB",
          (unsigned long)(uiImageAfter - uiImageInitial));
    NSLog(@"SVGAImage 加载时内存增长: %lu MB",
          (unsigned long)(svgaImageAfter - svgaImageInitial));
    NSLog(@"节省内存: %lu MB (%.1f%%)",
          (unsigned long)((uiImageAfter - uiImageInitial) - (svgaImageAfter - svgaImageInitial)),
          100.0 * (1.0 - (double)(svgaImageAfter - svgaImageInitial) / (double)(uiImageAfter - uiImageInitial)));

    NSLog(@"========================================\n");
}

+ (void)testMemoryRelease {
    NSLog(@"\n========================================");
    NSLog(@"测试 5: 释放后内存");
    NSLog(@"========================================");

    NSData *imageData = [self createTestImageData];

    NSUInteger initialMemory = [self currentMemoryUsage];
    NSLog(@"初始内存: %lu MB", (unsigned long)initialMemory);

    @autoreleasepool {
        // 创建并解码 SVGAImage
        SVGAImage *image = [[SVGAImage alloc] initWithData:imageData scale:2.0];
        CGImageRef cgImage = image.CGImage;
        (void)cgImage;

        NSUInteger afterDecodeMemory = [self currentMemoryUsage];
        NSLog(@"解码后内存: %lu MB (+%lu MB)",
              (unsigned long)afterDecodeMemory,
              (unsigned long)(afterDecodeMemory - initialMemory));
    }

    // 等待自动释放池清理
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    NSUInteger afterReleaseMemory = [self currentMemoryUsage];
    NSLog(@"释放后内存: %lu MB (残留 %lu MB)",
          (unsigned long)afterReleaseMemory,
          (unsigned long)(afterReleaseMemory - initialMemory));

    if (afterReleaseMemory <= initialMemory + 1) {
        NSLog(@"✅ 测试通过：内存完全释放（允许 1MB 误差）");
    } else {
        NSLog(@"⚠️  警告：有 %lu MB 内存未释放",
              (unsigned long)(afterReleaseMemory - initialMemory));
    }

    NSLog(@"========================================\n");
}

#pragma mark - Test Runner

+ (void)runAllTests {
    NSLog(@"\n");
    NSLog(@"╔════════════════════════════════════════╗");
    NSLog(@"║     SVGAImage 测试套件                 ║");
    NSLog(@"╚════════════════════════════════════════╝");

    [self testLazyDecoding];
    [self testOnDemandDecoding];
    [self testMemoryComparison];
    [self testBatchLoading];
    [self testMemoryRelease];

    NSLog(@"\n");
    NSLog(@"╔════════════════════════════════════════╗");
    NSLog(@"║     所有测试完成                       ║");
    NSLog(@"╚════════════════════════════════════════╝");
    NSLog(@"\n");
}

#pragma mark - Helper Methods

/**
 * 创建测试用的图片数据（1x1 像素的 PNG）
 */
+ (NSData *)createTestImageData {
    // 创建一个 1x1 像素的红色图片
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(512, 512), NO, 1.0);
    [[UIColor redColor] setFill];
    UIRectFill(CGRectMake(0, 0, 512, 512));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return UIImagePNGRepresentation(image);
}

@end

/**
 * 使用示例：
 *
 * // 在 AppDelegate 或测试代码中调用
 * [SVGAImageTests runAllTests];
 */
