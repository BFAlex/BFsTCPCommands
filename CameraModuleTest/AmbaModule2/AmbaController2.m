//
//  AmbaController.m
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "AmbaController2.h"
#import "CameraControllerHeader.h"

@interface AmbaController2 () <AmbaCmdClientDelegate> {
    NSString *_machineIp;
    int _cmdPort;
    int _dataPort;
}
@property (nonatomic, strong) AmbaCmdClient *ambaCmdClient;
@property (nonatomic, assign) ReturnBlock connectedStatusBlock;

@end

@implementation AmbaController2

#pragma mark - API

- (instancetype)init {
    if (self = [super init]) {
        [self configDefaultSetting];
    }
    
    return self;
}

- (void)connectToCamera:(ReturnBlock)block {
    
    if (!_ambaCmdClient) {
        _ambaCmdClient = [AmbaCmdClient sharedMachine];
        _ambaCmdClient.delegate = self;
    }
    _connectedStatusBlock = block;
    [_ambaCmdClient initNetworkCommunication:_machineIp tcpPort:_cmdPort];
}

- (void)disconnectFromCamera:(ReturnBlock)block {
    [_ambaCmdClient stopSession:block];
    [_ambaCmdClient destoryMachine];
}

- (void)startSession:(ReturnBlock)block {
    [_ambaCmdClient startSession:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        //
        if (error) {
            if (block) {
                block(error, cmd, result, type);
            }
        } else {
            [self setClientInfo:block];
        }
    }];
}

- (void)setClientInfo:(ReturnBlock)block {
    [_ambaCmdClient setClientInfo:block];
}

- (void)takePhoto:(ReturnBlock)block {
    [_ambaCmdClient shutter:block];
}

- (void)startRecord:(ReturnBlock)block {
    [_ambaCmdClient startRecord:block];
}

- (void)stopRecord:(ReturnBlock)block {
    [_ambaCmdClient stopRecord:block];
}

- (void)currentMachineStatus:(ReturnBlock)block {
    [_ambaCmdClient currentSettingStatus:block];
}

- (void)formatSDCard:(ReturnBlock)block {
    [_ambaCmdClient formatSDCard:block];
}

- (void)listAllFiles:(ReturnBlock)block {
    [_ambaCmdClient listAllFiles:block];
}

- (void)queryCmdValueList:(NSString *)cmdTitle andReturnBlock:(ReturnBlock)block {
    [_ambaCmdClient queryCmdValueList:cmdTitle andReturnBlock:block];
}

- (void)queryAppCurrentStatus:(ReturnBlock)block {
    [_ambaCmdClient queryAppCurrentStatus:block];
}

- (void)queryDeviceInfo:(ReturnBlock)block {
    [_ambaCmdClient queryDeviceInfo:block];
}

- (void)setCameraParameter:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block {
    [_ambaCmdClient setCameraParameter:param value:value andReturnBlock:block];
}

- (void)systemReset:(ReturnBlock)block {
    [_ambaCmdClient systemReset:block];
}

- (void)stopVF:(ReturnBlock)block {
    [_ambaCmdClient stopVF:block];
}

- (void)resetVF:(ReturnBlock)block {
    [_ambaCmdClient resetVF:block];
}

- (void)changeToFolder:(NSString *)folderName andReturnBlock:(ReturnBlock)block {
    [_ambaCmdClient changeToFolder:folderName andReturnBlock:block];
}

- (void)getThumbnail:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block {
    [_ambaCmdClient getThumbnail:param value:value andReturnBlock:block];
}

- (void)getThumbnailOfFile:(NSString *)filePath andReturnBlock:(ReturnBlock)block {
    [_ambaCmdClient getThumbnail:[self fileThumbnailType:filePath] value:filePath andReturnBlock:block];
}

//- (void)getMediaFile:(NSString *)fileName ipAddress:(NSString *)ipaddress andReturnBlock:(ReturnBlock)block {
//    [_ambaCmdClient getMediaFile:fileName ipAddress:ipaddress andReturnBlock:block];
//}
- (void)getMediaFile:(NSString *)fileName downloadingBlock:(DownloadingBlock)downloadingBlock andReturnBlock:(ReturnBlock)block {
    [_ambaCmdClient getMediaFile:fileName downloadingBlock:downloadingBlock andReturnBlock:block];
}

#pragma mark - Func

- (void)configDefaultSetting {
    
    _machineIp = @"192.168.42.1";
    _cmdPort = 7878;
    _dataPort = 8787;
}

- (NSString *)fileThumbnailType:(NSString *)filePath {
    //
    NSString *type = @"IDR";
    if ([[filePath pathExtension] isEqualToString:@"jpg"] || [[filePath pathExtension] isEqualToString:@"JPG"])
    {
        type = @"thumb";
    }
//    else if ([[filePath pathExtension] isEqualToString:@"mp4"] || [[filePath pathExtension] isEqualToString:@"MP4"])
//    {
//        return @"IDR";
//    }
    return type;
}

#pragma mark - AmbaCmdClientDelegate

- (void)ambaMachine:(AmbaCmdClient *)machine didUpdateConnectionStatus:(BOOL)isConnected forStream:(nonnull NSStream *)pStream{
    NSLog(@"[%@ %@]%@ is connected: %d",
          NSStringFromClass([self class]),
          NSStringFromSelector(_cmd),
          [pStream class],
          _ambaCmdClient.isConnected);
    if (_connectedStatusBlock) {
        NSDictionary *resultDict = @{@"ConnectStatus":@(isConnected)};
        _connectedStatusBlock(nil, 0, resultDict, ResultTypeNone);
    }
}

- (void)ambaMachine:(AmbaCmdClient *)machine finishDownload:(id)result {
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *resultDict = (NSDictionary *)result;
        NSLog(@"finishDownload result: %@", resultDict);
    }
    
//    UIAlertController *downloadAlert = [UIAlertController alertControllerWithTitle:nil message:@"finish download" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
//    [downloadAlert addAction:okAction];
}

@end
