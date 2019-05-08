//
//  AmbaFileManager.h
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/5/8.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFFileAssistant.h"

NS_ASSUME_NONNULL_BEGIN

@interface AmbaFileManager : NSObject

+ (instancetype)sharedInstance;
- (void)destoryInstance;
//
- (void)initDataCommunication: (NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo fileName:(NSString *)fileName;
- (void)closeFileDownloadConnection;
- (void)closeTCPConnection;

@end

NS_ASSUME_NONNULL_END
