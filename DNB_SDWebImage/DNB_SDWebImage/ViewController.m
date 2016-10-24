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
#import "DownloaderOperationManager.h"


@interface ViewController ()

/** 数据源数组 */
@property (nonatomic,strong) NSArray *appList;

/** 展示图片 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

/** 记录上一次图片的地址 */
@property (nonatomic,copy) NSString *lastURLStr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载数据
    [self loadJSONData];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //1.生成随机数
    int randow = arc4random_uniform((u_int32_t)self.appList.count);
    
    APPModel *app = self.appList[randow];
    
    //2.判断当前图片的地址和上一次图片的地址是否一样,如果不一样就取消上一次正在执行的下载操作
    //cancel : 仅仅是改变了操作的状态而已,并没有真正的取消这个操作
    if (![app.icon isEqualToString:self.lastURLStr] && self.lastURLStr != nil) {
        //单例接管取消操作
        [[DownloaderOperationManager sharedManager] cancelDownloadOperationWithLastURLStr:self.lastURLStr];
    }
    
    //记录本次的图片的地址,当再次点击的时候,它自然而然就是上次的地址了
    self.lastURLStr = app.icon;
    
    
    //单例接管下载 : 取消操作暂时失效
    [[DownloaderOperationManager sharedManager] downloadWithURLStr:app.icon successBlock:^(UIImage *image) {
        
        self.iconImageView.image = image;
    }];
    
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
