//
//  ECAudioUnit.m
//  ECFramework
//
//  Created by Ezio on 08/03/2018.
//  Copyright © 2018 EzioChen. All rights reserved.
//

#import "ECAudioUnit.h"

@interface ECAudioUnit(){
    @package
    void (^_inputCallbackBlock)(void *inPCMData,UInt32 inSize);
    void (^_outputCallbackBlock)(void *outPCMData,UInt32 inOutSize);
}

@property (nonatomic,assign)OSStatus ossStatus;
@property (nonatomic,readwrite) AudioUnit audioUnit;

@end


OSStatus inputCallBack(void *                     inRefCon,
                       AudioUnitRenderActionFlags *ioActionFlags,
                       const AudioTimeStamp       *inTimeStamp,
                       UInt32                     inBusNumber,
                       UInt32                     inNumberFrames,
                       AudioBufferList * __nullable ioData){
    ECAudioUnit *device = (__bridge ECAudioUnit *)(inRefCon);
    
    OSStatus status;
    AudioStreamBasicDescription asbd;
    UInt32 size = sizeof(AudioStreamBasicDescription);
    status = AudioUnitGetProperty(device.audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output, inBusNumber, &asbd,
                                  &size);
    if (status != noErr) {
        return status;
    }
    
    AudioBufferList bl;
    ioData = &bl;
    ioData->mNumberBuffers = 1;
    ioData->mBuffers[0].mDataByteSize = asbd.mBytesPerFrame * inNumberFrames;
    ioData->mBuffers[0].mNumberChannels = asbd.mChannelsPerFrame;
    ioData->mBuffers[0].mData = NULL;
    
    status = AudioUnitRender(device.audioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
    if (status != noErr) {
        return status;
    }
    
    if (device->_inputCallbackBlock) {
        device->_inputCallbackBlock(ioData->mBuffers[0].mData, ioData->mBuffers[0].mDataByteSize);
    }
    
    return noErr;
}

OSStatus outputCallBack( void *                           inRefCon,
                        AudioUnitRenderActionFlags *      ioActionFlags,
                        const AudioTimeStamp *            inTimeStamp,
                        UInt32                            inBusNumber,
                        UInt32                            inNumberFrames,
                        AudioBufferList * __nullable      ioData) {
    
    ECAudioUnit *device = (__bridge ECAudioUnit*)inRefCon;
    
    UInt32 size = 0;
    if (device->_outputCallbackBlock) {
        size = ioData->mBuffers[0].mDataByteSize;
        device->_outputCallbackBlock(ioData->mBuffers[0].mData,
                                     &size);
    }
    
    memset(ioData->mBuffers[0].mData + size, 0, ioData->mBuffers[0].mDataByteSize - size);
    
    return noErr;
}


@implementation ECAudioUnit



- (id) initWithAudioDescription:(AudioStreamBasicDescription) audioFormat{
    self = [super init];
    if (self) {
        
        
    }
    
    return self;
}

-(void)dealloc{
    
    AudioComponentInstanceDispose(_audioUnit);
}

-(AudioUnit)audioUnit{
    
    if (!_audioUnit) {
        _audioUnit = [self createAudioUnitInstance];
    }
    return _audioUnit;
}




- (AudioUnit)createAudioUnitInstance {
    OSStatus status;
    
    AudioUnit unit;
    AudioComponentDescription audioComponentDesc;
    AudioComponent audioComp;
    
    audioComponentDesc.componentType = kAudioUnitType_Output;
    audioComponentDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioComponentDesc.componentFlags = 0;
    audioComponentDesc.componentFlagsMask = 0;
#if TARGET_IPHONE_SIMULATOR
    audioComponentDesc.componentSubType = kAudioUnitSubType_RemoteIO;
#elif TARGET_OS_IPHONE
    audioComponentDesc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
#endif
    audioComp = AudioComponentFindNext(NULL, &audioComponentDesc);
    if (audioComp == NULL) {
        return nil;
    }
    status = AudioComponentInstanceNew(audioComp, &unit);
    if (status != noErr) {
        return nil;
    }
    
    return unit;
}



@end
