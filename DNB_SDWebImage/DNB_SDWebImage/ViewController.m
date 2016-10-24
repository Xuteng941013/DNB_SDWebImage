//
//  ViewController.m
//  DNB_SDWebImage
//
//  Created by 徐腾 on 2016/10/24.
//  Copyright © 2016年 徐腾. All rights reserved.
//

#import "ViewController.h"
#import "DownloaderOperation.h"

@interface ViewController ()

/**
 *  全局队列
 */
@property (strong,nonatomic) NSOperationQueue *queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化全局队列
    self.queue = [[NSOperationQueue alloc] init];
    
    NSString *urlStr = @"http://i9.pdim.gs/096c33ac7af85390fa40c8b2151607d8.jpeg";
    
    //创建自定义操作
    DownloaderOperation *op = [DownloaderOperation downloadWithURLStr:urlStr successBlock:^(UIImage *image) {
        
        NSLog(@"%@---%@",image,[NSThread currentThread]);
    }];
    
    //将自定义操作添加到队列中
    [self.queue addOperation:op];
    
}


@end
