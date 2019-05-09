//
//  AmbaMachine.m
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "AmbaCmdClient.h"
#import "AmbaDataClient.h"
#import "AmbaCmdHeader.h"

#define kAsyncTask(queue, block) dispatch_async(queue, block)

@interface AmbaCmdClient () <NSStreamDelegate> {
    int _sessionToken;
    
    NSString *_typeObject;
    NSString *_paramObject;
    NSInteger _offsetObject;
    NSInteger _sizeToDlObject;
    NSString  *_md5SumObject;
    NSInteger _fileAttributeValue;
    NSMutableString *tmpString;
    
    dispatch_semaphore_t _taskSemaphore;
    
    int     _curOperationCount; // 同步队列专用参数
}
@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic, strong) NSString *tmpMsgStr;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) __block AmbaCommand *curCommand;
// GCD
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
// NSArray
@property (nonatomic, strong) NSLock *lockOfNetwork;
@property (nonatomic, assign) BOOL isExecutingNetworkOrder;
@property (nonatomic, strong) NSMutableArray *ordersOfConcurrent;
@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;

@end

@implementation AmbaCmdClient

static AmbaCmdClient *cmdClient;
static dispatch_once_t onceToken;

- (NSMutableArray *)ordersOfConcurrent {
    if (!_ordersOfConcurrent) {
        _ordersOfConcurrent = [NSMutableArray array];
    }
    
    return _ordersOfConcurrent;
}

#pragma mark - API

+ (instancetype)sharedMachine {
    
    dispatch_once(&onceToken, ^{
        cmdClient = [[AmbaCmdClient alloc] init];
        if (cmdClient) {
            [cmdClient configDefaultSetting];
        }
    });
    
    return cmdClient;
}

- (void)destoryMachine {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (onceToken) {
        //
        [[AmbaDataClient sharedInstance] destoryInstance];
        //
        cmdClient = nil;
        onceToken = 0;
    }
}

- (void)initNetworkCommunication:(NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddress, (unsigned int)tcpPortNo, &readStream, &writeStream);
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge  NSOutputStream *)writeStream;
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
    
    self.isConnected = NO;
    _sessionToken = 0;
    self.ipAddress = ipAddress;
}

- (void)disconnectFromMachine {
    
    if (self.outputStream) {
        [self.outputStream close];
    }
    if (self.inputStream) {
        [self.inputStream close];
    }
}

- (void)startSession:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = startSessionCmd;
    command.messageId = startSessionMsgId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)setClientInfo:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = setClientInfoCmd;
    int curMessageId = setClientInfoMsgId;
    command.messageId = curMessageId;
    _paramObject = self.ipAddress;
    _typeObject = @"TCP";
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)stopSession:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = stopSessionCmd;
    int curMessageId = stopSessionMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)shutter:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = shutterCmd;
    int curMessageId = shutterMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)startRecord:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = recordStartCmd;
    int curMessageId = recordStartMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)stopRecord:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = recordStopCmd;
    int curMessageId = recordStopMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)currentSettingStatus:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = allSettingsCmd;
    int curMessageId = allSettingsMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)formatSDCard:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = setCameraParameterCmd;
    int curMessageId = formatSDMediaMsgId; // setCameraParameterMsgId
    command.messageId = curMessageId;
    _paramObject = @"C:";
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)listAllFiles:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = listAllFilesCmd;
    int curMessageId = listAllFilesMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)queryCmdValueList:(NSString *)cmdTitle andReturnBlock:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = getOptionsForValueCmd;
    int curMessageId = getOptionsForValueMsgId;
    command.messageId = curMessageId;
    command.param = cmdTitle;
    _paramObject = cmdTitle;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)queryAppCurrentStatus:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = appStatusCmd;
    int curMessageId = appStatusMsgId;
    command.messageId = curMessageId;
    _typeObject = @"app_status";
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)queryDeviceInfo:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = deviceInfoCmd;
    int curMessageId = deviceInfoMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)setCameraParameter:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = setCameraParameterCmd;
    int curMessageId = setCameraParameterMsgId;
    command.messageId = curMessageId;
    _typeObject = param;
    _paramObject = value;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)systemReset:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = setCameraParameterCmd;
    int curMessageId = setCameraParameterMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)changeToFolder:(NSString *)folderName andReturnBlock:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = changeToFolderCmd;
    int curMessageId = changeToFolderMsgId;
    command.messageId = curMessageId;
    _paramObject = folderName;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)stopVF:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = stopVFCmd;
    int curMessageId = stopVFMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)resetVF:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = resetVFCmd;
    int curMessageId = resetVFMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)getThumbnail:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = getThumbnailCmd;
    int curMessageId = getThumbnailId;
    command.messageId = curMessageId;
    _typeObject = param;
    _paramObject = value;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

- (void)getMediaFile:(NSString *)fileName ipAddress:(NSString *)ipaddress andReturnBlock:(ReturnBlock)block {
    
    _paramObject = fileName;
    _offsetObject = 0;
    _sizeToDlObject = 0;
    //
    [[AmbaDataClient sharedInstance] initDataCommunication:ipaddress tcpPort:8787 fileName:_paramObject];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self ambaGetFile:block];
    });
    
}

- (void)ambaGetFile:(ReturnBlock)block {
    
    AmbaCommand *command = [AmbaCommand command];
    command.curCommand = getFileCmd;
    int curMessageId = getFileMsgId;
    command.messageId = curMessageId;
    __weak typeof(command) weakCmd = command;
    __weak typeof(self) weakSelf = self;
    command.taskBlock = ^{
        [weakSelf startCmd:weakCmd];
    };
    command.returnBlock = block;
    [self addOrder:command];
}

// ************************

- (void)startCmd:(AmbaCommand *)cmd {
    id commandData = [self configDataForCommand:cmd];
    [self writeDataToCamera:commandData andError:nil];
}

- (id)configDataForCommand:(AmbaCommand *)cmd {
    
    NSDictionary *commandDict;
    
    if (cmd.messageId == 1 ||
        cmd.messageId == 5 ||
        cmd.messageId == 6 ||
        cmd.messageId == 15
        ) { //commands with "type" only
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @(_sessionToken), tokenKey,
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       _typeObject, typeKey,
                       nil];
        
    } else if (cmd.messageId == 1538 ||
               cmd.messageId == 1283 ||
               cmd.messageId == 1026 ||
               cmd.messageId == 1287 ||
               cmd.messageId == 1281 ||
               cmd.messageId == 16   ||
               cmd.messageId == 9    ||
               cmd.messageId == 4 )   { //commands with "param" only
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @(_sessionToken), tokenKey,
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       _paramObject, paramKey,
                       nil];
    } else if (cmd.messageId == 1285 ) {//special cases
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @(_sessionToken), tokenKey,
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       _paramObject, paramKey,
                       [NSNumber numberWithUnsignedInteger: _offsetObject], offsetKey,
                       [NSNumber numberWithUnsignedInteger:  _sizeToDlObject ], featchSizeKey,
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       nil];
    }else if (cmd.messageId ==1286) //special case
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @(_sessionToken), tokenKey,
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       _paramObject, paramKey,
                       [NSNumber numberWithUnsignedInteger: _offsetObject], offsetKey,
                       [NSNumber numberWithUnsignedInteger:  _sizeToDlObject ], @"size",
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       _md5SumObject, @"md5sum",
                       nil];
    } else if (cmd.messageId == 1793) //special case SessionHolder
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       nil];
        
    }else if (cmd.messageId == 2 ||
              cmd.messageId == 261  ||
              cmd.messageId == 1025)
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @(_sessionToken), tokenKey,
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       _paramObject, paramKey,
                       _typeObject, typeKey,
                       nil];
    } else if (cmd.messageId == 1027)
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @(_sessionToken), tokenKey,
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       _paramObject, paramKey,
                       [NSNumber numberWithUnsignedInteger:_fileAttributeValue], typeKey,
                       nil];
    }
    else {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @(_sessionToken), tokenKey,
                       [NSNumber numberWithUnsignedInteger:cmd.messageId], msgIdKey,
                       nil];
    }
    
    return commandDict;
}

- (NSInteger)writeDataToCamera:(id)obj andError:(NSError * _Nullable __autoreleasing *)error {
    
    if (_isConnected) {
        return [NSJSONSerialization writeJSONObject:obj toStream:self.outputStream options:kNilOptions error:error];
    } else {
        if (error) {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"camera is no connect"}];
        }
        return 0;
    }
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"[%@ %@]: %lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)eventCode);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
        {
            NSLog(@"连接成功：%@", NSStringFromClass([aStream class]));
            [self updateConnectionStatus:YES forStream:aStream];
        }
            break;
        case NSStreamEventHasBytesAvailable:
        {
            NSLog(@"[%@]8787 stream receive data", NSStringFromClass([self class]));
            if (aStream == self.inputStream) {
                uint8_t buffer[1024];
                NSInteger len;
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *responseString = [[NSString alloc] initWithBytes:buffer
                                                                            length:len
                                                                          encoding:NSASCIIStringEncoding];
                        
                        //------handle Packet Framented return from camera
                        //TODO: Implement timeout if the string does'nt make it to App
                        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                     options:kNilOptions
                                                                                       error:nil];
                        //Store the value in a global and append data string in next call check before we call messageReceived
                        if (!jsonResponse) {
                            [tmpString appendString:responseString];
                            
                            NSLog(@"Appending pkt Fragmented Data-> %@",tmpString);                            
                            
                            data = [tmpString dataUsingEncoding:NSUTF8StringEncoding];
                            if (data) {
                                jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:kNilOptions
                                                                                 error:nil];
                            }
                            if (jsonResponse){
                                [self messageReceived:tmpString];
                                //reset the tmpString to nothing
                                tmpString = [NSMutableString stringWithFormat:@""];
//                                recvResponse = 1;
//                                if (jsonTimer)
//                                    [jsonTimer invalidate];
                            }
                        } else {
//                            recvResponse = 1;
//                            if (jsonTimer)
//                                [jsonTimer invalidate];
                            
                            [self messageReceived:responseString];
                        }
                    }
                }
            }
        }
            break;
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"连接出现错误");
            [self updateConnectionStatus:NO forStream:aStream];
        }
            break;
        case NSStreamEventEndEncountered:
        {
            NSLog(@"连接结束");
            [self updateConnectionStatus:NO forStream:aStream];
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
        }
            break;
            
        default:
            NSLog(@"Unknown Event: %lu", (unsigned long)eventCode);
            break;
    }
}

- (void)messageReceived:(id)result {
    
    [self handleResultStringMsg:result];
}

- (void)handleResultStringMsg:(id)responseMsg {
    
    NSLog(@"[%@]:%@", NSStringFromSelector(_cmd), responseMsg);
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        responseDict = [self convertStringToDictionary:responseMsg];
    }
    
    int msgId = [[responseDict objectForKey:@"msg_id"] intValue];
//    if ([[responseDict objectForKey:msgIdKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:notificationMsgId]]) {
    if (notificationMsgId == msgId) {
        NSLog(@"get file result: %@", responseDict);
        if (!([responseMsg rangeOfString:@"get_file_complete"].location == NSNotFound)) {
            [[AmbaDataClient sharedInstance] closeFileDownloadConnection];
            NSLog(@"文件下载完成...");
        }
    }
    else if (_curCommand.messageId == startSessionMsgId)
    {
        [self responseToStartSession:responseMsg];
    }
    else if (_curCommand.messageId == stopSessionMsgId)
    {
        [self responseToStopSession:responseDict];
    }
    else if (_curCommand.messageId == shutterMsgId)
    {
        [self responseToShutter:responseDict];
    }
    else if (_curCommand.messageId == recordStartMsgId)
    {
        [self responseToStartRecord:responseDict];
    }
    else if (_curCommand.messageId == recordStopMsgId)
    {
        [self responseToStopRecord:responseDict];
    }
    else if (_curCommand.messageId == allSettingsMsgId)
    {
        [self responseToGetAllCurrentSettingsStatus:responseMsg];
    }
    else if (_curCommand.messageId == formatSDMediaMsgId)
    {
        [self responseToFormatSDCard:responseMsg];
    }
    else if (_curCommand.messageId == listAllFilesMsgId)
    {
        [self responseToListAllFiles:responseMsg];
    }
    else if (_curCommand.messageId == getOptionsForValueMsgId)
    {
        [self responseToGetOptionsSettings:responseMsg];
    }
    else if (_curCommand.messageId == appStatusMsgId)
    {
        [self responseToAppStatus:responseMsg];
    }
    else if (_curCommand.messageId == deviceInfoMsgId)
    {
        [self responseToDeviceInfo:responseMsg];
    }
    else if (_curCommand.messageId == setCameraParameterMsgId)
    {
        [self responseToSetParams:responseMsg];
    }
    else if (_curCommand.messageId == stopVFMsgId)
    {
        [self responseToVFStatus:responseMsg];
    }
    else if (_curCommand.messageId == resetVFMsgId)
    {
        [self responseToVFStatus:responseMsg];
    }
    else if (_curCommand.messageId == changeToFolderMsgId)
    {
        [self responseToListAllFiles:responseMsg];
    }
    else if (_curCommand.messageId == getFileMsgId)
    {
        [self responseToFileDownload:responseMsg];
    }
    else if (_curCommand.messageId == setClientInfoMsgId)
    {
        [self responseToCmd:responseMsg];
    }
    
//    [self.lockOfNetwork unlock];
    dispatch_semaphore_signal(_taskSemaphore);
//    NSLog(@"task thread(result): %@", [NSThread currentThread]);
}

#pragma mark - Handle Message

// ****
- (void)responseToCmd:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    NSString *msgId = [responseDict objectForKey:msgIdKey];
    NSLog(@"cmd(%@) result: %d", msgId, rval);
    if (rval != 0) {
        error = [self errorForDescription:[NSString stringWithFormat:@"Cmd(%@) fail", msgId]];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToFileDownload:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    NSString *msgId = [responseDict objectForKey:msgIdKey];
    NSLog(@"cmd(%@) result: %d", msgId, rval);
    
    if (rval == 0) {
        NSLog(@"file is downloading on port 8787");
    } else if (rval != 0) {
        error = [self errorForDescription:[NSString stringWithFormat:@"file finish down"]];
        [[AmbaDataClient sharedInstance] closeTCPConnection];
        [[AmbaDataClient sharedInstance] destoryInstance];
        
        if (_curCommand.returnBlock) {
            _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
        }
    }
}

// ***

- (void)responseToVFStatus:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    NSLog(@"VF result: %d", rval);
    
    if (rval != 0) {
        error = [self errorForDescription:@"VF fail"];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToSetParams:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    NSLog(@"set param result: %d", rval);
    
    if (rval != 0) {
        error = [self errorForDescription:@"set param fail"];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToDeviceInfo:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    NSLog(@"Device Info result: %d", rval);
    
    if (rval != 0) {
        error = [self errorForDescription:@"Device Info fail"];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToAppStatus:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    NSLog(@"App Status result: %d", rval);
    
    if (rval != 0) {
        error = [self errorForDescription:@"App Status fail"];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void) responseToGetOptionsSettings:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    if (rval != 0) {
        error = [self errorForDescription:@"Get Options Settings fail"];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToListAllFiles:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    if (rval != 0) {
        error = [self errorForDescription:@"Start Record fail"];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToFormatSDCard:(id)responseMsg {
    NSLog(@"response to format sd card: %@", responseMsg);
}

- (void)responseToGetAllCurrentSettingsStatus:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    if (rval != 0) {
        error = [self errorForDescription:@"Settings status fail"];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToStartRecord:(NSDictionary *)responseDict {
    
    NSError *error;
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    if (rval != 0) {
        error = [self errorForDescription:@"Start Record fail"];
    }
     
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToStopRecord:(NSDictionary *)responseDict {
    
    NSError *error;
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    if (rval != 0) {
        error = [self errorForDescription:@"Stop Record fail"];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToShutter:(NSDictionary *)responseDict {
//    NSLog(@"%@: %@", NSStringFromSelector(_cmd), responseDict);
    int rval = [[responseDict objectForKey:rvalKey] intValue];
    NSLog(@"Shutter result: %d", rval);
    
    NSError *error;
    if (rval != 0) {
        error = [self errorForDescription:@"shutter fail"];
    }
    
    if (_curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToStopSession:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    } else {
        responseDict = responseMsg;
    }
    
    if ([[responseDict objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]])
    {
        self.isConnected = NO;
        _sessionToken = 0;
        
        [self.inputStream close];
        [self.outputStream close];
    }
    else {
        NSLog(@"!!!!!!Unable to Disconnect!!!!!");
        error = [NSError errorWithDomain:NSURLErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"camera unable to disconnect"}];
    }
    
    if (self.curCommand.returnBlock) {
        _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
    }
}

- (void)responseToStartSession:(id)responseMsg {
    
    NSError *error;
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        responseDict = [self analysisDataFromStringToDictionary:responseMsg];
    } else {
        responseDict = responseMsg;
    }
    NSLog(@"rval %@", (NSNumber *)[responseDict objectForKey:rvalKey]);
    if ([[responseDict objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]])
    {
        _sessionToken = [[responseDict objectForKey:paramKey] intValue];
        NSLog(@"开启会话成功 》》》》");
    }
    else
    {
        NSLog(@"开启会话失败 》》》》Camera refuses to Start Session");
        error = [NSError errorWithDomain:NSURLErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"star session fail"}];
    }
    _curCommand.returnBlock(error, 0, responseDict, ResultTypeNone);
}

- (NSError *)errorForDescription:(NSString *)desc {
    
    if (desc.length < 1) {
        desc = @"unknown";
    }
    return [NSError errorWithDomain:NSURLErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:desc}];
}

#pragma mark -

- (NSDictionary *)analysisDataFromStringToDictionary:(NSString *)responseMsg {
    
    NSDictionary *responseDict;
    if ([responseMsg isKindOfClass:[NSString class]]) {
        NSData *data = [responseMsg dataUsingEncoding:NSUTF8StringEncoding];
        responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
    }
    
    return responseDict;
}

- (NSDictionary *)convertStringToDictionary:(NSString *)jsonInString
{
    
    jsonInString = [[jsonInString stringByReplacingOccurrencesOfString:@"{" withString:@""]
                    stringByReplacingOccurrencesOfString:@"}" withString:@""];
    
    
    NSMutableDictionary *convertedDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *keyValuePairArray = [jsonInString componentsSeparatedByString:@","];
    
    for(NSUInteger arrayInd = 0; arrayInd < MIN([keyValuePairArray count], 3); arrayInd++)
    {
        NSArray *singleKeyValuePair = [[keyValuePairArray objectAtIndex:arrayInd] componentsSeparatedByString:@":"];
        NSString *keyParam = [singleKeyValuePair objectAtIndex:0];
        keyParam = [keyParam stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        keyParam = [keyParam stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSString *valueParamString = [singleKeyValuePair objectAtIndex:1];
        NSNumber *valueParamNumber = [[NSNumber alloc] init];
        
        NSArray *tmpParamKeyParamArray = [[NSArray alloc] init];
        
        // if not "param:"
        if (![keyParam isEqualToString:paramKey])
        {
            valueParamNumber = [NSNumber numberWithInt:[valueParamString intValue]]; //  = [formatter numberFromString:valueParamString];
        }
        
        // if "param:"
        else
        {
            valueParamString = [[valueParamString stringByReplacingOccurrencesOfString:@"[" withString:@""]
                                stringByReplacingOccurrencesOfString:@"]" withString:@""];
            
            NSLog(@"Number of Chars %d", (unsigned int)valueParamString.length);
            
            tmpParamKeyParamArray = [valueParamString componentsSeparatedByString:@","];
            
            // See if single number
            if([tmpParamKeyParamArray count] == 1)
            {
                valueParamNumber = [NSNumber numberWithInt:[valueParamString intValue]];
            }
        }
        
        if (![keyParam isEqualToString:paramKey])
        {
            [convertedDictionary setObject:valueParamNumber forKey:keyParam];
        }
        // if "param:"
        else
        {
            // if just a number, then set to number
            if ([tmpParamKeyParamArray count] == 1)
            {
                [convertedDictionary setObject:valueParamNumber forKey:keyParam];
            }
            // else set it to string (AMBAXXX.jpg)
            else
            {
                [convertedDictionary setObject:valueParamString forKey:keyParam];
            }
        }
    } // for(NSUI...
    
    NSDictionary *returnDictionary = [convertedDictionary copy];
    
    // Print out for debugging
    
    NSEnumerator *enumerator = [returnDictionary keyEnumerator];
    NSString *key;
    while (key = [ enumerator nextObject])
    {
        NSLog(@"%@, %@", key, [returnDictionary objectForKey:key]);
    }
    
    return returnDictionary;
}
#pragma mark - Func

- (void)updateConnectionStatus:(BOOL)isConnected forStream:(NSStream *)pStream {
    
    self.isConnected = isConnected;
    if ([self.delegate respondsToSelector:@selector(ambaMachine:didUpdateConnectionStatus:forStream:)]) {
        [self.delegate ambaMachine:self didUpdateConnectionStatus:_isConnected forStream:pStream];
    }
}

- (BOOL)addOrder:(AmbaCommand *)order {

    kAsyncTask(self.concurrentQueue, ^{
        [self addNetworkOrder:order];
    });

    return true;
}

/**
 并发队列顺序执行order
 */
- (void)addNetworkOrder:(AmbaCommand *)order {
//    NSLog(@"添加任务线程： %@", [NSThread currentThread]);
    [self.lockOfNetwork lock];
    [self.ordersOfConcurrent addObject:order];

    if (self.isExecutingNetworkOrder && (_curOperationCount >= self.maxConcurrentOperationCount)) {
        [self.lockOfNetwork unlock];
        return;
    }

    _curOperationCount++;
    while (self.ordersOfConcurrent.count > 0) {

        self.isExecutingNetworkOrder = YES;
        [self.lockOfNetwork unlock];

        AmbaCommand *executeOrder = [self searchOrderForHighterProperty:self.ordersOfConcurrent];
        [self synchronizeExecuteOrder:executeOrder];

        [self.lockOfNetwork lock];
        [self.ordersOfConcurrent removeObject:executeOrder];
    }
    self.isExecutingNetworkOrder = NO;
    _curOperationCount--;
    [self.lockOfNetwork unlock];
}
/**
 子类重写具体指令操作方法
 */

- (id)synchronizeExecuteOrder:(AmbaCommand *)order {

    /**
     增加具体的网络指令内容
     */

//    [self.lockOfNetwork lock];
    long result = dispatch_semaphore_wait(_taskSemaphore, 5.f);
    if (result != 0) {
        NSLog(@"cmd(%d) overtime", self.curCommand.messageId);
        [NSThread sleepForTimeInterval:1.f];
    }
//    NSLog(@"task thread: %@", [NSThread currentThread]);
    self.curCommand = order;
    order.taskBlock();

    return nil;
}

- (AmbaCommand *)searchOrderForHighterProperty:(NSArray *)orders {
    
    AmbaCommand *targetOrder = [orders firstObject];
    for (int i = 1; i < orders.count; i++) {
        AmbaCommand *tmpOrder = orders[i];
        if (targetOrder.orderPrority < tmpOrder.orderPrority) {
            targetOrder = tmpOrder;
        }
    }
    
    return targetOrder;
}

- (void)configDefaultSetting {
    
    _sessionToken = 0;
    self.tmpMsgStr = @"";
    
    // GCD
    NSString *queueName = @"bibi";
    self.concurrentQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
    self.maxConcurrentOperationCount = 1;
    _curOperationCount = 0;
    
    _taskSemaphore = dispatch_semaphore_create(1);
}

@end
