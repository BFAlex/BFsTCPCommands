//
//  AmbaController.m
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "AmbaController.h"
#import "AmbaCmdClient.h"
#import "CameraControllerHeader.h"
#import "CFiledModel.h"

#define kAmbaIpAddress @"192.168.42.1"

@interface AmbaController () <AmbaCmdClientDelegate> {
    
    NSArray *_tvModList;
    NSArray *_movieRecordSizeList;
    NSArray *_videoQuality;
    NSTimer *_connectTimer;
}
@property (nonatomic, strong) AmbaCmdClient *cmdClient;
@property (nonatomic, copy) ReturnBlock connectedStatusBlock;

@end

@implementation AmbaController {
    
    //Status
    CameraCommandStatus *_commandStatus;
}

#pragma mark - API

- (instancetype)init {
    if (self = [super init]) {
        [self configDefaultSetting];
    }
    
    return self;
}

- (void)dealloc {
    [self disconnectFromCamera:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        //
    }];
}

- (void)configDefaultSetting {
    //Status
    _commandStatus = [[CameraCommandStatus alloc] init];
    _commandStatus.curLiveStreamUrl = [NSString stringWithFormat:@"rtsp://%@/live", kAmbaIpAddress];
    //
    _commandStatus.curCameraMode = CameraModeMovie;
    //
    _commandStatus.isCardExist = YES;
}

- (void)connectToCamera:(ReturnBlock)block {
    
    if (!_cmdClient) {
        _cmdClient = [AmbaCmdClient sharedMachine];
        _cmdClient.delegate = self;
    }
    _connectedStatusBlock = block;
    [_cmdClient initNetworkCommunication:kAmbaIpAddress tcpPort:7878];
    
    [self startOvertime];
}

- (void)disconnectFromCamera:(ReturnBlock)block {
    [_cmdClient stopSession:block];
    [_cmdClient destoryMachine];
}

- (void)startSession:(ReturnBlock)block {
    [_cmdClient startSession:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"开启会话结果: %@", resultStr);
        //
        [self updateMachineCapabilityList];
        //
        if (block) {
            block(error, cmd, result, ResultTypeNone);
        }
    }];
}

- (void)takePhoto:(ReturnBlock)block {
    [_cmdClient shutter:block];
}

- (void)startRecord:(ReturnBlock)block {
    
    [_cmdClient startRecord:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"start record result: %@", result);
        //
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = (NSDictionary *)result;
            int rval = [[resultDict objectForKey:@"rval"] intValue];
            if (rval == 0) {
                self->_commandStatus.isRecord = YES;
            }
        }
        //
        if (block) {
            block(error, cmd, result, type);
        }
    }];
}

- (void)stopRecord:(ReturnBlock)block {
    
    [_cmdClient stopRecord:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"stop record result: %@", result);
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = (NSDictionary *)result;
            int rval = [[resultDict objectForKey:@"rval"] intValue];
            if (rval == 0) {
                self->_commandStatus.isRecord = NO;
            }
        }
        if (block) {
            block(error, cmd, result, type);
        }
    }];
}

- (void)currentMachineStatus:(ReturnBlock)block {
    [_cmdClient currentSettingStatus:block];
}

- (void)formatSDCard:(ReturnBlock)block {
    [_cmdClient formatSDCard:block];
}

- (void)listAllFiles:(ReturnBlock)block {
    [_cmdClient listAllFiles:block];
}

- (void)queryCmdValueList:(NSString *)cmdTitle andReturnBlock:(ReturnBlock)block {
    [_cmdClient queryCmdValueList:cmdTitle andReturnBlock:block];
}

- (void)queryAppCurrentStatus:(ReturnBlock)block {
    [_cmdClient queryAppCurrentStatus:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"app current status: %@", result);
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = (NSDictionary *)result;
            NSString *recordStatus = [resultDict objectForKey:@"param"];
            self->_commandStatus.isRecord = [recordStatus isEqualToString:@"record"];
        }
        
        if (block) {
            block(error, cmd, result, type);
        }
    }];
}

- (void)queryDeviceInfo:(ReturnBlock)block {
    [_cmdClient queryDeviceInfo:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"device info: %@", result);
        
        if (block) {
            block(error, cmd, result, type);
        }
    }];
}

- (void)setCameraParameter:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block {
    [_cmdClient setCameraParameter:param value:value andReturnBlock:block];
}

- (void)stopVF:(ReturnBlock)block {
    [_cmdClient stopVF:block];
}

- (void)resetVF:(ReturnBlock)block {
    [_cmdClient resetVF:block];
}

#pragma mark File Module

- (void)startSearchFiles {
    
    NSString *rootFolder = @"/tmp/SD0";
    NSArray *folders = @[rootFolder];
    
    NSLog(@"start search files");
    [self searchFilesFromFolders:folders andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"all media files(%lu): %@", (unsigned long)[(NSArray *)result count], result);
    }];
}

- (void)searchFilesFromFolders:(NSArray *)pFolders andReturnBlock:(ReturnBlock)block {
    
    if (pFolders.count < 1 && block) {
        block(nil, 0, nil, ResultTypeNone);
        return;
    }
    
    NSString *folderName = pFolders[0];
    NSArray *otherFolders;
    if (pFolders.count > 1) {
        otherFolders = [pFolders subarrayWithRange:NSMakeRange(1, pFolders.count - 1)];
    }
    
    [self searchFilesInFolder:folderName andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        //
        if (!otherFolders && block) {
            block(error, cmd, result, type);
        } else {
            NSArray *folderFiles = (NSArray *)result;
            [self searchFilesFromFolders:[otherFolders copy] andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
                NSArray *otherFolderFiles = (NSArray *)result;
                NSMutableArray *allFiles = [NSMutableArray array];
                for (id media in folderFiles) {
                    [allFiles addObject:media];
                }
                for (id file in otherFolderFiles) {
                    [allFiles addObject:file];
                }
                //
                if (block) {
                    block(error, cmd, allFiles, type);
                }
            }];
        }
    }];
}

- (void)searchFilesInFolder:(NSString *)folderName andReturnBlock:(ReturnBlock)block {
    
    __block NSMutableArray *folderFiles = [NSMutableArray array];
    [_cmdClient changeToFolder:folderName andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        //
        [self->_cmdClient listAllFiles:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
            if (error) {
                NSLog(@"切换目录失败");
                if (block) {
                    block(error, cmd, result, type);
                }
                return ;
            }
            
            NSArray *listing = [(NSDictionary *)result objectForKey:@"listing"];
            NSMutableArray *folders = [NSMutableArray array];
            for (NSDictionary *itemDict in listing) {
                NSArray *allKeys = [itemDict allKeys];
                for (NSString *key in allKeys) {
                    if ([key containsString:@"."]) {
                        if ([self isMediaFile:key]) {
                            NSString *filePath = [folderName stringByAppendingPathComponent:key];
                            [folderFiles addObject:filePath];
                        }
                    } else {
                        NSString *folder = [folderName stringByAppendingPathComponent:key];
                        [folders addObject:folder];
                    }
                }
            }
            
            if (folders.count > 0) {
                [self searchFilesFromFolders:[folders copy] andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
                    //
                    [folderFiles addObjectsFromArray:[(NSArray *)result copy]];
                    if (block) {
                        block(error, cmd, folderFiles, type);
                    }
                }];
            } else {
                if (block) {
                    block(error, cmd, folderFiles, type);
                }
            }
        }];
    }];
}

- (BOOL)isMediaFile:(NSString *)fileName {
    
    if ([self isVideoFile:fileName] || [self isPhotoFile:fileName]) {
        return true;
    } else {
        return false;
    }
}

- (BOOL)isVideoFile:(NSString *)fileName {
    return [fileName hasSuffix:@".MP4"];
}

- (BOOL)isPhotoFile:(NSString *)fileName {
    return [fileName hasSuffix:@".JPG"];
}

- (NSString *)simpleFileName:(NSString *)fileName {
    
    NSString *file;
    //    if (fileName.length > 0) {
    //        file = [[fileName componentsSeparatedByString:@"_"] lastObject];
    //    }
    if (fileName.length > 12) {
        file = [fileName substringFromIndex:12];
    } else {
        file = fileName;
    }
    
    return file;
}

- (NSString *)fileTimeFromName:(NSString *)fileName {
    
    NSString *fTime;
    if (fileName.length > 1) {
        NSArray *fCmps = [fileName componentsSeparatedByString:@"_"];
        if (fCmps.count > 1) {
            fTime = fCmps[1];
            if (fTime.length == 20) {
                fTime = [fTime substringFromIndex:6];
            }
#warning 转换时间戳
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[fTime integerValue]];
            fTime = [formatter stringFromDate:confromTimesp];
        }
    }
    
    return fTime;
}

#pragma mark - Private

- (void)updateMachineCapabilityList{
    // 视频质量
    [self queryCmdValueList:@"video_quality" andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSArray *items;
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = (NSDictionary *)result;
            items = [resultDict objectForKey:@"options"];
        }
        self->_videoQuality = items;
        
        // 视频分辨率
        [self queryCmdValueList:@"video_resolution" andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
            NSArray *items;
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSDictionary *resultDict = (NSDictionary *)result;
                items = [resultDict objectForKey:@"options"];
            }
            self->_movieRecordSizeList = items;
            
            // 视频编码
            [self queryCmdValueList:@"video_coding_format" andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
                NSArray *items;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *resultDict = (NSDictionary *)result;
                    items = [resultDict objectForKey:@"options"];
                }
                self->_tvModList = items;
            }];
        }];
    }];
}

- (void)connectMachineOvertime {
    
    [_cmdClient disconnectFromMachine];
    if (_connectedStatusBlock) {
        [_cmdClient disconnectFromMachine];
        NSError *error = [self errorWithMsg:@"machine is disconnect"];
        _connectedStatusBlock(error, 0, nil, ResultTypeNone);
    }
    [self stopOvertime];
}

- (void)startOvertime {
    
    _connectTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(connectMachineOvertime) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_connectTimer forMode:NSRunLoopCommonModes];
}

- (void)stopOvertime {
    
    if (_connectTimer) {
        [_connectTimer invalidate];
        _connectTimer = nil;
    }
}

#pragma mark - AmbaCmdClientDelegate

- (void)ambaCmdClient:(AmbaCmdClient *)machine didUpdateConnectionStatus:(BOOL)isConnected forStream:(nonnull NSStream *)pStream{
    NSLog(@"[%@ %@]%@ is connected: %d",
          NSStringFromClass([self class]),
          NSStringFromSelector(_cmd),
          [pStream class],
          _cmdClient.isConnected);
    
    if (isConnected && [pStream isKindOfClass:[NSInputStream class]]) {
        [self stopOvertime];
    }
    
    if (_connectedStatusBlock) {
        if (isConnected) {
            if ([pStream isKindOfClass:[NSOutputStream class]]) {
                [self startSession:_connectedStatusBlock];
            }
        } else {
            [_cmdClient disconnectFromMachine];
            NSError *error = [self errorWithMsg:@"machine is disconnect"];
            _connectedStatusBlock(error, 0, nil, ResultTypeNone);
        }
    }
}

- (void)ambaCmdClient:(AmbaCmdClient *)client connectErrorForStream:(NSStream *)pStream {
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self connectMachineOvertime];
    
}

#pragma mark -

- (NSError *)errorWithMsg:(NSString *)msg {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:NSStringFromClass(self.class)
                                         code:-1
                                     userInfo:userInfo];
    return error;
}

#pragma mark - Camera API

- (CameraCommandStatus *)commandStatus {
    return _commandStatus;
}

- (void)queryCommandStatus:(ReturnBlock)block {
    
    [self currentMachineStatus:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"current machine status: %@", result);
        //
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = (NSDictionary *)result;
            NSArray *paramArr = [resultDict objectForKey:@"param"];
            for (NSDictionary *itemDict in paramArr) {
                NSString *key = [itemDict allKeys].firstObject;
                // 视频分辨率
                if ([key isEqualToString:@"video_resolution"]) {
                    self->_commandStatus.curRecordSize = [itemDict objectForKey:key];
                    continue;
                }
                // 视频质量
                if ([key isEqualToString:@"video_quality"]) {
                    self->_commandStatus.curVideoQuality = [itemDict objectForKey:key];
                    continue;
                }
                // 视频编码
                if ([key isEqualToString:@"video_coding_format"]) {
                    self->_commandStatus.curTVFormat = [itemDict objectForKey:key];
                    continue;
                }
            }
        }
        //
        [self queryAppCurrentStatus:block];
    }];
}

- (void)record:(id)value returnBlock:(ReturnBlock)block {
    
    BOOL startRecord = [value boolValue];
    if (startRecord) {
        [self startRecord:block];
    } else {
        [self stopRecord:block];
    }
}

- (void)capturePhoto:(ReturnBlock)block {
    
    [self takePhoto:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"take photo result: %@", result);
        if (block) {
            block(error, cmd, result, type);
        }
    }];
}

- (void)cardStatus:(ReturnBlock)block {
    if (block) {
        block(nil, 0, nil, ResultTypeNone);
    }
}

- (void)mediaStream:(BOOL)isOn mode:(int)mode returnBlock:(ReturnBlock)block {
    if (block) {
         block(nil, 0, nil, ResultTypeNone);
    }
}

- (void)recordTime:(ReturnBlock)block {
    if (block) {
        block(nil, 0, nil, ResultTypeNone);
    }
}

- (void)changeToMode:(id)value returnBlock:(ReturnBlock)block {
    _commandStatus.curCameraMode = (_commandStatus.curCameraMode != CameraModeMovie) ? CameraModeMovie : CameraModePhoto;
    if (block) {
        block(nil, 0, nil, ResultTypeNone);
    }
}

- (void)liveView:(id)value  returnBlock:(ReturnBlock)block {
    
    int status = [value intValue];
    if (status == 1) {
        [self resetVF:block];
    } else {
        [self stopVF:block];
    }
}

- (void)videoQualityList:(ReturnBlock)block {
    if (block) {
        block(nil, 0, _videoQuality, ResultTypeNone);
    }
}

- (void)movieRecordSizeList:(ReturnBlock)block {
    if (block) {
        block(nil, 0, _movieRecordSizeList, ResultTypeNone);
    }
}

- (void)tvModList:(ReturnBlock)block {
    if (block) {
        block(nil, 0, _tvModList, ResultTypeNone);
    }
}

- (void)setRecordSize:(id)value returnBlock:(ReturnBlock)block {
    __weak typeof(self) weakSelf = self;
    [self setCameraParameter:@"video_resolution" value:value andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = (NSDictionary *)result;
            int rval = [[resultDict objectForKey:@"rval"] intValue];
            if (rval == 0) {
                strongSelf->_commandStatus.curRecordSize = value;
            }
        }
        if (block) {
            block(error, cmd, result, type);
        }
    }];
}

- (void)setTVFormat:(id)value returnBlock:(ReturnBlock)block {
    __weak typeof(self) weakSelf = self;
    [self setCameraParameter:@"video_coding_format" value:value andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = (NSDictionary *)result;
            int rval = [[resultDict objectForKey:@"rval"] intValue];
            if (rval == 0) {
                strongSelf->_commandStatus.curTVFormat = value;
            }
        }
        if (block) {
            block(error, cmd, result, type);
        }
    }];
}

- (void)setVideoQuality:(id)value returnBlock:(ReturnBlock)block {
    __weak typeof(self) weakSelf = self;
    [self setCameraParameter:@"video_quality" value:value andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = (NSDictionary *)result;
            int rval = [[resultDict objectForKey:@"rval"] intValue];
            if (rval == 0) {
                strongSelf->_commandStatus.curVideoQuality = value;
            }
        }
        if (block) {
            block(error, cmd, result, type);
        }
    }];
}

- (void)systemFormat:(ReturnBlock)block {
    [self formatSDCard:block];
}

- (void)systemReset:(ReturnBlock)block {
    [_cmdClient setCameraParameter:@"default_setting" value:@"on" andReturnBlock:block];
}

- (void)getFileListForType:(id)value returnBlock:(ReturnBlock)block {
    //
    NSString *rootFolder = @"/tmp/SD0";
    NSArray *folders = @[rootFolder];
    NSLog(@"[%@]start search files", NSStringFromClass([self class]));
    [self searchFilesFromFolders:folders andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"all media files(%lu): %@", (unsigned long)[(NSArray *)result count], result);
        // 构造file数据模型
        NSMutableArray *fileModels = [NSMutableArray array];
        if ([result isKindOfClass:[NSArray class]]) {
            NSArray *files = (NSArray *)result;
            for (NSString *file in files) {
                CFiledModel *model = [[CFiledModel alloc] init];
//                model.fName = [file lastPathComponent];
                model.fName = [self simpleFileName:[file lastPathComponent]];
                model.isPhoto = [self isPhotoFile:file];
                if (model.isPhoto) {
                    model.fpath = file;
                } else {
#warning Amba回播地址拼接全部无效
                    model.fpath = [NSString stringWithFormat:@"rtsp://%@%@", kAmbaIpAddress, file];
//                    model.fpath = [NSString stringWithFormat:@"http://%@%@", kAmbaIpAddress, file];
                }
                // 普通/紧急 视频区分属性
                model.fattr = @"32";
//                model.ftime = [self fileTimeFromName:[file lastPathComponent]];
                model.ftime = [NSString stringWithFormat:@"%@", [NSDate date]];
                // 选择性返回 视频/图片 文件
//                if ([value intValue] == VideoTypeLoop) {
//                    [fileModels addObject:model];
//                } else
                    if ([value intValue] == VideoTypePhoto && model.isPhoto) {
                    [fileModels addObject:model];
                } else if ([value intValue] != VideoTypePhoto && !model.isPhoto) {
                    [fileModels addObject:model];
                }
                
            }
        }
        
        if (block) {
            block(error, cmd, fileModels, type);
        }
    }];
}



@end
