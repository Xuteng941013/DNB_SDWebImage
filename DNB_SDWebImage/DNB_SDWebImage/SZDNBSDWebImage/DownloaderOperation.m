//
//  DownloaderOperation.m
//  DNB_SDWebImage
//
//  Created by 徐腾 on 2016/10/24.
//  Copyright © 2016年 徐腾. All rights reserved.
//

#import "DownloaderOperation.h"

@interface DownloaderOperation ()

//接收外界传入的地址
@property (nonatomic,strong) NSString *URLStr;
//接收外界传入的block
@property (nonatomic,strong) void(^successBlock)(UIImage *image);

@end


@implementation DownloaderOperation

+ (instancetype)downloadWithURLStr:(NSString *)URLStr successBlock:(void (^)(UIImage *))successBlock{
    DownloaderOperation *op = [[DownloaderOperation alloc] init];
    
    op.URLStr = URLStr;
    op.successBlock = successBlock;
    
    return op;
}


- (void)main{
    
    //下载图片
    NSURL *URLStr = [NSURL URLWithString:self.URLStr];
    NSData *data = [NSData dataWithContentsOfURL:URLStr];
    UIImage *image = [UIImage imageWithData:data];
    
    //断言
    NSAssert(self.successBlock != nil, @"回到的block不能为空");
    
    //图片下载完成后,通知主线程刷新UI
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        self.successBlock(image);
    }];
    
}



@end
