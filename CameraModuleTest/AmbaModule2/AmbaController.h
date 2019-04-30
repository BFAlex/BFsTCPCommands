//
//  AmbaController.h
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraControllerHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface AmbaController : NSObject

- (void)connectToCamera:(ReturnBlock)block;
- (void)disconnectFromCamera:(ReturnBlock)block;
- (void)startSession:(ReturnBlock)block;
- (void)takePhoto:(ReturnBlock)block;
- (void)startRecord:(ReturnBlock)block;
- (void)stopRecord:(ReturnBlock)block;
- (void)currentMachineStatus:(ReturnBlock)block;
- (void)formatSDCard:(ReturnBlock)block;
- (void)listAllFiles:(ReturnBlock)block;

@end

NS_ASSUME_NONNULL_END
