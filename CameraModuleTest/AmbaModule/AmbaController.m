//
//  AmbaController.m
//  RoadCam
//
//  Created by 刘玲 on 2019/4/28.
//  Copyright © 2019年 HSH. All rights reserved.
//

#import "AmbaController.h"
#import "AmbaStateMachine.h"


NSString  *tokenKey     = @"token";
NSString  *msgIdKey     = @"msg_id";
NSString  *typeKey      = @"type";
NSString  *offsetKey    = @"offset";
NSString  *featchSizeKey = @"fetch_size";
NSString *optionsKey    = @"options";
//Return keys
NSString *rvalKey = @"rval";
NSString *permissionKey = @"permission";
NSString *pwdKey = @"pwd";

//BiDirectional Key
NSString *paramKey = @"param";

//CommandStrings
NSString *startSessionCmd   = @"StartSession";
NSString *stopSessionCmd    = @"StopSession";
NSString *recordStartCmd    = @"RecStart";
NSString *recordStopCmd     = @"RecStop";
NSString *shutterCmd        = @"Shutter";
NSString *deviceInfoCmd     = @"deviceInfoCmd";
NSString *batteryLevelCmd   = @"batteryLevelCmd";
NSString *stopContPhotoSessionCmd = @"stopContPhotoSessionCmd";
NSString *recordingTimeCmd  = @"RecordingTime";
NSString *splitRecordingCmd = @"RecordingSplit";
NSString *stopVFCmd         = @"StopVF";
NSString *resetVFCmd        = @"ResetVF";
NSString *zoomInfoCmd       = @"zoomInfo";
NSString *setBitRateCmd     = @"BitRate";
NSString *startEncoderCmd   = @"StartEncoder";
NSString *changeSettingCmd  = @"ChangeSetting";
NSString *appStatusCmd      = @"uItronStat";
NSString *storageSpaceCmd   = @"storageSpace";
NSString *presentWorkingDirCmd = @"pwd";
NSString *listAllFilesCmd   = @"listAllFiles";
NSString *numberOfFilesInFolderCmd = @"numberOfFilesInFolderCmd";
NSString *changeToFolderCmd = @"changeFolder";
NSString *mediaInfoCmd      = @"mediaInfo";
NSString *getFileCmd        = @"getFile";
NSString *putFileCmd        = @"putFile";
NSString *stopGetFileCmd    = @"stopGetFile";
NSString *removeFileCmd     = @"removeFile";
NSString *fileAttributeCmd  = @"fileAttributeCmd";
NSString *formatSDMediaCmd  = @"formatSDMediaCmd";
NSString *allSettingsCmd    = @"allSettings";
NSString *getSettingValueCmd = @"getSettingValue";
NSString *getOptionsForValueCmd = @"getOptionsForValue";
NSString *setCameraParameterCmd = @"setCameraParamValue";
NSString *sendCustomJSONCmd = @"sendCustomJSONCmd";
NSString *setClientInfoCmd  = @"setClientInfoCmd";
NSString *getWifiSettingsCmd = @"getWifiSettingsCmd";
NSString *setWifiSettingsCmd = @"setWifiSettingsCmd";
NSString *getWifiStatusCmd   = @"getWifiStatusCmd";
NSString *stopWifiCmd        = @"stopWifiCmd";
NSString *startWifiCmd       = @"startWifiCmd";
NSString *reStartWifiCmd     = @"reStartWifiCmd";
NSString *querySessionCmd    = @"querySessionCmd";
NSString *AMBALOGFILE    = @"AmbaRemoteCam.txt";


//command code thats msg_id number as per amba document
const unsigned int appStatusMsgId       = 1;
const unsigned int getSettingValueMsgId = 1;
const unsigned int setCameraParameterMsgId = 2;
const unsigned int allSettingsMsgId     = 3;
const unsigned int formatSDMediaMsgId   = 4;
const unsigned int storageSpaceMsgId    = 5;
const unsigned int numberOfFilesInFolderId = 6;
const unsigned int notificationMsgId    = 7;
const unsigned int getOptionsForValueMsgId = 9;
const unsigned int deviceInfoMsgId      = 11;
const unsigned int batteryLevelMsgId    = 13;
const unsigned int zoomInfoMsgId        = 15;
const unsigned int setBitRateMsgId      = 16;


const unsigned int startSessionMsgId    = 257;
const unsigned int stopSessionMsgId     = 258;
const unsigned int resetVFMsgId         = 259;
const unsigned int stopVFMsgId          = 260;
const unsigned int setClientInfoMsgId   = 261;


const unsigned int recordStartMsgId     = 513;
const unsigned int recordStopMsgId      = 514;
const unsigned int recordingTimeMsgId   = 515;
const unsigned int splitRecordingMsgId  = 516;

const unsigned int shutterMsgId         = 769;
const unsigned int stopContPhotoSessionMsgId = 770;
const unsigned int mediaInfoMsgId       = 1026;
const unsigned int fileAttributeMsgId   = 1027;

const unsigned int removeFileMsgId      = 1281;
const unsigned int listAllFilesMsgId    = 1282;
const unsigned int changeToFolderMsgId  = 1283;
const unsigned int presentWorkingDirMsgId = 1284;
const unsigned int getFileMsgId         = 1285;
const unsigned int putFileMsgId         = 1286;
const unsigned int stopGetFileMsgId     = 1287;

const unsigned int reStartWifiMsgId     = 1537;
const unsigned int setWifiSettingsMsgId = 1538;
const unsigned int getWifiSettingsMsgId = 1539;
const unsigned int stopWifiMsgId        = 1540;
const unsigned int startWifiMsgId       = 1541;
const unsigned int getWifiStatusMsgId   = 1542;
const unsigned int querySessionHolderMsgId = 1793;

const unsigned int sendCustomJSONMsgID = 99999999; //Select some random number for custom cmd.
//
unsigned int STATUS_FLAG;
unsigned int recvResponse;

@interface AmbaController () {
    
    ReturnBlock _resultBlock;
    NSString *_lastCommand;
    NSString *_currentCommand;
    
    NSString *_typeObject;
    NSString *_paramObject;
    NSInteger _offsetObject;
    NSInteger _sizeToDlObject;
    NSString  *_md5SumObject;
    NSInteger _fileAttributeValue;
}
@property (nonatomic, weak) AmbaStateMachine *machine;

@end

@implementation AmbaController

#pragma mark - API

- (void)connectToCamera:(ReturnBlock)block {
    
    [self connectToAmbaCamera:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        if (!error) {
            // 开始会话
            [self startSession:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
                //
                if (block) {
                    block(error, cmd, result, type);
                }
            }];
        }
    }];
}

- (void)dealloc {
    
    if (_machine) {
        [_machine destoryInstance];
        _machine = nil;
    }
    //
    [self unregisterAmbaNotification];
}

- (void)handleReceivedResult:(id)result {
    
    NSDictionary *resultDict;
    if ([result isKindOfClass:[NSString class]]) {
        resultDict = [self convertStringToDictionary:result];
    } else {
        resultDict = (NSDictionary *)result;
    }
    
    [self handleDictResult:resultDict];
}

- (void)handleDictResult:(NSDictionary *)resultDict {
    
    if ([[resultDict objectForKey:msgIdKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:notificationMsgId]]) {
        //
    }
    else if ([_currentCommand isEqualToString:startSessionCmd])
    {
        [self responseToStartSession:resultDict];
    }
}

- (void) responseToStartSession:(NSDictionary *)responseDict
{
    NSLog(@"Response to StartSession received");
    NSLog(@"rval %@", (NSNumber *)[responseDict objectForKey:rvalKey]);
    if ([[responseDict objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]])
    {
        _machine.sessionToken = [responseDict objectForKey:paramKey];
        NSLog(@"开启会话成功 》》》》");
        _resultBlock(nil, 0, nil, ResultTypeNone);
    }
    // send an error message about camera refusing a lock
    else
    {
        NSLog(@"Camera refuses to Start Session");
//        NSDictionary *notificationDict = [[NSDictionary alloc] init];
//        NSNotification *notificationObject = [NSNotification notificationWithName:startSessionRefusalNotification
//                                                                           object:self
//                                                                         userInfo:notificationDict];
//        self.notificationCount = 1;
//        [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
//        STATUS_FLAG = 1;
        NSLog(@"开启会话失败 》》》》");
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:250 userInfo:nil];
        _resultBlock(error, 0, nil, ResultTypeNone);
    }
     NSLog(@"开启会话结果：%@", responseDict);
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

#pragma mark - Command

- (void)connectToAmbaCamera:(ReturnBlock)block {
    
    _resultBlock = block;
    //
    [self registerAmbaNotification];
    //
    self.machine = [AmbaStateMachine sharedInstance];
    [self.machine setupTargetController:self];
    [self.machine initNetworkCommunication:kCameraHost tcpPort:kCameraPort];
}

- (void)sendCmdToCamera:(unsigned int)commandCode andResult:(ReturnBlock)block {
    
    NSDictionary *commandDict;
    
    if ( commandCode == 1 ||
        commandCode == 5 ||
        commandCode == 6 ||
        commandCode == 15
        ) { //commands with "type" only
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       self.machine.sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       _typeObject, typeKey,
                       nil];
        
    } else if (commandCode == 1538 ||
               commandCode == 1283 ||
               commandCode == 1026 ||
               commandCode == 1287 ||
               commandCode == 1281 ||
               commandCode == 16   ||
               commandCode == 9    ||
               commandCode == 4 )   { //commands with "param" only
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       self.machine.sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       _paramObject, paramKey,
                       nil];
    } else if (commandCode == 1285 ) {//special cases
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       self.machine.sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       _paramObject, paramKey,
                       [NSNumber numberWithUnsignedInteger: _offsetObject], offsetKey,
                       [NSNumber numberWithUnsignedInteger: _sizeToDlObject ], featchSizeKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       nil];
    }else if (commandCode ==1286) //special case
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       self.machine.sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       _paramObject, paramKey,
                       [NSNumber numberWithUnsignedInteger: _offsetObject], offsetKey,
                       [NSNumber numberWithUnsignedInteger:  _sizeToDlObject ], @"size",
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       _md5SumObject, @"md5sum",
                       nil];
    } else if (commandCode == 1793) //special case SessionHolder
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       nil];
        
    }else if (commandCode == 2 ||
              commandCode == 261)
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       self.machine.sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       _paramObject, paramKey,
                       _typeObject, typeKey,
                       nil];
    } else if ( commandCode == 1027)
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       self.machine.sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       _paramObject, paramKey,
                       [NSNumber numberWithUnsignedInteger:_fileAttributeValue], typeKey,
                       nil];
    }
    else {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       self.machine.sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       nil];
    }
    
    _resultBlock = block;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.machine writeDataToCamera:commandDict andError:nil];
    });
}

- (void)startSession:(ReturnBlock)block {
    
    _lastCommand = _currentCommand;
    _currentCommand = startSessionCmd;
    
    [self sendCmdToCamera:startSessionMsgId andResult:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        if (block) {
            block(error, cmd, result, type);
        }
    }];
}

- (void)stopSession:(ReturnBlock)block {
    //
}

#pragma mark - Notification

- (void)registerAmbaNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConnectionStatus:)
                                                 name:kUpdateConnectionStatusNotification
                                               object:nil];
}
- (void)unregisterAmbaNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateConnectionStatusNotification object:nil];
}

- (void)updateConnectionStatus:(NSNotification *)notification {
    
    NSError *error;
    if (!self.machine.isTCPConnected) {
        error = [NSError errorWithDomain:NSURLErrorDomain code:250 userInfo:@{NSLocalizedDescriptionKey:@"tcp connect error"}];
    }
    //
    if (_resultBlock) {
        _resultBlock(error, 0, nil, ResultTypeNone);
    }
}

@end
