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
- (void)startSession;

@end

NS_ASSUME_NONNULL_END
