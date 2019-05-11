//
//  AmbaFileManager.h
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/5/8.
//  Copyright © 2019年 BFs. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "AmbaClient.h"
#import "BFFileAssistant.h"
#import "AmbaCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface AmbaDataClient : AmbaClient

+ (instancetype)sharedInstance;
- (void)destoryInstance;
//
//- (void)initDataCommunication: (NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo fileName:(NSString *)fileName;
- (void)connectToDataService:(NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo;
- (void)closeTheConnectionToDataServer;
- (void)downloadFile:(NSString *)fileName downloadingBlock:(DownloadingBlock)downloadingBlock andReturnBlock:(ReturnBlock)block;
- (void)closeFileDownloadConnection;
//
- (void)prepareToGetThumbnailOfFile:(NSString *)fileName;
- (NSString *)getDownloadFilePath;

@end

NS_ASSUME_NONNULL_END
