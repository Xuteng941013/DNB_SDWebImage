//
//  DownloaderOperation.h
//  DNB_SDWebImage
//
//  Created by 徐腾 on 2016/10/24.
//  Copyright © 2016年 徐腾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSString+path.h"

@interface DownloaderOperation : NSOperation

/**
 *  类方法实例化操作,并传入图片的地址和下载完成回调
 *
 *  @param URLStr       图片的地址
 *  @param successBlock 下载完成的回调
 *
 *  @return 返回自定义操作对象
 */
+ (instancetype)downloadWithURLStr:(NSString *)URLStr successBlock:(void(^)(UIImage * image))successBlock;

@end
