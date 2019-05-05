//
//  AmbaCommand.h
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraControllerHeader.h"
#import <AVKit/AVKit.h>

// 指令优先级
typedef enum {
    BFSOrderPriorityLow = 0,
    BFSOrderPriorityNormal,
    BFSOrderPriorityMiddle,
    BFSOrderPriorityHightest,
} BFSOrderPriority;
//
typedef void (^ItemTaskBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface AmbaCommand : NSObject

@property (nonatomic, assign) BFSOrderPriority orderPrority;
@property (nonatomic, assign) int messageId;
@property (nonatomic, strong) NSString *param;
@property (nonatomic, strong) NSString *curCommand;
@property (nonatomic, copy) ItemTaskBlock taskBlock;
@property (nonatomic, copy) ReturnBlock returnBlock;

+ (instancetype)command;

@end

NS_ASSUME_NONNULL_END
