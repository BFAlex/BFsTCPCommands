//
//  ViewController.m
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "ViewController.h"
#import "AmbaController.h"

@interface ViewController ()
@property (nonatomic, strong) AmbaController *ambaController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _ambaController = [[AmbaController alloc] init];
}

- (IBAction)actionConnectBtn:(UIButton *)sender {
    
    [_ambaController connectToCamera:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"tcp 连接会话结果：%@", !error?@"成功":error.description);
        NSLog(@"tcp连接结果: %@", result);
    }];
}
- (IBAction)actionSessionBtn:(UIButton *)sender {
    
    [_ambaController startSession:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"开启会话结果: %@", resultStr);
        
        [self actionSettingBtn:nil];
    }];
}
- (IBAction)actionDisconnectBtn:(UIButton *)sender {
    [_ambaController disconnectFromCamera:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSLog(@"断开连接...");
    }];
}
- (IBAction)actionTakePhotoBtn:(UIButton *)sender {
    [_ambaController takePhoto:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"拍照结果: %@", resultStr);
    }];
}
- (IBAction)actionStartRecordBtn:(UIButton *)sender {
    [_ambaController startRecord:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"开启录制结果: %@", resultStr);
    }];
}
- (IBAction)actionStopRecordBtn:(UIButton *)sender {
    [_ambaController stopRecord:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"关闭录制结果: %@", resultStr);
    }];
}
- (IBAction)actionSettingBtn:(UIButton *)sender {
    [_ambaController currentMachineStatus:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"setting结果: %@", resultStr);
    }];
}
- (IBAction)actionFormatSDBtn:(UIButton *)sender {
    [_ambaController formatSDCard:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"Format SD 结果: %@", resultStr);
    }];
}
- (IBAction)actionListAllFiles:(UIButton *)sender {
    [_ambaController listAllFiles:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"List All Files结果: %@", resultStr);
    }];
}
- (IBAction)actionListOfVideoResolutionValues:(UIButton *)sender {
    [_ambaController queryCmdValueList:@"video_resolution" andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"video_resolution结果: %@", resultStr);
    }];
}
- (IBAction)actionListOfVideoCodingFormatValues:(UIButton *)sender {
    [_ambaController queryCmdValueList:@"video_coding_format" andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"video_coding_format结果: %@", resultStr);
    }];
}
- (IBAction)actionListOfVideoQualityValues:(UIButton *)sender {
    [_ambaController queryCmdValueList:@"video_quality" andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"video_quality结果: %@", resultStr);
    }];
}
- (IBAction)actionAppStatusBtn:(UIButton *)sender {
    [_ambaController queryAppCurrentStatus:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"app status结果: %@", resultStr);
    }];
}
- (IBAction)actionDeviceInfoBtn:(UIButton *)sender {
    [_ambaController queryDeviceInfo:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"device Info结果: %@", resultStr);
    }];
}
- (IBAction)actionVideoQualityBtn:(UIButton *)sender {
}
- (IBAction)actionSystemResetBtn:(UIButton *)sender {
    [_ambaController systemReset:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"System Reset结果: %@", resultStr);
    }];
}
- (IBAction)actionStartVFBtn:(UIButton *)sender {
    [_ambaController resetVF:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"StartVF结果: %@", resultStr);
    }];
}
- (IBAction)actionStopVFBtn:(UIButton *)sender {
    [_ambaController stopVF:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"StopVF结果: %@", resultStr);
    }];
}
- (IBAction)actionFilePathBtn:(UIButton *)sender {
    
//    [self searchTestFolders];
    [self startSearchFiles];
}


#pragma mark - Func

- (void)searchTestFolders {
    
    [_ambaController changeToFolder:@"/tmp/SD0/DCIM" andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        [self->_ambaController stopVF:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
            NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        }];
    }];
}
// *************
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
    [_ambaController changeToFolder:folderName andReturnBlock:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        //
        [self->_ambaController listAllFiles:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
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
                    if ([key containsString:@"."] && [self isMediaFile:key]) {
                        NSString *filePath = [folderName stringByAppendingPathComponent:key];
                        [folderFiles addObject:filePath];
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
    
    if ([fileName hasSuffix:@".MP4"] || [fileName hasSuffix:@".JPG"]) {
        return true;
    } else {
        return false;
    }
}

@end
