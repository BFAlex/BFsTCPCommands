//
//  AmbaMachine.h
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmbaCommand.h"

NS_ASSUME_NONNULL_BEGIN

@class AmbaMachine;
@protocol AmbaMachineDelegate <NSObject>

@optional
- (void)ambaMachine:(AmbaMachine *)machine didUpdateConnectionStatus:(BOOL)isConnected  forStream:(NSStream *)pStream;

@end

@interface AmbaMachine : NSObject

@property (nonatomic, weak) id<AmbaMachineDelegate> delegate;
@property (nonatomic, assign) BOOL isConnected;

+ (instancetype)sharedMachine;
- (void)destoryMachine;
//
- (void)initNetworkCommunication:(NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo;
- (void)disconnectFromMachine;
- (void)startSession:(ReturnBlock)block;
- (void)stopSession:(ReturnBlock)block;

@end

NS_ASSUME_NONNULL_END
