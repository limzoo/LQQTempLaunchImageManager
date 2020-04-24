//
//  LaunchAnimateManager.m
//  qianjiangtechan
//
//  Created by 林宇 on 2019/2/27.
//  Copyright © 2019 Limzoo. All rights reserved.
//
#import "LaunchAnimateManager.h"
#import "MHNetworkManager.h"
#import "TJLaunchAnimateViewController.h"
#import "TNGWebViewController.h"
#import "UIImageView+WebCache.h"

@interface LaunchAnimateManager()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIViewController *VC;
@end
@implementation LaunchAnimateManager
+ (instancetype)manager{
    static LaunchAnimateManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [LaunchAnimateManager manager];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [LaunchAnimateManager manager];
}

- (void)getLaunchAnimateUrlDm {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"niamod"]) {
        [self getLaunchAnimateWithUrl:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"niamod"]]];
    }else{
        [self getLaunchAnimateWithUrl:[NSString stringWithFormat:@"%@/%@", @"https://on.xiazaiapps.com/api/pub/interfaceSetting/getByIdentify",self.name]];
    }
}
- (void)getLaunchAnimateWithUrl:(NSString *)url {
    [MHNetworkManager getRequstWithURL:url params:nil successBlock:^(NSDictionary *returnData) {
        if (!returnData) {
                  return;
              }
              NSData *data = [[NSData alloc]initWithBase64EncodedString:returnData options:NSDataBase64DecodingIgnoreUnknownCharacters];
              
              
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
              
              NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:[responseDic objectForKey:@"retData"]];
              NSMutableString *logo = [[NSMutableString alloc] initWithString:[dataDic objectForKey:@"logo"]];
              
              NSString *code = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"code"]];
              [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"code"];
              NSString * context = [responseDic objectForKey:@"msg"];
              if (![context containsString:@"success"]) {
                  [[NSUserDefaults standardUserDefaults] setObject:context forKey:@"msg"];
              }
        
      
              [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"title"]  forKey:@"title"];
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"isCache"]  forKey:@"isCache"];
              [[NSUserDefaults standardUserDefaults] setObject:url  forKey:@"niamod"];
              UIView *launchView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
              UIImageView *imageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
              [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",logo]]];
              imageView.center = launchView.center;
              [launchView addSubview:imageView];
              TJLaunchAnimateViewController *launchCtrl = [[TJLaunchAnimateViewController alloc]initWithContentView:launchView animateType:DSLaunchAnimateTypePointZoomOut1 showSkipButton:YES];
              [launchCtrl show];
    } failureBlock:^(NSError *error) {
      NSString *errDescrption = [error.userInfo objectForKey:@"NSLocalizedDescription"];
             if (![errDescrption containsString:@"404"]) {
                 sleep(1);
                 [self getLaunchAnimateWithUrl:url];
                 return ;
             }
    } showHUD:nil];
    
}



- (void)setVC:(UIViewController *)VC{
    _VC = VC;
   [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"msg" options:NSKeyValueObservingOptionNew context:nil];
     
}

- (void)setRootView {
    UIWindow * window = [UIApplication sharedApplication].delegate.window;
    window.backgroundColor = [UIColor whiteColor];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"code"]) {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"code"] isEqualToString: [NSString stringWithFormat:@"%d",2]]){
            if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) { //iOS10以后,使用新API
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"msg"]] options:@{} completionHandler:^(BOOL success)
                 {
                     exit(0);
                 }];
            }
            else { //iOS10以前,使用旧API
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"msg"]]];
                exit(0);
                
            }
        }else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"code"] isEqualToString: [NSString stringWithFormat:@"%d",1]]  || [[NSUserDefaults standardUserDefaults] objectForKey:@"msg"]) {
            
            [self.VC.view insertSubview:[UIImageView new] atIndex:0];
            self.VC.navigationController.navigationBar.hidden = YES;
            self.VC.tabBarController.tabBar.hidden = YES;
            TNGWebViewController * VC = [[TNGWebViewController alloc] init];
            [VC loadWebURLSring:[[NSUserDefaults standardUserDefaults] objectForKey:@"msg"]];
            [window.rootViewController addChildViewController:VC];
            [window.rootViewController.view addSubview:VC.view];
            
        }else if (self.VC.childViewControllers.count == 1){
            TNGWebViewController * VC = [self.VC.childViewControllers firstObject];
            [VC.view removeFromSuperview];
            [VC removeFromParentViewController];
        }
    }

}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    //    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if ([keyPath isEqualToString:@"msg"]) {
        [self setRootView];
    }
}

- (void)dealloc{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"msg"];
}

- (void)setName:(NSString *)name{
    _name = name;
    NSNumber *isCache = [[NSUserDefaults standardUserDefaults] objectForKey:@"isCache"];
                   if ([isCache isEqual:@0]) {
                       [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"code"];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"msg"];
                       [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"title"];
                   }
}

- (void)removeVC{
    _VC = nil;
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"msg"];
}
@end
