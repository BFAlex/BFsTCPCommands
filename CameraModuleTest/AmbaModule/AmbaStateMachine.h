//
//  AmbaStateMachine.h
//  RoadCam
//
//  Created by 刘玲 on 2019/4/28.
//  Copyright © 2019年 HSH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmbaConstants.h"
#import "AmbaController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AmbaStateMachine : NSObject

@property (nonatomic, retain) NSNumber *sessionToken;
//@property (nonatomic, retain) NSMutableString *lastCommand;
//@property (nonatomic, retain) NSMutableString *currentCommand;

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
//@property (nonatomic, retain) NSMutableArray *messages;

@property (nonatomic) BOOL isTCPConnected;
//@property (nonatomic, assign) NSInteger wifiTCPConnectionStatus; // 1=connected 0=unable to connect
@property (nonatomic, retain) NSMutableString *wifiIPParameters;
@property (nonatomic, retain) NSMutableString *notifyMsg;
@property (nonatomic, retain) NSMutableArray  *notifyFileList;
@property (atomic, retain) NSNumber *connected;

+ (instancetype)sharedInstance;
- (void)destoryInstance;
- (void)setupTargetController:(AmbaController *)pController;

- (void)initNetworkCommunication:(NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo;
- (NSInteger)writeDataToCamera:(id)obj andError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
