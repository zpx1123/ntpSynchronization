//
//  ViewController.m
//  jkajsfkjasf
//
//  Created by 周鹏翔 on 15/11/11.
//  Copyright © 2015年 周鹏翔. All rights reserved.
//

#import "ViewController.h"
#import "NetworkClock.h"
#import "KLHttpTool.h"
#import <AVFoundation/AVFoundation.h>
#import "NSObject+BaseObject.h"

@interface ViewController (){
    
    double serverPlayTime;
    double offsetTime;
    
}
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//播放器
@property (weak ,nonatomic) NSTimer *timer;//进度更新定时器
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [NetworkClock sharedInstance];
//    NSTimer * repeatingTimer = [[NSTimer alloc]
//                                initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.001]
//                                interval:1.0 target:self selector:@selector(repeatingMethod:)
//                                userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];
//    
    NSTimer* _timer1=[NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(repeatingMethod:) userInfo:nil repeats:true];
    _timer1.fireDate=[NSDate distantPast];//恢复定时器
    
    sysClockLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 50, 500, 50)];
    netClockLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 150, 500, 50)];
    differenceLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 200, 500, 50)];
    
    statrTime=[[UIButton alloc]initWithFrame:CGRectMake(10, 250, 280, 50)];
    [statrTime setTitle:@"模拟接受播放消息" forState:UIControlStateNormal];
    [statrTime setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [statrTime setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    statrTime.backgroundColor=[UIColor grayColor];
    
    [statrTime addTarget:self action:@selector(Sendclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:statrTime];
    
    [self.view addSubview:sysClockLabel];
    [self.view addSubview:netClockLabel];
    [self.view addSubview:differenceLabel];

    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)Sendclick{
    

    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [KLHttpTool getWithURL:@"http://api3.dance365.com/global/ntptime" params:@{@"id":identifier} success:^(id json) {
        
        NSMutableDictionary * dic=[[NSMutableDictionary alloc]initWithDictionary:json];
        
       serverPlayTime= [[dic objectForKey:@"serverPlay"] doubleValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            double SYStime=(double)[systemTime timeIntervalSince1970];
        double networkT= (double)[networkTime timeIntervalSince1970];
            double nowPlayOffset= serverPlayTime-networkT;
            [self playSong:nowPlayOffset];
        [self popUpAlert:@"okkkk"];
        
        });
     
    } failure:^(NSError *error) {
        
    }];
    
}
-(void)playSong:(double)time{
    

        NSTimer* _tmm = [NSTimer scheduledTimerWithTimeInterval:time
                                                         target:self
                                                       selector:@selector(caculateLeftTimeForTomorrow)
                                                       userInfo:nil
                                                        repeats:NO] ;
    

   
    
}
-(void)caculateLeftTimeForTomorrow{
    
     [self play];
}
- (void) repeatingMethod:(NSTimer *) theTimer {
    systemTime = [NSDate date];
    
//    NSString *timeSp = [NSString stringWithFormat:@"%f", (double)[systemTime timeIntervalSince1970]];

    networkTime = [[NetworkClock sharedInstance] networkTime];
    
//    NSLog(@"------->%@", [NSString stringWithFormat:@"%@", systemTime]);
//     NSLog(@"<-------%@",[NSString stringWithFormat:@"%@", networkTime]);
//    NSLog(@"<------->%@",[NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%5.3f",
//                                                            [networkTime timeIntervalSinceDate:systemTime]]]);
    
    sysClockLabel.text = [NSString stringWithFormat:@"%f", (double)[systemTime timeIntervalSince1970]];
    netClockLabel.text = [NSString stringWithFormat:@"%f", (double)[networkTime timeIntervalSince1970]];
    differenceLabel.text = [NSString stringWithFormat:@"%5.3f",
                            [networkTime timeIntervalSinceDate:systemTime]];
    
    offsetTime=[networkTime timeIntervalSinceDate:systemTime];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









/**
 *  创建播放器
 *
 *  @return 音频播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSString *urlStr=[[NSBundle mainBundle]pathForResource:@"音乐.mp3" ofType:nil];
        NSURL *url=[NSURL fileURLWithPath:urlStr];
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        _audioPlayer.numberOfLoops=0;//设置为0不循环
//        _audioPlayer.delegate=self;
        [_audioPlayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
        //设置后台播放模式
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        //        [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        [audioSession setActive:YES error:nil];
        //添加通知，拔出耳机后暂停播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    }
    return _audioPlayer;
    
}

/**
 *  播放音频
 */
-(void)play{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
        [self.audioPlayer setRate:1.5];
        self.timer.fireDate=[NSDate distantPast];//恢复定时器
    }
}
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return _timer;
}


/**
 *  更新播放进度
 */
-(void)updateProgress{
    float progress= self.audioPlayer.currentTime /self.audioPlayer.duration;
//    [self.playProgress setProgress:progress animated:true];
    NSLog(@"播放进度%f",progress);
}
@end
