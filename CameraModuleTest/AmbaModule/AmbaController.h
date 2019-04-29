//
//  AmbaController.h
//  RoadCam
//
//  Created by 刘玲 on 2019/4/28.
//  Copyright © 2019年 HSH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraControllerHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface AmbaController : NSObject

@property (nonatomic, readonly) ReturnBlock resultBlock;

#pragma mark - Connection
- (void)connectToCamera:(ReturnBlock)block;

#pragma mark - Special API
- (void)handleReceivedResult:(id)result;

@end

NS_ASSUME_NONNULL_END
