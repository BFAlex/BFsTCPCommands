//
//  AmbaController.m
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "AmbaController.h"
#import "AmbaMachine.h"
#import "CameraControllerHeader.h"

@interface AmbaController () <AmbaMachineDelegate>
@property (nonatomic, strong) AmbaMachine *machine;
@property (nonatomic, assign) ReturnBlock connectedStatusBlock;

@end

@implementation AmbaController

#pragma mark - API

- (void)connectToCamera:(ReturnBlock)block {
    
    if (!_machine) {
        _machine = [AmbaMachine sharedMachine];
        _machine.delegate = self;
    }
    _connectedStatusBlock = block;
    [_machine initNetworkCommunication:@"192.168.42.1" tcpPort:7878];
}

- (void)disconnectFromCamera:(ReturnBlock)block {
    [_machine stopSession:block];
    [_machine destoryMachine];
}

- (void)startSession:(ReturnBlock)block {
//    [_machine startSession:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
//        NSString *resultStr = error ? error.description : @"成功";
//        NSLog(@"开启会话结果: %@", resultStr);
//    }];
    [_machine startSession:block];
}

- (void)takePhoto:(ReturnBlock)block {
//    [_machine shutter:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
//        NSString *resultStr = error ? error.description : @"成功";
//        NSLog(@"拍照结果: %@", resultStr);
//    }];
    [_machine shutter:block];
}

- (void)startRecord:(ReturnBlock)block {
    [_machine startRecord:block];
}

- (void)stopRecord:(ReturnBlock)block {
    [_machine stopRecord:block];
}

- (void)currentMachineStatus:(ReturnBlock)block {
    [_machine currentSettingStatus:block];
}

- (void)formatSDCard:(ReturnBlock)block {
    [_machine formatSDCard:block];
}

- (void)listAllFiles:(ReturnBlock)block {
    [_machine listAllFiles:block];
}

- (void)queryCmdValueList:(NSString *)cmdTitle andReturnBlock:(ReturnBlock)block {
    [_machine queryCmdValueList:cmdTitle andReturnBlock:block];
}

- (void)queryAppCurrentStatus:(ReturnBlock)block {
    [_machine queryAppCurrentStatus:block];
}

- (void)queryDeviceInfo:(ReturnBlock)block {
    [_machine queryDeviceInfo:block];
}

- (void)setCameraParameter:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block {
    [_machine setCameraParameter:param value:value andReturnBlock:block];
}

- (void)systemReset:(ReturnBlock)block {
    [_machine systemReset:block];
}

- (void)stopVF:(ReturnBlock)block {
    [_machine stopVF:block];
}

- (void)resetVF:(ReturnBlock)block {
    [_machine resetVF:block];
}

- (void)changeToFolder:(NSString *)folderName andReturnBlock:(ReturnBlock)block {
    [_machine changeToFolder:folderName andReturnBlock:block];
}

#pragma mark - AmbaMachineDelegate

- (void)ambaMachine:(AmbaMachine *)machine didUpdateConnectionStatus:(BOOL)isConnected forStream:(nonnull NSStream *)pStream{
    NSLog(@"[%@ %@]%@ is connected: %d",
          NSStringFromClass([self class]),
          NSStringFromSelector(_cmd),
          [pStream class],
          _machine.isConnected);
    if (_connectedStatusBlock) {
        NSDictionary *resultDict = @{@"ConnectStatus":@(isConnected)};
        _connectedStatusBlock(nil, 0, resultDict, ResultTypeNone);
    }
}

@end
