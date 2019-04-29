//
//  AmbaCommand.m
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "AmbaCommand.h"

@implementation AmbaCommand

+ (instancetype)command {
    
    AmbaCommand *command = [[AmbaCommand alloc] init];
    if (command) {
        //
        [command setupDefault];
    }
    
    return command;
}

- (void)setupDefault {
    
    self.orderPrority = BFSOrderPriorityNormal;
}

@end
