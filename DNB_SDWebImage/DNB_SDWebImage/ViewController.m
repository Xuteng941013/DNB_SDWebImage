//
//  ViewController.m
//  DNB_SDWebImage
//
//  Created by 徐腾 on 2016/10/24.
//  Copyright © 2016年 徐腾. All rights reserved.
//

#import "ViewController.h"
#import "DownloaderOperation.h"
#import "AFNetworking.h"
#import "YYModel.h"
#import "APPModel.h"



@interface ViewController ()

/** 全局队列 */
@property (strong,nonatomic) NSOperationQueue *queue;

/** 数据源数组 */
@property (nonatomic,strong) NSArray *appList;

/** 展示图片 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

/** 操作缓存池 */
@property (nonatomic,strong) NSMutableDictionary *OPCache;

/** 记录上一次图片的地址 */
@property (nonatomic,copy) NSString *lastURLStr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载数据
    [self loadJSONData];
    
    //初始化全局队列
    self.queue = [[NSOperationQueue alloc] init];
    
    //初始化操作缓存池
    self.OPCache = [NSMutableDictionary dictionary];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //1.生成随机数
    int randow = arc4random_uniform((u_int32_t)self.appList.count);
    
    APPModel *app = self.appList[randow];
    
    //2.判断当前图片的地址和上一次图片的地址是否一样,如果不一样就取消上一次正在执行的下载操作
    //cancel : 仅仅是改变了操作的状态而已,并没有真正的取消这个操作
    if (![app.icon isEqualToString:self.lastURLStr] && self.lastURLStr != nil) {
        
        //取消上一次正在进行的操作
        [[self.OPCache objectForKey:self.lastURLStr] cancel];
        
        //把取消的操作从操作缓存池中移除
        [self.OPCache removeObjectForKey:self.lastURLStr];
    }
    
    //记录本次的图片的地址,当再次点击的时候,它自然而然就是上次的地址了
    self.lastURLStr = app.icon;
    
    //3.创建自定义操作
    DownloaderOperation *op = [DownloaderOperation downloadWithURLStr:app.icon successBlock:^(UIImage *image) {
        //刷新界面
        self.iconImageView.image = image;
        
        //图片添加完后,移除操作
        [self.OPCache removeObjectForKey:app.icon];
    }];
    
    //4.将操作添加到操作缓存池中
    [self.OPCache setObject:op forKey:app.icon];
    
    //5.将自定义操作添加到队列中
    [self.queue addOperation:op];
}



#pragma mark-获取json数据的主方法
/*
 测试框架是否可行,当获取到appList数据之后,再点击屏幕,实现图片的下载和展示
 */
- (void)loadJSONData
{
    // 1.创建网络请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 2.使用网络请求管理者,发送网络请求获取json数据;
    // GET方法默认是在子线程异步执行的,当AFN获取到网络数据之后,success回调是自动的默认在主线程执行的
    [manager GET:@"https://raw.githubusercontent.com/zhangxiaochuZXC/SZiOS07_FerverFile/master/apps.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // responseObject就是字典数组 (AFN自动实现字典转模型)
        NSArray *dictArr = responseObject;
        // 实现字典转模型 : 字典数组转模型数组
        self.appList = [NSArray yy_modelArrayWithClass:[APPModel class] json:dictArr];
        NSLog(@"%@",self.appList);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}




@end
