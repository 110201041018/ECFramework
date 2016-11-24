//
//  ECAudioRecord.m
//  JarvisRobot
//
//  Created by 陈冠杰 on 16/7/14.
//  Copyright © 2016年 EzioChen. All rights reserved.
//

#import "ECAudioRecord.h"
#import <AVFoundation/AVFoundation.h>
#import "ECLog.h"

#define ecRecordAudioFile @"myRecord.caf" //默认保存的音频文件格式

static ECAudioRecord *audioMedia;

@interface ECAudioRecord()<AVAudioRecorderDelegate>{

    NSURL  *audioSavePath;
    NSMutableDictionary *audioSetDict;
}



@end

@implementation ECAudioRecord



+(id)sharedInstance{
    @synchronized ([ECAudioRecord class]) {
        if (audioMedia == nil) {
            audioMedia = [[ECAudioRecord alloc] init];
        }
    }
    return audioMedia;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        [self setAudioSession];
    }
    
    return self;
}

/**
 *  设置代理
 *
 *  @param delegate ViewController
 */
-(void)setECAudioDelegate:(id)delegate{

    _delegate = delegate;
    
}

/**
 *  设置音频会话Session
 */
-(void)setAudioSession{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置为播放和录音状态们可以在录音完成之后播放录音。
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
}

/**
 *  设置录音保存的路径
 */
-(void)setSavePath{

    if (_recordPath) {
        NSString *urlPath = [_recordPath stringByAppendingPathComponent:ecRecordAudioFile];
        audioSavePath = [NSURL URLWithString:urlPath];
    }else{
        NSLog(@"error! recordPath is nil");
    }
    
}

/**
 *  获取录音文件的存储路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    
    if(_recordPath){
        NSString *urlPath = [_recordPath stringByAppendingPathComponent:ecRecordAudioFile];
        audioSavePath = [NSURL URLWithString:urlPath];
        return audioSavePath;
    }else{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *urlPath = [path stringByAppendingPathComponent:ecRecordAudioFile];
        NSURL *audioPath = [NSURL URLWithString:urlPath];
        return audioPath;
    }

}


/**
 *  设置录音参数
 *
 *  @param FormatKey      录音格式
 *  @param rateKey        采样率
 *  @param channel        通道
 *  @param pcmbit         采样点
 *  @param isBigEndianKey 是否采用突出点采样
 *
 */
-(void)setAudioSettingWith:(NSUInteger) FormatKey
                   RateKey:(NSUInteger) rateKey
                ChannelKey:(NSUInteger) channel
               PCMBitDepth:(NSUInteger) pcmbit
         PCMIsBigEndianKey:(BOOL) isBigEndianKey
{
    
    audioSetDict = [NSMutableDictionary dictionary];
    
    [audioSetDict setObject:@(FormatKey) forKey:AVFormatIDKey];
    [audioSetDict setObject:@(rateKey) forKey:AVSampleRateKey];
    [audioSetDict setObject:@(channel) forKey:AVNumberOfChannelsKey];
    [audioSetDict setObject:@(pcmbit) forKey:AVLinearPCMBitDepthKey];
    [audioSetDict setObject:@(isBigEndianKey) forKey:AVLinearPCMIsBigEndianKey];
    
}

/**
 *  获得当前的录音设置
 *
 *  @return dictionary
 */
-(NSDictionary *)getAudioSetting{

    if (audioSetDict == nil) {
        /*** 设置录音文件 ***/
        NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        //设置录音采样率，8000是电话采样率，对于一般录音已经够了
        [recordSetting setValue:@(8000) forKey:AVSampleRateKey];
        //设置通道,这里采用单声道
        [recordSetting setValue:@(1) forKey:AVNumberOfChannelsKey];
        //每个采样点位数,分为8、16、24、32
        [recordSetting setValue:@(16) forKey:AVLinearPCMBitDepthKey];
         //是否使用浮点数采样
        [recordSetting setValue:@(false) forKey:AVLinearPCMIsFloatKey];
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];//录音的质量
        
        return recordSetting;
        
    }else{
        
        return audioSetDict;
        
    }
    
    
}


/**
 *  获取录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{

    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url = [self getSavePath];
        //创建录音格式设置
        NSDictionary *settingDict = [self getAudioSetting];
        //创建录音机
        NSError *err = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settingDict error:&err];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        if (err) {
            NSLog(@"创建录音机对象发生错误了，错误信息：%@",err.localizedDescription);
            return nil;
        }
    }
    
    return _audioRecorder;
}


/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{

    if (!_audioPlayer) {
        NSURL *url = [self getSavePath];
        NSError *err = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
        _audioPlayer.numberOfLoops = 0;
        [_audioPlayer prepareToPlay];
        
        if (err) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",err.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}





/**
 *  录音声波监控定时器
 *
 *  @return 定时器
 */
-(NSTimer *)audioTimer{

    if (!_recorderTimer) {
        _recorderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    
    return _recorderTimer;
}



/**
 *  录音状态反馈
 */
-(void)audioPowerChange{
    //更新测量值S
    [self.audioRecorder updateMeters ];
    //取得第一个通道的音频（注意音频强度范围是：-160~0）
    float power = [self.audioRecorder averagePowerForChannel:0];
    float progress = (1.0/160.0) * (power + 160.0);
    
    [self setPower:progress];
    
}


-(void)setPower:(float)progress{
    
    if ([_delegate respondsToSelector:@selector(audioVoicePower:)]) {
        [_delegate audioVoicePower:progress];
    }
}



#pragma  mark <控制录音相关接口>

/**
 *  开始录音
 */
-(void)startToRecord{

    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];
        //恢复定时器
        self.recorderTimer.fireDate = [NSDate distantPast];
    
    }else{
        
        ECLogs(@"请先停止录音");
    }
}

/**
 *  停止录音
 */
-(void)stopToRecord{

    [self.audioRecorder stop];
    self.recorderTimer.fireDate=[NSDate distantFuture];
    [self setPower:0.0];

}

/**
 *  暂停录音
 */
-(void)pauseToRecord{

    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.recorderTimer.fireDate=[NSDate distantFuture];
    }else{
        
        ECLogs(@"请先进入录音模式");
        
    }
}

/**
 *  恢复继续录音
 *  恢复录音只需要再次调用record，AVAudioSession 会帮你从上次记录的位置追加录音
 */
-(void)continuanceToRecord{

    [self startToRecord];
}


#pragma  mark <接收AVAudioSession delegate>

//录音完成
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{

    
}





@end
