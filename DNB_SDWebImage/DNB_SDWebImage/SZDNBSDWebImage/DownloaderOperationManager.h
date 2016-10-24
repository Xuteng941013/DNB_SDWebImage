//
//  DownloaderOperationManager.h
//  DNB_SDWebImage
//
//  Created by 徐腾 on 2016/10/24.
//  Copyright © 2016年 徐腾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DownloaderOperation.h"

@interface DownloaderOperationManager : NSObject

/**
 *  单例全局访问点
 *
 *  @return 返回单例对象
 */
+ (instancetype)sharedManager;

/**
 单例下载的方法
 
 @param URLStr       接收外界传入的图片地址
 @param successBlock 接收外界传入的下载完成回调
 */
- (void)downloadWithURLStr:(NSString *)URLStr successBlock:(void(^)(UIImage *image))successBlock;


@end
