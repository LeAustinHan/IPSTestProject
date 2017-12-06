//
//  ViewController.m
//  IPSTestProject
//  进入设置应用静音，当前页面，用户修改音量直接设置静音。
//  Created by Han Jize on 2017/12/5.
//  Copyright © 2017年 Han Jize. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry/Masonry.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self sendWebView];
    
    UIButton *silenceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    silenceButton.frame = CGRectMake(100, 550, 200, 40);
    [silenceButton setTitle:@"安静" forState:UIControlStateNormal];
    silenceButton.backgroundColor = [UIColor redColor];
    [silenceButton addTarget:self action:@selector(resetSilence) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:silenceButton];
    
    // 防止block中的循环引用
    __weak typeof (self) weakSelf = self;
    // 使用mas_makeConstraints添加约束
    [silenceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100);
        make.top.mas_equalTo(550);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(200);
    }];
    
    
    UIButton *loudButton = [UIButton buttonWithType:UIButtonTypeSystem];
    loudButton.frame = CGRectMake(100, 600, 200, 40);
    [loudButton setTitle:@"大声" forState:UIControlStateNormal];
    loudButton.backgroundColor = [UIColor orangeColor];
    [loudButton addTarget:self action:@selector(resetLoud) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loudButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (void)sendWebView{
    //设置webview
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 500)];
    [self.view addSubview:webView];
    NSURL* url = [NSURL URLWithString:@"http://10.4.0.242/"];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [webView loadRequest:request];
}

//设置静默（不是设置静音开关）
- (void)resetSilence{
    
    MPVolumeView *volumeView = nil;
    //防止重复加载
    for (UIView *view in [self.view subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeView"]){
            volumeView = (MPVolumeView *)view;
            break;
        }
    }
    if (volumeView == nil) {
        //volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -100, 10, 10)];
        volumeView = [[MPVolumeView alloc] init];
    }
    
    /**********核心功能**************/
    //请注意这里的设置，保证声控视图隐藏起来
    //[volumeView sizeToFit];
    volumeView.hidden = NO;
    //volumeView.showsVolumeSlider  = NO;
    //volumeView.showsRouteButton = NO;
    //请注意此处，将声控视图布置到view上。
    [self.view addSubview:volumeView];
    //此处为遍历视图层级，找出声控视图逻辑
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    [volumeViewSlider setValue:0.0];//设置静音，音量为0
    //为了保证声控视图不显示，不可以立即移除视图
    //[self performSelector:@selector(remoVolumeView:) withObject:volumeView afterDelay:3.0];
}

//恢复大声
- (void)resetLoud{
    MPVolumeView *volumeView = nil;
    //防止重复加载
    for (UIView *view in [self.view subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeView"]){
            volumeView = (MPVolumeView *)view;
            break;
        }
    }
    if (volumeView == nil) {
        //volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -100, 10, 10)];
        volumeView = [[MPVolumeView alloc] init];
    }
    
    //请注意这里的设置，
    //[volumeView setFrame:CGRectMake(-1000, -100, 1, 1)];
    //[volumeView sizeToFit];
    volumeView.hidden = NO;
    //volumeView.showsVolumeSlider = NO;
    //volumeView.showsRouteButton = NO;
    //请注意此处，将声控视图布置到view上。
    [self.view addSubview:volumeView];
    
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    //此种方法不可行
    float currentVolume = volumeViewSlider.value;
    NSLog(@"当前音量 %f",currentVolume);
    
    [volumeViewSlider setValue:0.2];
    //为了保证声控视图不显示，不可以立即移除视图
    //[self performSelector:@selector(remoVolumeView:) withObject:volumeView afterDelay:2.0];
}

- (void)remoVolumeView:(UIView *)volumeView{
    if (volumeView) {
        [volumeView removeFromSuperview];
    }
}

//系统声音改变处理
- (void)volumeChanged:(NSNotification *)notification{
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    NSLog(@"XES--当前系统音量--%f", volume);
    //当前交互，接收到用户修改声音设置成静默
    [self resetSilence];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
