//
//  ECAudioUnit.h
//  ECFramework
//
//  Created by Ezio on 08/03/2018.
//  Copyright © 2018 EzioChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

#define nBuffers 3
#define e_Sample 16
#define e_Rate 8000
#define e_Channel 1
#define e_BitPerChannel (sizeof(eSample)*8)
#define e_BytesPerFrame (e_Channel * sizeof(e_Sample))
#define e_FrameSize 512

typedef struct AQCallbackStruct
{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         mBuffers[nBuffers];
    AudioFileID                 outputFile;
    unsigned long               frameSize;
    long long                   recPtr;
    int                         run;
    
} AQCallbackStruct;

@interface ECAudioUnit : NSObject
{
    AQCallbackStruct aqc;
    AudioFileTypeID fileFormat;
}

@property (nonatomic, assign) AQCallbackStruct aqc;
@property (nonatomic, assign) long audioDataLength;

- (id) initWithAudioDescription:(AudioStreamBasicDescription) audioFormat;
- (void) didstartRecord;
- (void) didstopRecord;
- (void) didpause;
- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue;

@end
