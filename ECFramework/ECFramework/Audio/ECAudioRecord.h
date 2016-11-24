//
//  ECAudioRecord.h
//  JarvisRobot
//
//  Created by 陈冠杰 on 16/7/14.
//  Copyright © 2016年 EzioChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAudioRecorder;
@class AVAudioPlayer;

@protocol ECAudioRecordDelegate <NSObject>

@optional

-(void)audioVoicePower:(float )progress;

@end

@interface ECAudioRecord : NSObject


@property (nonatomic,strong) AVAudioRecorder*   audioRecorder;
@property (nonatomic,strong) AVAudioPlayer*     audioPlayer;
@property (nonatomic,strong) NSTimer*           recorderTimer;
@property (nonatomic,strong) NSString*          recordPath;
@property (nonatomic,assign) id<ECAudioRecordDelegate>  delegate;



+(id)sharedInstance;

/**
 *  设置代理
 *
 *  @param delegate ViewController
 */
-(void)setECAudioDelegate:(id)delegate;

/**
 *  设置录音保存的路径
 */
-(void)setSavePath;

/**
 *  获取录音文件的存储路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath;

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
         PCMIsBigEndianKey:(BOOL) isBigEndianKey;

/**
 *  获得当前的录音设置
 *
 *  @return dictionary
 */
-(NSDictionary *)getAudioSetting;

/**
 *  获取录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder;

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer;


/**
 *  开始录音
 */
-(void)startToRecord;

/**
 *  停止录音
 */
-(void)stopToRecord;

/**
 *  暂停录音
 */
-(void)pauseToRecord;

/**
 *  恢复继续录音
 *  恢复录音只需要再次调用record，AVAudioSession 会帮你从上次记录的位置追加录音
 */
-(void)continuanceToRecord;


@end
