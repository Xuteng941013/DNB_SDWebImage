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

/** 图片的缓存池 */
@property (nonatomic,strong) NSMutableDictionary *imagesCache;
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
        //初始化图片缓存池
        self.imagesCache = [NSMutableDictionary dictionary];
    }
    return self;
}


//单例下载的主方法 : 单例封装DownloadOperation的下载代码
- (void)downloadWithURLStr:(NSString *)URLStr successBlock:(void (^)(UIImage *))successBlock{
    
    //下载图片之前判断是否有缓存
    if ([self checkCacheWithURLStr:URLStr] == YES) {
        //如果有,直接把缓存里面的图片回调给VC
        if (successBlock != nil) {
            UIImage *cacheImage = [self.imagesCache objectForKey:URLStr];
            successBlock(cacheImage);
        }
        return;
    }
    
    
    //判断要建立的操作是否已经存在,如果存在,就不在新建操作了
    if ([self.OPCache objectForKey:URLStr] != nil) {
        return;
    }
    
    
    //单例定义代码块,传递给自定义操作
    void(^managerBlock)() =^(UIImage *image) {
        
        //实现图片内存缓存
        if (image != nil) {
            
            [self.imagesCache setObject:image forKey:URLStr];
        }
        
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

- (BOOL)checkCacheWithURLStr:(NSString *)URLStr{
    
    //下载图片之前,判断是否有内存缓存
    if ([self.imagesCache objectForKey:URLStr] != nil) {
        NSLog(@"从内存中加载..");
        return YES;
    }
    
    //下载图片之前,判断是否有沙盒缓存
    //取出沙盒里面的图片,看是否为空,如果为空,则没有沙盒缓存
    UIImage *memImage = [UIImage imageWithContentsOfFile:[URLStr appendCaches]];
    if (memImage != nil) {
        NSLog(@"从沙盒中加载..");
        //在内存缓存里面存一份
        [self.imagesCache setObject:memImage forKey:URLStr];
        return YES;
    }
    
    return NO;
}



- (void)cancelDownloadOperationWithLastURLStr:(NSString *)lastURLStr{
    
    
    //取消上一次正在进行的操作
    [[self.OPCache objectForKey:lastURLStr] cancel];
    
    //把取消的操作从操作缓存池中移除
    [self.OPCache removeObjectForKey:lastURLStr];
    
}

@end
