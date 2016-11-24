//
//  ECtcpClient.h
//  ECFramework
//
//  Created by 陈冠杰 on 23/11/2016.
//  Copyright © 2016 EzioChen. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ECtcpClientDelegate <NSObject>

-(void)clientDidReadData:(NSData *)data formClient:(NSInteger) clientTag;

@end


@class GCDAsyncSocket;


@interface ECtcpClient : NSObject

@property(nonatomic,assign) NSInteger                   clientTag;
@property(nonatomic,strong) GCDAsyncSocket              *clientSocket;
@property(nonatomic,assign) id<ECtcpClientDelegate>     delegate;

- (instancetype)initWith:(NSString *)address onPort:(NSInteger) port;
- (void)sendToServerWithData:(NSData *) data;
@end
