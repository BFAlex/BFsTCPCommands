//
//  AmbaController.h
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraControllerHeader.h"
#import "AmbaCmdClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface AmbaControllerDemo : NSObject

- (void)connectToCamera:(ReturnBlock)block;
- (void)disconnectFromCamera:(ReturnBlock)block;
- (void)startSession:(ReturnBlock)block;
- (void)setClientInfo:(ReturnBlock)block;
- (void)takePhoto:(ReturnBlock)block;
- (void)startRecord:(ReturnBlock)block;
- (void)stopRecord:(ReturnBlock)block;
- (void)currentMachineStatus:(ReturnBlock)block;
- (void)formatSDCard:(ReturnBlock)block;
- (void)listAllFiles:(ReturnBlock)block;
- (void)queryCmdValueList:(NSString *)cmdTitle andReturnBlock:(ReturnBlock)block;
- (void)queryAppCurrentStatus:(ReturnBlock)block;
- (void)queryDeviceInfo:(ReturnBlock)block;
- (void)setCameraParameter:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block;
- (void)systemReset:(ReturnBlock)block;
- (void)changeToFolder:(NSString *)folderName andReturnBlock:(ReturnBlock)block;
- (void)stopVF:(ReturnBlock)block;
- (void)resetVF:(ReturnBlock)block;
//- (void)getThumbnail:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block;
- (void)getThumbnailOfFile:(NSString *)filePath andReturnBlock:(ReturnBlock)block;
// 文件
//- (void)getMediaFile:(NSString *)fileName ipAddress:(NSString *)ipaddress andReturnBlock:(ReturnBlock)block;
- (void)getMediaFile:(NSString *)fileName downloadingBlock:(DownloadingBlock)downloadingBlock andReturnBlock:(ReturnBlock)block;

@end

NS_ASSUME_NONNULL_END
