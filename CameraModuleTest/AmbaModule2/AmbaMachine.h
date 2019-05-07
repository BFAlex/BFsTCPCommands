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
- (void)shutter:(ReturnBlock)block;
- (void)startRecord:(ReturnBlock)block;
- (void)stopRecord:(ReturnBlock)block;
- (void)currentSettingStatus:(ReturnBlock)block;
- (void)formatSDCard:(ReturnBlock)block;
- (void)listAllFiles:(ReturnBlock)block;
- (void)queryCmdValueList:(NSString *)cmdTitle andReturnBlock:(ReturnBlock)block;
- (void)queryAppCurrentStatus:(ReturnBlock)block;
- (void)queryDeviceInfo:(ReturnBlock)block;
- (void)setCameraParameter:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block;
- (void)systemReset:(ReturnBlock)block;

@end

NS_ASSUME_NONNULL_END
