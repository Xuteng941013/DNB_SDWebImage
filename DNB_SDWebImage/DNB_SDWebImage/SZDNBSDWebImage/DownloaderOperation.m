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

//1.自定义操作实例化的方法
//2.此方法先于mian方法执行
+ (instancetype)downloadWithURLStr:(NSString *)URLStr successBlock:(void (^)(UIImage *))successBlock{
    //1.实例化自定义操作
    DownloaderOperation *op = [[DownloaderOperation alloc] init];
    
    //2.保存图片地址和下载完成回调,就可以在当前类全局使用,把外界传入的数据变成自己的
    op.URLStr = URLStr;
    op.successBlock = successBlock;
    
    //3.返回自定义操作
    return op;
}

/**
 *  重写操作执行的入口方法 : 做你想做的事情,默认就在子线程异步执行的
    一旦队列调度了操作执行,那么操作就会自动的执行main方法
 */
- (void)main{
    NSLog(@"传入..%@",self.URLStr);
    
    //模拟网络延迟
    [NSThread sleepForTimeInterval:1.0];
    
    //下载图片
    NSURL *URLStr = [NSURL URLWithString:self.URLStr];
    NSData *data = [NSData dataWithContentsOfURL:URLStr];
    UIImage *image = [UIImage imageWithData:data];
    
    //判断当前的操作是否已经被取消,如果取消就直接return,不在往下执行
    //注意:这个方法可以在多个地方判断,但是必须能够拦截回调,并且至少在延迟操作的后面有一个判断
    if (self.isCancelled == YES) {
        NSLog(@"取消..%@",self.URLStr);
        return;
    }
    
    //断言
    NSAssert(self.successBlock != nil, @"回到的block不能为空");
    
    //图片下载完成后,通知主线程刷新UI
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //执行完这行代码,VC里面的successBlock就会执行,并拿到image
        //注意:在哪个线程回调代码块,那么代码块就在哪个线程执行,代理通知也是这样的
        NSLog(@"完成..%@",self.URLStr);
        self.successBlock(image);
    }];
    
}



@end
