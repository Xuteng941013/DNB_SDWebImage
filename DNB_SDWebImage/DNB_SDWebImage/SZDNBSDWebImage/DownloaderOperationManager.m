//
//  DownloaderOperationManager.m
//  DNB_SDWebImage
//
//  Created by 徐腾 on 2016/10/24.
//  Copyright © 2016年 徐腾. All rights reserved.
//

#import "DownloaderOperationManager.h"

@interface DownloaderOperationManager ()

/** 操作缓存池 */
@property (nonatomic,strong) NSMutableDictionary *OPCache;

/** 全局队列 */
@property (strong,nonatomic) NSOperationQueue *queue;

@end

@implementation DownloaderOperationManager

+ (instancetype)sharedManager{
    
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    
    if (self = [super init]) {
        //初始化操作池
        self.OPCache = [NSMutableDictionary dictionary];
        //初始化队列
        self.queue = [[NSOperationQueue alloc] init];
    }
    return self;
}


//单例下载的主方法 : 单例封装DownloadOperation的下载代码
- (void)downloadWithURLStr:(NSString *)URLStr successBlock:(void (^)(UIImage *))successBlock{
    
    //单例定义代码块,传递给自定义操作
    void(^managerBlock)() =^(UIImage *image) {
        //回调VC传递给单例的代码块,把下载的image传递给VC
        if (successBlock !=nil) {
            //执行完这行代码,VC里面的successBlock就会执行,拿到image
            successBlock(image);
        }
            
        //图片添加完后,移除操作
        [self.OPCache removeObjectForKey:URLStr];
    };
    
    
    //创建自定义操作
    DownloaderOperation *op = [DownloaderOperation downloadWithURLStr:URLStr successBlock:managerBlock];
    
    //将操作添加到操作缓存池中
    [self.OPCache setObject:op forKey:URLStr];
    
    //将自定义操作添加到队列中
    [self.queue addOperation:op];
    
    
}


@end
