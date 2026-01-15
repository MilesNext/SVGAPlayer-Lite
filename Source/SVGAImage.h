//
//  SVGAImage.h
//  SVGAPlayer
//
//  Created by ourtalk on 1/15/26.
//  Copyright © 2026 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * SVGAImage 是 UIImage 的子类，实现了延迟解码和按需解码机制
 *
 * 核心特性：
 * 1. 延迟解码：创建时不立即解码图片，只保存原始数据
 * 2. 按需解码：只在访问 CGImage 时才进行解码
 * 3. 强制解码：解码到自己的位图，避免 ImageIO 缓存残留
 * 4. 内存可控：释放时立即回收内存，无残留
 */
@interface SVGAImage : UIImage

/**
 * 使用图片数据创建 SVGAImage（延迟解码）
 * @param data 图片数据（PNG、JPEG 等）
 * @param scale 图片缩放比例（通常为 2.0 或 3.0）
 * @return SVGAImage 实例
 */
- (nullable instancetype)initWithData:(NSData *)data scale:(CGFloat)scale;

/**
 * 使用图片数据创建 SVGAImage（延迟解码，默认 scale = 1.0）
 * @param data 图片数据
 * @return SVGAImage 实例
 */
- (nullable instancetype)initWithData:(NSData *)data;

/**
 * 是否已经解码
 */
@property (nonatomic, readonly) BOOL isDecoded;

@end

NS_ASSUME_NONNULL_END
