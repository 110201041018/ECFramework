//
//  ECtcpClient.m
//  ECFramework
//
//  Created by 陈冠杰 on 23/11/2016.
//  Copyright © 2016 EzioChen. All rights reserved.
//

#import "ECtcpClient.h"
#import "ECLog.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface ECtcpClient()<GCDAsyncSocketDelegate>{

}

@end

@implementation ECtcpClient

@synthesize clientSocket;

- (instancetype)initWith:(NSString *)address onPort:(NSInteger) port
{
    self = [super init];
    if (self) {

        clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        NSError *error;
        if (![clientSocket connectToHost:address onPort:port error:&error]) {
            
            NSLog(@"connect failed:%@",error);
            
        }else{
            
            ECLogs(@"Create succeed:%@",clientSocket);
            
        }
        
    }
    return self;
}


-(void)sendToServerWithData:(NSData *) data{

    [clientSocket writeData:data withTimeout:-1 tag:1];
    
}

#pragma mark <- TCP_Delegate ->
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
    ECLogs(@"Connect succeed:%@",clientSocket);
    [clientSocket readDataWithTimeout:-1 tag:1];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{

    ECLogs(@"get Data From server");
    if ([_delegate respondsToSelector:@selector(clientDidReadData:formClient:)]) {
        [_delegate clientDidReadData:data formClient:_clientTag];
    }
    
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{

    NSLog(@"Client disconnect because of %@",err);
    
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{

    [clientSocket readDataWithTimeout:-1 tag:1];
    ECLogs(@"client send over");
}





@end
