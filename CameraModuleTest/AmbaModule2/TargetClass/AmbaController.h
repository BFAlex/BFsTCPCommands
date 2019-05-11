//
//  AmbaController.h
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraControllerHeader.h"
//#import "CameraController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AmbaController : NSObject

//- (void)connectToCamera:(ReturnBlock)block;
//- (void)disconnectFromCamera:(ReturnBlock)block;
//- (void)takePhoto:(ReturnBlock)block;
//- (void)startRecord:(ReturnBlock)block;
//- (void)stopRecord:(ReturnBlock)block;
//- (void)formatSDCard:(ReturnBlock)block;
//- (void)listAllFiles:(ReturnBlock)block;
//- (void)queryCmdValueList:(NSString *)cmdTitle andReturnBlock:(ReturnBlock)block;
//- (void)queryAppCurrentStatus:(ReturnBlock)block;
//- (void)queryDeviceInfo:(ReturnBlock)block;
//- (void)setCameraParameter:(NSString *)param value:(NSString *)value andReturnBlock:(ReturnBlock)block;
//- (void)stopVF:(ReturnBlock)block;
//- (void)resetVF:(ReturnBlock)block;

#pragma mark - Command status
- (CameraCommandStatus *)commandStatus;

@end

NS_ASSUME_NONNULL_END
